package com.example.usercore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@SpringBootApplication
public class UserCoreApplication {

    public static void main(String[] args) {
        SpringApplication.run(UserCoreApplication.class, args);
    }
}

@RestController
@RequestMapping("/api/users")
class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/register")
    public ResponseEntity<UserService.UserRegistrationResult> registerUser(@RequestBody Map<String, String> request) {
        UserService.UserRegistrationResult result = userService.registerUser(
                request.getOrDefault("username", "john_doe"),
                request.getOrDefault("email", "john@example.com"),
                request.getOrDefault("fullName", "John Doe"),
                request.getOrDefault("phone", "+1-555-0199"),
                request.getOrDefault("address", "123 Main St, New York, NY"),
                request.getOrDefault("password", "SecureP@ss123")
        );
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppUser> getUser(@PathVariable Long id) {
        return userService.findUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/all")
    public ResponseEntity<List<AppUser>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/audit-logs")
    public ResponseEntity<List<AuditLog>> getAuditLogs() {
        return ResponseEntity.ok(userService.getAllAuditLogs());
    }

    @GetMapping("/notifications/{userId}")
    public ResponseEntity<List<SystemNotification>> getNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(userService.getNotificationsForUser(userId));
    }
}
