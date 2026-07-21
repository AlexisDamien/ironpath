package com.ironpath.backend.shared.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

class LoginRateLimiterTest {

    private LoginRateLimiter rateLimiter;

    @BeforeEach
    void setUp() {
        rateLimiter = new LoginRateLimiter();
    }

    @Test
    void checkAllowed_shouldNotThrow_whenNoAttemptsRecorded() {
        assertDoesNotThrow(() -> rateLimiter.checkAllowed("user@example.com"));
    }

    @Test
    void checkAllowed_shouldNotThrow_belowMaxAttempts() {
        String email = "user@example.com";

        for (int i = 0; i < 4; i++) {
            rateLimiter.recordFailedAttempt(email);
        }

        assertDoesNotThrow(() -> rateLimiter.checkAllowed(email));
    }

    @Test
    void checkAllowed_shouldThrow_whenMaxAttemptsReached() {
        String email = "user@example.com";

        for (int i = 0; i < 5; i++) {
            rateLimiter.recordFailedAttempt(email);
        }

        assertThrows(
                TooManyAttemptsException.class,
                () -> rateLimiter.checkAllowed(email)
        );
    }

    @Test
    void recordSuccessfulAttempt_shouldResetCounter() {
        String email = "user@example.com";

        for (int i = 0; i < 5; i++) {
            rateLimiter.recordFailedAttempt(email);
        }
        rateLimiter.recordSuccessfulAttempt(email);

        assertDoesNotThrow(() -> rateLimiter.checkAllowed(email));
    }

    @Test
    void checkAllowed_shouldBeCaseInsensitiveAndTrimmed_onEmail() {
        String email = "User@Example.com";

        for (int i = 0; i < 5; i++) {
            rateLimiter.recordFailedAttempt("  user@example.com  ");
        }

        assertThrows(
                TooManyAttemptsException.class,
                () -> rateLimiter.checkAllowed(email)
        );
    }

    @Test
    void attemptsForDifferentEmails_shouldBeIndependent() {
        for (int i = 0; i < 5; i++) {
            rateLimiter.recordFailedAttempt("blocked@example.com");
        }

        assertDoesNotThrow(() -> rateLimiter.checkAllowed("other@example.com"));
    }
}
