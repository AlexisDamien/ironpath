package com.ironpath.backend.shared.infrastructure;

import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.Deque;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;

@Component
public class LoginRateLimiter {

    private static final int MAX_ATTEMPTS = 5;
    private static final Duration WINDOW = Duration.ofMinutes(15);

    private final ConcurrentHashMap<String, Deque<Instant>> attemptsByKey =
            new ConcurrentHashMap<>();

    public void checkAllowed(String email) {
        String key = normalize(email);
        Deque<Instant> attempts = attemptsByKey.computeIfAbsent(
                key, unused -> new ConcurrentLinkedDeque<>()
        );

        Instant threshold = Instant.now().minus(WINDOW);
        attempts.removeIf(instant -> instant.isBefore(threshold));

        if (attempts.size() >= MAX_ATTEMPTS) {
            throw new TooManyAttemptsException(
                    "Trop de tentatives de connexion. Réessayez dans quelques minutes."
            );
        }
    }

    public void recordFailedAttempt(String email) {
        attemptsByKey
                .computeIfAbsent(normalize(email), unused -> new ConcurrentLinkedDeque<>())
                .addLast(Instant.now());
    }

    public void recordSuccessfulAttempt(String email) {
        attemptsByKey.remove(normalize(email));
    }

    private static String normalize(String email) {
        return email.toLowerCase().trim();
    }
}
