# Repo 1: User Core Service (`repo1-user-core-service`)

Spring Boot Microservice managing **5 database tables** in PostgreSQL:
- **3 Shared Common Tables**:
  1. `app_users` (User master table accessible across all 3 services)
  2. `audit_logs` (Centralized system audit trail used by all 3 services)
  3. `system_notifications` (Cross-service notification dispatch table)
- **2 Repo-Specific Tables**:
  4. `user_profiles` (Address, KYC status, phone numbers)
  5. `user_credentials` (Password hashes, authentication provider details)

## Port
`8081`

## SQL Schema Files
- **`schema-common-tables.sql`**: DDL and seed data for the 3 shared common tables (`app_users`, `audit_logs`, `system_notifications`).
- **`schema-repo1-specific.sql`**: DDL and seed data for Repo 1 specific tables (`user_profiles`, `user_credentials`).
- **`init-postgres-database.sql`**: Complete database initialization script covering all 9 tables across all 3 microservices.

## Functional Flow
1. **User Registration Flow**:
   - Inserts record into `app_users` (Common Table 1)
   - Inserts record into `user_profiles` (Repo 1 Table 1)
   - Inserts record into `user_credentials` (Repo 1 Table 2)
   - Writes event into `audit_logs` (Common Table 2)
   - Writes notification into `system_notifications` (Common Table 3)

## Running the Application
```bash
mvn spring-boot:run
```

## REST Endpoints
- `POST /api/users/register` - Register new user (populates all 5 tables)
- `GET  /api/users/{id}` - Fetch user by ID
- `GET  /api/users/all` - List all users
- `GET  /api/users/audit-logs` - Query shared audit logs
- `GET  /api/users/notifications/{userId}` - Query shared notifications for user
