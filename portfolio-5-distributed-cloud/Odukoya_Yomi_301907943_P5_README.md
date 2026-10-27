# Portfolio 5: Security, Data Governance, and Cloud Distribution

## 1. Executive Summary
This final module establishes the **Security Framework, Data Privacy Governance (GDPR/CCPA)**, and **Distributed Cloud Database Architecture** for the **Global Arcade Hub**. 

As a multi-tenant gaming platform handling global telemetry and personal user data, the platform combines **Role-Based Access Control (RBAC)**, **Row-Level Security (RLS)**, and **PII Data Masking** with a **Multi-Region Cloud Topology** supporting high availability and distributed scaling.

---

## 2. Security and Data Governance Architecture

### 2.1 Principle of Least Privilege & RBAC
We enforce granular user roles to prevent unauthorized data access:
* **`arcade_app_service`**: Full CRUD access restricted to transactional application workflows.
* **`arcade_analyst`**: Read-only access restricted strictly to anonymized analytics views (`v_masked_player_analytics`).
* **`arcade_auditor`**: Read-only access restricted to security audit logs (`security_audit_log`).

### 2.2 Row-Level Security (RLS)
PostgreSQL Row-Level Security ensures strict multi-tenant isolation. Players can only view or modify their own record:
```sql
CREATE POLICY player_self_service_policy ON player
    FOR ALL TO arcade_app_service
    USING (player_id = NULLIF(current_setting('app.current_player_id', true), '')::INT);
