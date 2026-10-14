-- ============================================================================
-- REPO 1: SHARED COMMON TABLES SCHEMA (Used across all 3 repositories)
-- Tables: app_users, audit_logs, system_notifications
-- Database: shared_app_db
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Common Table 1: app_users
-- Master user table; referenced by Repo 2 (orders) and Repo 3 (payments)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL,
    full_name VARCHAR(150),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Common Table 2: audit_logs
-- Written by all 3 repositories for centralized tracking and compliance
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    details VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- Common Table 3: system_notifications
-- Written by all 3 repositories for customer alerts and notifications
-- ----------------------------------------------------------------------------
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
-- Sample Seed Data for Common Tables
-- ----------------------------------------------------------------------------
INSERT INTO app_users (id, username, email, full_name, status) 
VALUES (1, 'john_doe', 'john.doe@example.com', 'John Doe', 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_logs (service_name, action, entity_type, entity_id, details)
VALUES 
('user-core-service', 'USER_REGISTERED', 'USER', 1, 'Initial seed user john_doe registered'),
('order-service', 'ORDER_CREATED', 'ORDER', 1, 'Initial seed order ORD-1001 placed for user john_doe'),
('payment-service', 'PAYMENT_COMPLETED', 'PAYMENT', 1, 'Initial seed payment TXN-ABC-001 processed for user john_doe')
ON CONFLICT DO NOTHING;

INSERT INTO system_notifications (user_id, channel, subject, message, status)
VALUES 
(1, 'EMAIL', 'Welcome!', 'Welcome to the platform, John Doe!', 'SENT'),
(1, 'SMS', 'Order Confirmation', 'Your order ORD-1001 has been placed successfully.', 'DISPATCHED'),
(1, 'EMAIL', 'Payment Receipt', 'Payment received for Invoice INV-2026-001.', 'DELIVERED')
ON CONFLICT DO NOTHING;
