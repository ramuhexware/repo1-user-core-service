-- ============================================================================
-- REPO 1 SPECIFIC TABLES SCHEMA (Used ONLY by repo1-user-core-service)
-- Tables: user_profiles, user_credentials
-- Database: shared_app_db
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Repo 1 Specific Table 1: user_profiles
-- Private profile data, address, phone, KYC verification
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    phone VARCHAR(50),
    address VARCHAR(255),
    kyc_status VARCHAR(50) DEFAULT 'UNVERIFIED',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_profile_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Repo 1 Specific Table 2: user_credentials
-- Private authentication data, password hashes, auth provider
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_credentials (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    auth_provider VARCHAR(50) DEFAULT 'LOCAL',
    last_login_at TIMESTAMP,
    CONSTRAINT fk_credential_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- Sample Seed Data for Repo 1 Specific Tables
-- ----------------------------------------------------------------------------
INSERT INTO user_profiles (id, user_id, phone, address, kyc_status) 
VALUES (1, 1, '+1-555-0100', '100 Broadway, NY', 'VERIFIED')
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_credentials (id, user_id, password_hash, auth_provider) 
VALUES (1, 1, 'HASH_e7b12', 'LOCAL')
ON CONFLICT (id) DO NOTHING;
