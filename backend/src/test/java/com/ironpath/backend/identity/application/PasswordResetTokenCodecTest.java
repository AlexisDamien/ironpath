package com.ironpath.backend.identity.application;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PasswordResetTokenCodecTest {

    private PasswordResetTokenCodec codec;

    @BeforeEach
    void setUp() {
        codec = new PasswordResetTokenCodec();
    }

    @Test
    void generateToken_shouldReturnNonNullNonEmptyToken() {
        String token = codec.generateToken();

        assertNotNull(token);
        assertTrue(token.length() > 0);
    }

    @Test
    void generateToken_shouldReturnUrlSafeCharactersOnly() {
        String token = codec.generateToken();

        assertTrue(token.matches("^[A-Za-z0-9_-]+$"));
    }

    @Test
    void generateToken_shouldReturnDifferentTokensOnEachCall() {
        Set<String> tokens = new HashSet<>();
        for (int i = 0; i < 100; i++) {
            tokens.add(codec.generateToken());
        }

        assertEquals(100, tokens.size());
    }

    @Test
    void hashToken_shouldReturnConsistentHash_forSameInput() {
        String token = "some-reset-token";

        String hash1 = codec.hashToken(token);
        String hash2 = codec.hashToken(token);

        assertEquals(hash1, hash2);
    }

    @Test
    void hashToken_shouldReturnDifferentHashes_forDifferentInputs() {
        String hash1 = codec.hashToken("token-a");
        String hash2 = codec.hashToken("token-b");

        assertNotEquals(hash1, hash2);
    }

    @Test
    void hashToken_shouldReturnHexEncodedSha256_ie64CharsLowercase() {
        String hash = codec.hashToken("some-reset-token");

        assertEquals(64, hash.length());
        assertTrue(hash.matches("^[0-9a-f]{64}$"));
    }

    @Test
    void hashToken_shouldNeverEqualThePlainToken() {
        String token = codec.generateToken();

        String hash = codec.hashToken(token);

        assertNotEquals(token, hash);
    }
}
