package com.ironpath.backend.shared.infrastructure;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JwtServiceTest {

    private static final String TEST_SECRET =
            "ironpath-secret-key-must-be-at-least-256-bits-long-for-hs256";

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secret", TEST_SECRET);
        ReflectionTestUtils.setField(jwtService, "expiration", 86_400_000L);
    }

    @Test
    void generateToken_shouldProduceNonNullToken() {
        UUID userId = UUID.randomUUID();

        String token = jwtService.generateToken(userId, "test@ironpath.com");

        assertNotNull(token);
        assertFalse(token.isBlank());
    }

    @Test
    void extractUserId_shouldReturnOriginalUserId_fromGeneratedToken() {
        UUID userId = UUID.randomUUID();

        String token = jwtService.generateToken(userId, "test@ironpath.com");

        assertEquals(userId, jwtService.extractUserId(token));
    }

    @Test
    void extractClaims_shouldContainEmailClaim() {
        UUID userId = UUID.randomUUID();

        String token = jwtService.generateToken(userId, "test@ironpath.com");
        Claims claims = jwtService.extractClaims(token);

        assertEquals("test@ironpath.com", claims.get("email"));
        assertEquals(userId.toString(), claims.getSubject());
    }

    @Test
    void isTokenValid_shouldReturnTrue_forFreshlyGeneratedToken() {
        String token = jwtService.generateToken(UUID.randomUUID(), "test@ironpath.com");

        assertTrue(jwtService.isTokenValid(token));
    }

    @Test
    void isTokenValid_shouldReturnFalse_forMalformedToken() {
        assertFalse(jwtService.isTokenValid("not-a-valid-jwt-token"));
    }

    @Test
    void isTokenValid_shouldReturnFalse_forExpiredToken() {
        ReflectionTestUtils.setField(jwtService, "expiration", -1000L);

        String expiredToken = jwtService.generateToken(UUID.randomUUID(), "test@ironpath.com");

        assertFalse(jwtService.isTokenValid(expiredToken));
    }

    @Test
    void isTokenValid_shouldReturnFalse_whenSignedWithDifferentSecret() {
        String token = jwtService.generateToken(UUID.randomUUID(), "test@ironpath.com");

        JwtService otherService = new JwtService();
        ReflectionTestUtils.setField(otherService, "secret",
                "a-completely-different-secret-key-that-is-also-long-enough");
        ReflectionTestUtils.setField(otherService, "expiration", 86_400_000L);

        assertFalse(otherService.isTokenValid(token));
    }
}
