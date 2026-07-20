package com.ironpath.backend.shared.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class AesGcmCipherServiceTest {

    private AesGcmCipherService cipherService;

    @BeforeEach
    void setUp() {
        cipherService = new AesGcmCipherService();
        // Clé AES-256 valide encodée en base64, utilisée uniquement pour les tests
        ReflectionTestUtils.setField(cipherService, "base64Key", "MPuCrz059TbgyQbOsZ7K5THQTmfuNBC6aUVWKssScA0=");
    }

    @Test
    void encryptThenDecrypt_shouldReturnOriginalValue() {
        String plainText = "78.5";

        String encrypted = cipherService.encrypt(plainText);
        String decrypted = cipherService.decrypt(encrypted);

        assertEquals(plainText, decrypted);
    }

    @Test
    void encrypt_shouldReturnNull_whenInputIsNull() {
        assertNull(cipherService.encrypt(null));
    }

    @Test
    void decrypt_shouldReturnNull_whenInputIsNull() {
        assertNull(cipherService.decrypt(null));
    }

    @Test
    void encrypt_shouldProduceDifferentCipherText_forSamePlainText() {
        String plainText = "78.5";

        String first = cipherService.encrypt(plainText);
        String second = cipherService.encrypt(plainText);

        assertNotEquals(first, second, "L'IV aléatoire doit rendre chaque chiffrement unique");
    }

    @Test
    void decrypt_shouldThrowException_whenCipherTextIsCorrupted() {
        String encrypted = cipherService.encrypt("78.5");
        String corrupted = encrypted.substring(0, encrypted.length() - 4) + "abcd";

        assertThrows(IllegalStateException.class, () -> cipherService.decrypt(corrupted));
    }

    @Test
    void decrypt_shouldThrowException_whenValueIsTooShortToContainIv() {
        String tooShort = java.util.Base64.getEncoder().encodeToString(new byte[]{1, 2, 3});

        assertThrows(IllegalStateException.class, () -> cipherService.decrypt(tooShort));
    }

    @Test
    void encryptThenDecrypt_shouldHandleEmptyString() {
        String encrypted = cipherService.encrypt("");
        assertTrue(cipherService.decrypt(encrypted).isEmpty());
    }
}
