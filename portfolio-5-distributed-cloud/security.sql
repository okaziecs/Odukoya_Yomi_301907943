-- Portfolio 5: Security, Privacy, and Data Governance Implementation
-- Environment: PostgreSQL

--------------------------------------------------------------------------------
-- 1. ROLE-BASED ACCESS CONTROL (RBAC)
--------------------------------------------------------------------------------

-- Create system roles following the Principle of Least Privilege
CREATE ROLE arcade_analyst WITH LOGIN PASSWORD 'AnalystSecurePass123!';
CREATE ROLE arcade_app_service WITH LOGIN PASSWORD 'AppServiceSecurePass123!';
CREATE ROLE arcade_auditor WITH LOGIN PASSWORD 'AuditorSecurePass123!';

-- Grant Application Service access (Full CRUD on transactional tables)
GRANT CONNECT ON DATABASE arcade_hub TO arcade_app_service;
GRANT USAGE ON SCHEMA public TO arcade_app_service;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO arcade_app_service;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO arcade_app_service;

-- Grant Analyst access (Read-Only access to analytical reporting views)
GRANT CONNECT ON DATABASE arcade_hub TO arcade_analyst;
GRANT USAGE ON SCHEMA public TO arcade_analyst;

-- Grant Auditor access (Read-Only access to audit logs and security trails)
GRANT CONNECT ON DATABASE arcade_hub TO arcade_auditor;
GRANT USAGE ON SCHEMA public TO arcade_auditor;

--------------------------------------------------------------------------------
-- 2. ROW-LEVEL SECURITY (RLS) FOR MULTI-TENANCY / PRIVACY
--------------------------------------------------------------------------------

-- Enable Row-Level Security on sensitive player profile table
ALTER TABLE player ENABLE ROW LEVEL SECURITY;

-- Policy 1: Players can only view and edit their own profile data
CREATE POLICY player_self_service_policy ON player
    FOR ALL
    TO arcade_app_service
    USING (player_id = NULLIF(current_setting('app.current_player_id', true), '')::INT);

-- Policy 2: Auditors can view all player profiles for compliance checks
CREATE POLICY auditor_read_all_policy ON player
    FOR SELECT
    TO arcade_auditor
    USING (true);

--------------------------------------------------------------------------------
-- 3. PII MASKING & PRIVACY VIEW (GDPR / CCPA COMPLIANCE)
--------------------------------------------------------------------------------

-- Dynamic Data Masking View for Data Analysts (Hides email & IP details)
CREATE OR REPLACE VIEW v_masked_player_analytics AS
SELECT 
    player_id,
    handle,
    -- Mask Email Address: e.g., 'john.doe@example.com' -> 'j***e@example.com'
    REGEXP_REPLACE(email, '^(.)(.*)(.)@(.*)$', '\1***\3@\4') AS masked_email,
    -- Anonymize IP address / Region identifiers
    country_code,
    joined_at,
    is_active
FROM player;

-- Grant Analyst read access ONLY to the masked view, denying direct table access
GRANT SELECT ON v_masked_player_analytics TO arcade_analyst;
REVOKE SELECT ON player FROM arcade_analyst;

--------------------------------------------------------------------------------
-- 4. IMMUTABLE AUDIT LOGGING FOR SECURITY GOVERNANCE
--------------------------------------------------------------------------------

CREATE TABLE security_audit_log (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    performed_by VARCHAR(50) NOT NULL DEFAULT CURRENT_USER,
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

-- Audit Trigger Function
CREATE OR REPLACE FUNCTION log_security_event()
RETURNS TRIGGER AS $$ BEGIN INSERT INTO security_audit_log (table_name, operation, old_data, new_data) VALUES ( TG_TABLE_NAME, TG_OP, CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END, CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END ); RETURN NEW; END; $$ LANGUAGE plpgsql;

-- Attach trigger to sensitive player updates
CREATE TRIGGER trg_audit_player_changes
AFTER INSERT OR UPDATE OR DELETE ON player
FOR EACH ROW EXECUTE FUNCTION log_security_event();

-- Restrict audit table modifications (Read-Only for auditors)
GRANT SELECT ON security_audit_log TO arcade_auditor;
REVOKE INSERT, UPDATE, DELETE ON security_audit_log FROM arcade_auditor, arcade_analyst;
