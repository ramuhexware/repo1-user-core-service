-- ============================================================================
-- PostgreSQL Database Initialization Script for Multi-Repo Microservices Architecture
-- Database: shared_app_db
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. THE 3 COMMON / SHARED TABLES (Used across all 3 microservices repositories)
-- ----------------------------------------------------------------------------

-- Common Table 1: app_users
-- Created and managed by Repo 1; referenced by Repo 2 (orders) and Repo 3 (payments)
CREATE TABLE IF NOT EXISTS app_users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    full_name VARCHAR(150),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Common Table 2: audit_logs
-- Written by all 3 repositories for centralized tracking and compliance
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    details VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Common Table 3: system_notifications
-- Written by all 3 repositories for customer alerts and notifications
CREATE TABLE IF NOT EXISTS system_notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    channel VARCHAR(50),
    subject VARCHAR(200),
    message VARCHAR(1000),
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 2. REPO 1 SPECIFIC TABLES (Used ONLY by repo1-user-core-service)
-- Total tables in Repo 1 = 3 Common + 2 Specific = 5 Tables
-- ----------------------------------------------------------------------------

-- Repo 1 Specific Table 1: user_profiles
CREATE TABLE IF NOT EXISTS user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    phone VARCHAR(50),
    address VARCHAR(255),
    kyc_status VARCHAR(50) DEFAULT 'UNVERIFIED',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Repo 1 Specific Table 2: user_credentials
CREATE TABLE IF NOT EXISTS user_credentials (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    auth_provider VARCHAR(50) DEFAULT 'LOCAL',
    last_login_at TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 3. REPO 2 SPECIFIC TABLES (Used ONLY by repo2-order-service)
-- ----------------------------------------------------------------------------

-- Repo 2 Specific Table 1: customer_orders
CREATE TABLE IF NOT EXISTS customer_orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_number VARCHAR(100) NOT NULL UNIQUE,
    total_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Repo 2 Specific Table 2: order_items
CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    product_name VARCHAR(200),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(12, 2) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 4. REPO 3 SPECIFIC TABLES (Used ONLY by repo3-payment-service)
-- ----------------------------------------------------------------------------

-- Repo 3 Specific Table 1: payment_transactions
CREATE TABLE IF NOT EXISTS payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,
    transaction_reference VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Repo 3 Specific Table 2: payment_invoices
CREATE TABLE IF NOT EXISTS payment_invoices (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL UNIQUE,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    tax_amount NUMERIC(12, 2) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 5. SEED DATA DEMONSTRATING SHARED & REPO-SPECIFIC DATA
-- ----------------------------------------------------------------------------

-- Seed Common User (Created via Repo 1)
INSERT INTO app_users (id, username, email, full_name, status) 
VALUES (1, 'john_doe', 'john.doe@example.com', 'John Doe', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

-- Seed Repo 1 Specific Profile & Credential
INSERT INTO user_profiles (id, user_id, phone, address, kyc_status) 
VALUES (1, 1, '+1-555-0100', '100 Broadway, NY', 'VERIFIED')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_credentials (id, user_id, password_hash, auth_provider) 
VALUES (1, 1, 'HASH_e7b12', 'LOCAL')
ON CONFLICT (id) DO NOTHING;

-- Seed Repo 2 Specific Order & Items (Referencing common user_id = 1)
INSERT INTO customer_orders (id, user_id, order_number, total_amount, status)
VALUES (1, 1, 'ORD-1001', 1249.98, 'CONFIRMED')
ON CONFLICT (id) DO NOTHING;

INSERT INTO order_items (id, order_id, product_sku, product_name, quantity, unit_price)
VALUES 
(1, 1, 'IPHONE-15', 'iPhone 15 128GB', 1, 1199.99),
(2, 1, 'CASE-01', 'Silicone Case', 1, 49.99)
ON CONFLICT (id) DO NOTHING;

-- Seed Repo 3 Specific Payment & Invoice (Referencing common user_id = 1 and order_id = 1)
INSERT INTO payment_transactions (id, order_id, user_id, amount, payment_method, payment_status, transaction_reference)
VALUES (1, 1, 1, 1249.98, 'CREDIT_CARD', 'SUCCESS', 'TXN-ABC-001')
ON CONFLICT (id) DO NOTHING;

INSERT INTO payment_invoices (id, payment_id, invoice_number, tax_amount, total_amount)
VALUES (1, 1, 'INV-2026-001', 99.99, 1349.97)
ON CONFLICT (id) DO NOTHING;

-- Seed Common Audit Logs showing contributions from all 3 services:
INSERT INTO audit_logs (service_name, action, entity_type, entity_id, details)
VALUES 
('user-core-service', 'USER_REGISTERED', 'USER', 1, 'User john_doe registered with profile & credentials'),
('order-service', 'ORDER_CREATED', 'ORDER', 1, 'Order ORD-1001 placed for user john_doe (total: $1249.98)'),
('payment-service', 'PAYMENT_COMPLETED', 'PAYMENT', 1, 'Payment TXN-ABC-001 processed for order 1 (total: $1349.97)');

-- Seed Common Notifications showing alerts created by all 3 services:
INSERT INTO system_notifications (user_id, channel, subject, message, status)
VALUES 
(1, 'EMAIL', 'Welcome!', 'Welcome to the platform, John Doe!', 'SENT'),
(1, 'SMS', 'Order Confirmation', 'Your order ORD-1001 has been placed successfully.', 'DISPATCHED'),
(1, 'EMAIL', 'Payment Receipt', 'Payment received for Invoice INV-2026-001.', 'DELIVERED');
