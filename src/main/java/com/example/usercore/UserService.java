package com.example.usercore;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

// ---- Repositories for the 3 Common Tables ----
@Repository
interface UserRepository extends JpaRepository<AppUser, Long> {
    Optional<AppUser> findByUsername(String username);
}

@Repository
interface AuditLogRepository extends JpaRepository<AuditLog, Long> {
    List<AuditLog> findByServiceNameOrderByCreatedAtDesc(String serviceName);
}

@Repository
interface NotificationRepository extends JpaRepository<SystemNotification, Long> {
    List<SystemNotification> findByUserIdOrderByCreatedAtDesc(Long userId);
}

// ---- Repositories for the 2 Repo-1 Specific Tables ----
@Repository
interface UserProfileRepository extends JpaRepository<UserProfile, Long> {
    Optional<UserProfile> findByUserId(Long userId);
}

@Repository
interface UserCredentialRepository extends JpaRepository<UserCredential, Long> {
    Optional<UserCredential> findByUserId(Long userId);
}

// ---- Service orchestrating all 5 tables in Repo 1 ----
@Service
@Transactional
public class UserService {

    private final UserRepository userRepository;
    private final UserProfileRepository userProfileRepository;
    private final UserCredentialRepository userCredentialRepository;
    private final AuditLogRepository auditLogRepository;
    private final NotificationRepository notificationRepository;

    public UserService(UserRepository userRepository,
                       UserProfileRepository userProfileRepository,
                       UserCredentialRepository userCredentialRepository,
                       AuditLogRepository auditLogRepository,
                       NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.userProfileRepository = userProfileRepository;
        this.userCredentialRepository = userCredentialRepository;
        this.auditLogRepository = auditLogRepository;
        this.notificationRepository = notificationRepository;
    }

    /**
     * Functional flow demonstrating updates across ALL 5 tables in Repo 1:
     * 1. Common Table: app_users
     * 2. Specific Table: user_profiles
     * 3. Specific Table: user_credentials
     * 4. Common Table: audit_logs
     * 5. Common Table: system_notifications
     */
    public UserRegistrationResult registerUser(String username, String email, String fullName,
                                               String phone, String address, String rawPassword) {
        // 1. Save to Common Table: app_users
        AppUser user = userRepository.save(new AppUser(username, email, fullName, "ACTIVE"));

        // 2. Save to Specific Table: user_profiles
        UserProfile profile = userProfileRepository.save(new UserProfile(user.getId(), phone, address, "VERIFIED"));

        // 3. Save to Specific Table: user_credentials
        String passwordHash = "HASH_" + Integer.toHexString(rawPassword.hashCode());
        UserCredential credential = userCredentialRepository.save(new UserCredential(user.getId(), passwordHash, "LOCAL"));

        // 4. Save to Common Table: audit_logs
        AuditLog auditLog = auditLogRepository.save(new AuditLog(
                "user-core-service",
                "USER_REGISTERED",
                "USER",
                user.getId(),
                "New user registered: " + username + " with profile and credentials created"
        ));

        // 5. Save to Common Table: system_notifications
        SystemNotification notification = notificationRepository.save(new SystemNotification(
                user.getId(),
                "EMAIL",
                "Welcome to the Platform!",
                "Hello " + fullName + ", your account has been registered successfully.",
                "SENT"
        ));

        return new UserRegistrationResult(user.getId(), username, email, profile.getPhone(),
                auditLog.getId(), notification.getId());
    }

    @Transactional(readOnly = true)
    public Optional<AppUser> findUserById(Long id) {
        return userRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<UserProfile> findProfileByUserId(Long userId) {
        return userProfileRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<AppUser> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<AuditLog> getAllAuditLogs() {
        return auditLogRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<SystemNotification> getNotificationsForUser(Long userId) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    // Helper record for returning results
    public record UserRegistrationResult(
            Long userId,
            String username,
            String email,
            String phone,
            Long auditLogId,
            Long notificationId
    ) {}
}
