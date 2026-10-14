# Multi-Repository Spring Boot Microservices Architecture

This workspace contains **3 independent Git repositories** built in **Java 21** using **Spring Boot 3.3.4** and **PostgreSQL**.

---

## 📊 Summary: Common Tables vs. Individual Tables

| Repository | Total Tables Handled | 3 Common Tables (Shared) | Individual Tables (Repo-Specific) | Port |
| :--- | :---: | :--- | :--- | :---: |
| **`repo1-user-core-service`** | **5** | `app_users`, `audit_logs`, `system_notifications` | `user_profiles`, `user_credentials` | `8081` |
| **`repo2-order-service`** | **2** (+3 common) | `app_users` *(read)*, `audit_logs` *(write)*, `system_notifications` *(write)* | `customer_orders`, `order_items` | `8082` |
| **`repo3-payment-service`** | **2** (+3 common) | `app_users` *(read)*, `audit_logs` *(write)*, `system_notifications` *(write)* | `payment_transactions`, `payment_invoices` | `8083` |

---

## 🌐 1. The 3 Common Database Tables (Shared Across All 3 Repositories)

These **3 tables** are stored in PostgreSQL and accessed by all three microservices. They establish the shared core domain (users, audit trail, and customer communications).

### 1. `app_users` (Common Table 1)
* **Purpose**: Master table for registered user accounts across the entire platform.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `username` (VARCHAR, Unique, Not Null)
  - `email` (VARCHAR, Not Null)
  - `full_name` (VARCHAR)
  - `status` (VARCHAR: `ACTIVE`, `SUSPENDED`)
  - `created_at` (TIMESTAMP)
* **How each repository uses this table**:
  - **Repo 1 (`user-core-service`)**: **Writes & Manages**. Creates new user accounts during registration.
  - **Repo 2 (`order-service`)**: **Reads & Validates**. Checks user identity and status before allowing order placement.
  - **Repo 3 (`payment-service`)**: **Reads & Validates**. Checks user existence before authorizing and charging payments.

### 2. `audit_logs` (Common Table 2)
* **Purpose**: Centralized audit trail capturing business events from all 3 services in one unified table.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `service_name` (VARCHAR: `user-core-service`, `order-service`, `payment-service`)
  - `action` (VARCHAR: `USER_REGISTERED`, `ORDER_CREATED`, `PAYMENT_COMPLETED`)
  - `entity_type` (VARCHAR: `USER`, `ORDER`, `PAYMENT`)
  - `entity_id` (BIGINT)
  - `details` (VARCHAR(1000))
  - `created_at` (TIMESTAMP)
* **How each repository uses this table**:
  - **Repo 1 (`user-core-service`)**: Inserts audit log with `service_name = 'user-core-service'` when a user registers.
  - **Repo 2 (`order-service`)**: Inserts audit log with `service_name = 'order-service'` when an order is created.
  - **Repo 3 (`payment-service`)**: Inserts audit log with `service_name = 'payment-service'` when a payment is processed.

### 3. `system_notifications` (Common Table 3)
* **Purpose**: Centralized notifications and customer communication events triggered by any service.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `user_id` (BIGINT, Foreign reference to `app_users.id`)
  - `channel` (VARCHAR: `EMAIL`, `SMS`, `IN_APP`)
  - `subject` (VARCHAR)
  - `message` (VARCHAR(1000))
  - `status` (VARCHAR: `SENT`, `DISPATCHED`, `DELIVERED`)
  - `created_at` (TIMESTAMP)
* **How each repository uses this table**:
  - **Repo 1 (`user-core-service`)**: Sends welcome email notification upon user account activation.
  - **Repo 2 (`order-service`)**: Sends order placement confirmation alert with order number.
  - **Repo 3 (`payment-service`)**: Sends payment invoice receipt alert with transaction reference.

---

## 🔒 2. Individual Database Tables (With Respect to Each Repository)

These tables are **private and exclusive** to their respective repository. No other repository creates or alters them.

```
+-----------------------------------------------------------------------------------+
|                           POSTGRESQL DATABASE                                     |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                     3 COMMON TABLES (Shared Access)                         |  |
|  |  * app_users            * audit_logs            * system_notifications      |  |
|  +-----------------------------------------------------------------------------+  |
|            ^                               ^                              ^       |
|            |                               |                              |       |
|  +---------+------------+     +------------+-----------+     +------------+-----+ |
|  | REPO 1: USER CORE    |     | REPO 2: ORDER SERVICE  |     | REPO 3: PAYMENT  | |
|  |                      |     |                        |     |                  | |
|  | [Individual Tables]  |     | [Individual Tables]    |     | [Indiv. Tables]  | |
|  | 1. user_profiles     |     | 1. customer_orders     |     | 1. payment_txns  | |
|  | 2. user_credentials  |     | 2. order_items         |     | 2. payment_inv   | |
|  +----------------------+     +------------------------+     +------------------+ |
+-----------------------------------------------------------------------------------+
```

### A. Repository 1: `repo1-user-core-service` (Port 8081)
*Total: **5 tables** (3 Common + 2 Individual)*

#### 1. `user_profiles` *(Individual Table 1 of Repo 1)*
* **Scope**: **Used ONLY in Repo 1**.
* **Purpose**: Stores profile, contact, and compliance/KYC data for users.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `user_id` (BIGINT, Unique, references `app_users.id`)
  - `phone` (VARCHAR)
  - `address` (VARCHAR)
  - `kyc_status` (VARCHAR: `VERIFIED`, `PENDING`, `REJECTED`)
  - `updated_at` (TIMESTAMP)

#### 2. `user_credentials` *(Individual Table 2 of Repo 1)*
* **Scope**: **Used ONLY in Repo 1**.
* **Purpose**: Stores authentication credentials, password hashes, and security metadata.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `user_id` (BIGINT, Unique, references `app_users.id`)
  - `password_hash` (VARCHAR, Not Null)
  - `auth_provider` (VARCHAR: `LOCAL`, `GOOGLE`, `OKTA`)
  - `last_login_at` (TIMESTAMP)

---

### B. Repository 2: `repo2-order-service` (Port 8082)
*Total: **2 Individual tables** (+ accesses the 3 Common tables)*

#### 1. `customer_orders` *(Individual Table 1 of Repo 2)*
* **Scope**: **Used ONLY in Repo 2**.
* **Purpose**: Stores high-level customer order headers, amounts, and statuses.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `user_id` (BIGINT, references `app_users.id` from common table)
  - `order_number` (VARCHAR, Unique, Not Null)
  - `total_amount` (NUMERIC(12, 2), Not Null)
  - `status` (VARCHAR: `CONFIRMED`, `SHIPPED`, `CANCELLED`)
  - `created_at` (TIMESTAMP)

#### 2. `order_items` *(Individual Table 2 of Repo 2)*
* **Scope**: **Used ONLY in Repo 2**.
* **Purpose**: Stores granular line items, quantities, and pricing for each order.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `order_id` (BIGINT, Not Null, references `customer_orders.id`)
  - `product_sku` (VARCHAR, Not Null)
  - `product_name` (VARCHAR)
  - `quantity` (INTEGER, Not Null)
  - `unit_price` (NUMERIC(12, 2), Not Null)

---

### C. Repository 3: `repo3-payment-service` (Port 8083)
*Total: **2 Individual tables** (+ accesses the 3 Common tables)*

#### 1. `payment_transactions` *(Individual Table 1 of Repo 3)*
* **Scope**: **Used ONLY in Repo 3**.
* **Purpose**: Records financial payment transactions, gateways, and payment statuses.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `order_id` (BIGINT, Not Null, references order from Repo 2)
  - `user_id` (BIGINT, Not Null, references user from common `app_users`)
  - `amount` (NUMERIC(12, 2), Not Null)
  - `payment_method` (VARCHAR: `CREDIT_CARD`, `DEBIT_CARD`, `PAYPAL`)
  - `payment_status` (VARCHAR: `SUCCESS`, `FAILED`, `PENDING`)
  - `transaction_reference` (VARCHAR, Unique, Not Null)
  - `created_at` (TIMESTAMP)

#### 2. `payment_invoices` *(Individual Table 2 of Repo 3)*
* **Scope**: **Used ONLY in Repo 3**.
* **Purpose**: Records legal customer invoices, calculated sales taxes, and total amounts paid.
* **Columns**:
  - `id` (BIGSERIAL, Primary Key)
  - `payment_id` (BIGINT, Unique, Not Null, references `payment_transactions.id`)
  - `invoice_number` (VARCHAR, Unique, Not Null)
  - `tax_amount` (NUMERIC(12, 2), Not Null)
  - `total_amount` (NUMERIC(12, 2), Not Null)
  - `issued_at` (TIMESTAMP)

---

## 📁 Repository Structure & SQL Files Layout (Exactly 12 Java Files)

```
Multi_Repo_Simple/
├── repo1-user-core-service/             <-- Git Repo 1 (Port 8081)
│   ├── .git/
│   ├── pom.xml
│   ├── COMMON_README.md                 (Complete multi-repo architecture documentation)
│   ├── schema-common-tables.sql         (The 3 Common Tables: app_users, audit_logs, system_notifications)
│   ├── schema-repo1-specific.sql        (Repo 1 Individual Tables: user_profiles, user_credentials)
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   ├── schema-common-tables.sql
│   │   └── schema-repo1-specific.sql
│   └── src/main/java/com/example/usercore/
│       ├── CommonEntities.java          (1. app_users, audit_logs, system_notifications)
│       ├── UserEntities.java            (2. user_profiles, user_credentials)
│       ├── UserService.java             (3. Repositories + User registration flow)
│       └── UserCoreApplication.java     (4. Spring Boot App + REST Controller)
│
├── repo2-order-service/                 <-- Git Repo 2 (Port 8082)
│   ├── .git/
│   ├── pom.xml
│   ├── schema-repo2-order-service.sql   (Repo 2 Individual Tables: customer_orders, order_items)
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── schema-repo2-order-service.sql
│   └── src/main/java/com/example/orderservice/
│       ├── CommonEntities.java          (5. app_users, audit_logs, system_notifications)
│       ├── OrderEntities.java           (6. customer_orders, order_items)
│       ├── OrderService.java            (7. Repositories + Order placement flow)
│       └── OrderApplication.java        (8. Spring Boot App + REST Controller)
│
├── repo3-payment-service/               <-- Git Repo 3 (Port 8083)
│   ├── .git/
│   ├── pom.xml
│   ├── schema-repo3-payment-service.sql (Repo 3 Individual Tables: payment_transactions, payment_invoices)
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── schema-repo3-payment-service.sql
│   └── src/main/java/com/example/paymentservice/
│       ├── CommonEntities.java          (9.  app_users, audit_logs, system_notifications)
│       ├── PaymentEntities.java         (10. payment_transactions, payment_invoices)
│       ├── PaymentService.java          (11. Repositories + Payment processing flow)
│       └── PaymentApplication.java      (12. Spring Boot App + REST Controller)
│
├── test-all.ps1                         <-- Compiles all 3 repositories
├── test-apis.ps1                        <-- End-to-end API test script across all 3 services
└── README.md                            <-- Root Documentation
```

---

## 🔄 End-to-End Functional Flow Across Common Tables

1. **User Registration (`repo1-user-core-service` - Port 8081)**:
   - Endpoint: `POST /api/users/register`
   - Populates **Common Table 1 (`app_users`)** with user identity.
   - Populates **Repo 1 Individual Tables (`user_profiles`, `user_credentials`)**.
   - Emits log in **Common Table 2 (`audit_logs`)** (`service_name = "user-core-service"`).
   - Emits welcome notification in **Common Table 3 (`system_notifications`)**.

2. **Order Placement (`repo2-order-service` - Port 8082)**:
   - Endpoint: `POST /api/orders/create`
   - Validates user existence by querying **Common Table 1 (`app_users`)**.
   - Populates **Repo 2 Individual Tables (`customer_orders`, `order_items`)**.
   - Emits log in **Common Table 2 (`audit_logs`)** (`service_name = "order-service"`).
   - Emits notification in **Common Table 3 (`system_notifications`)**.

3. **Payment Processing (`repo3-payment-service` - Port 8083)**:
   - Endpoint: `POST /api/payments/process`
   - Validates payer existence by querying **Common Table 1 (`app_users`)**.
   - Populates **Repo 3 Individual Tables (`payment_transactions`, `payment_invoices`)**.
   - Emits log in **Common Table 2 (`audit_logs`)** (`service_name = "payment-service"`).
   - Emits notification in **Common Table 3 (`system_notifications`)**.

---

## 🚀 Running the Microservices

In separate terminal tabs, start the three microservices:

```bash
# Terminal 1 - Repo 1 (Port 8081)
cd repo1-user-core-service
mvn spring-boot:run

# Terminal 2 - Repo 2 (Port 8082)
cd repo2-order-service
mvn spring-boot:run

# Terminal 3 - Repo 3 (Port 8083)
cd repo3-payment-service
mvn spring-boot:run
```

---

## 🧪 Testing the 3 Common Tables (Via REST APIs)

Run the included automated API test script:
```powershell
.\test-apis.ps1
```

This script will:
1. Call **Repo 1** (`:8081`) to register a new user -> populates `app_users`, `audit_logs`, `system_notifications`.
2. Call **Repo 2** (`:8082`) to place an order for that user -> updates `customer_orders`, `order_items`, `audit_logs`, `system_notifications`.
3. Call **Repo 3** (`:8083`) to process payment for that order -> updates `payment_transactions`, `payment_invoices`, `audit_logs`, `system_notifications`.
4. Fetch all entries from the shared `audit_logs` and `system_notifications` tables to verify cross-service logging and notifications!

---

## 🐘 PostgreSQL Setup

Initialize PostgreSQL (`shared_app_db` on port 5432) using the separate SQL scripts for each repository:

```bash
# 1. Create the 3 Common Tables (from Repo 1)
psql -U postgres -d shared_app_db -f repo1-user-core-service/schema-common-tables.sql

# 2. Create Repo 1 Individual Tables (user_profiles, user_credentials)
psql -U postgres -d shared_app_db -f repo1-user-core-service/schema-repo1-specific.sql

# 3. Create Repo 2 Individual Tables (customer_orders, order_items)
psql -U postgres -d shared_app_db -f repo2-order-service/schema-repo2-order-service.sql

# 4. Create Repo 3 Individual Tables (payment_transactions, payment_invoices)
psql -U postgres -d shared_app_db -f repo3-payment-service/schema-repo3-payment-service.sql
```
*(No Docker required; connects directly to your standard local PostgreSQL server)*
