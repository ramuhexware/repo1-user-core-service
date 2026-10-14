package com.example.usercore;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Repo 1 Specific Table 1: user_profiles
 * Exclusively used by repo1-user-core-service.
 */
@Entity
@Table(name = "user_profiles")
class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    private String phone;

    private String address;

    @Column(name = "kyc_status")
    private String kycStatus;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();

    public UserProfile() {}

    public UserProfile(Long userId, String phone, String address, String kycStatus) {
        this.userId = userId;
        this.phone = phone;
        this.address = address;
        this.kycStatus = kycStatus;
        this.updatedAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getKycStatus() { return kycStatus; }
    public void setKycStatus(String kycStatus) { this.kycStatus = kycStatus; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}

/**
 * Repo 1 Specific Table 2: user_credentials
 * Exclusively used by repo1-user-core-service.
 */
@Entity
@Table(name = "user_credentials")
class UserCredential {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false, unique = true)
    private Long userId;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "auth_provider")
    private String authProvider;

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;

    public UserCredential() {}

    public UserCredential(Long userId, String passwordHash, String authProvider) {
        this.userId = userId;
        this.passwordHash = passwordHash;
        this.authProvider = authProvider;
        this.lastLoginAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getAuthProvider() { return authProvider; }
    public void setAuthProvider(String authProvider) { this.authProvider = authProvider; }
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
}
