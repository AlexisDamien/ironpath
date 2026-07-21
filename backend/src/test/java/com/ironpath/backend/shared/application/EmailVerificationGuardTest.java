package com.ironpath.backend.shared.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class EmailVerificationGuardTest {

    private EmailVerificationGuard guard;

    @BeforeEach
    void setUp() {
        guard = new EmailVerificationGuard();
    }

    @Test
    void check_shouldThrowUnauthorizedException_whenEmailNotVerified() {
        User user = User.builder()
                .email("user@example.com")
                .emailVerifiedAt(null)
                .build();

        UnauthorizedException exception = assertThrows(
                UnauthorizedException.class,
                () -> guard.check(user)
        );

        assertTrue(exception.getMessage().contains("vérifier votre email"));
    }

    @Test
    void check_shouldNotThrow_whenEmailIsVerified() {
        User user = User.builder()
                .email("user@example.com")
                .emailVerifiedAt(LocalDateTime.now())
                .build();

        assertDoesNotThrow(() -> guard.check(user));
    }
}
