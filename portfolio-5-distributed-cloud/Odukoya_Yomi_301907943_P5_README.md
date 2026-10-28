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
### 2.3 PII Masking & Audit Logging
To ensure GDPR/CCPA compliance, direct access to raw player tables is restricted. The system enforces dynamic masking via database views:
* **`v_masked_player_analytics`**: Obfuscates sensitive fields such as player email addresses (`j***@domain.com`) and location metadata.
* **`security_audit_log`**: Triggers automatically capture operational changes, schema updates, and privilege escalations without exposure to application users.

---

## 3. Distributed Cloud Architecture & Topology

### 3.1 Polyglot Cloud Architecture & Multi-Region Setup
The system employs a **Polyglot Persistence Strategy** deployed across AWS and MongoDB Atlas to optimize for localized latency and strict data integrity:
* **Relational Layer (PostgreSQL - Neon / AWS RDS):** Serves as the primary source of truth for transactional data, deployed in `us-east-1` with synchronous Multi-AZ failover and asynchronous read-replicas in `eu-central-1` (Frankfurt) and `ap-southeast-1` (Singapore).
* **Document Stream Layer (MongoDB Atlas):** Managed cluster configured for high-throughput score telemetry across global shards.

```json
{
  "clusterName": "global-arcade-hub-production",
  "cloudProvider": "AWS / MongoDB Atlas Hybrid",
  "topology": {
    "relationalCore": {
      "engine": "PostgreSQL Amazon RDS Multi-AZ",
      "primaryRegion": "us-east-1 (N. Virginia)",
      "readReplicas": [
        { "region": "eu-central-1 (Frankfurt)", "purpose": "Low-latency regional queries & analytics" },
        { "region": "ap-southeast-1 (Singapore)", "purpose": "APAC player read requests" }
      ]
    },
    "noSQLStream": {
      "engine": "MongoDB Atlas Multi-Region Cluster",
      "shardingStrategy": {
        "shardKey": { "eventType": "hashed", "occurredAt": 1 },
        "shards": [
          { "shardId": "shard_us", "region": "us-east-1" },
          { "shardId": "shard_eu", "region": "eu-central-1" },
          { "shardId": "shard_apac", "region": "ap-southeast-1" }
        ]
      }
    }
  }
}

PROPOSED DISTRIBUTED HYBRID ARCHITECTURE — (PROPOSAL ONLY)

                     ┌────────────────────────────────────────┐
                     │            Application Core            │
                     │          (Global Arcade Hub)           │
                     └───────────────────┬────────────────────┘
                                         │
                 ┌───────────────────────┴───────────────────────┐
                 │                                               │
                 ▼                                               ▼
   ┌───────────────────────────┐                   ┌───────────────────────────┐
   │ PostgreSQL Relational     │                   │   MongoDB Atlas Primary   │
   │ Core (CP Mode)            │                   │   Zone A (AP Telemetry)   │
   │ - User Profiles & Auth    │                   └─────────────┬─────────────┘
   │ - Player Transactions     │                                 │
   └───────────────────────────┘                 ┌───────────────┴───────────────┐
                                                 │                               │
                                                 ▼                               ▼
                                   ┌───────────────────────────┐   ┌───────────────────────────┐
                                   │  Secondary · Replica B    │   │  Secondary · Replica C    │
                                   │  (eu-central-1)           │   │  (ap-southeast-1)         │
                                   └───────────────────────────┘   └───────────────────────────┘
