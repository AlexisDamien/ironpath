package com.ironpath.backend.shared.infrastructure;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

@Component
public class AesGcmCipherService {

    private static final String ALGORITHM = "AES/GCM/NoPadding";
    private static final String KEY_ALGORITHM = "AES";

    private static final int GCM_TAG_LENGTH_BITS = 128;
    private static final int GCM_IV_LENGTH_BYTES = 12;

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    @Value("${app.encryption.key}")
    private String base64Key;

    public String encrypt(String plainText) {
        if (plainText == null) {
            return null;
        }

        try {
            byte[] iv = new byte[GCM_IV_LENGTH_BYTES];
            SECURE_RANDOM.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(ALGORITHM);
            SecretKeySpec keySpec = createKeySpec();

            cipher.init(
                    Cipher.ENCRYPT_MODE,
                    keySpec,
                    new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv)
            );

            byte[] cipherText = cipher.doFinal(
                    plainText.getBytes(StandardCharsets.UTF_8)
            );

            byte[] combined = new byte[iv.length + cipherText.length];

            System.arraycopy(
                    iv,
                    0,
                    combined,
                    0,
                    iv.length
            );

            System.arraycopy(
                    cipherText,
                    0,
                    combined,
                    iv.length,
                    cipherText.length
            );

            return Base64.getEncoder().encodeToString(combined);
        } catch (Exception exception) {
            throw new IllegalStateException(
                    "Erreur de chiffrement",
                    exception
            );
        }
    }

    public String decrypt(String encoded) {
        if (encoded == null) {
            return null;
        }

        try {
            byte[] combined = Base64.getDecoder().decode(encoded);

            if (combined.length <= GCM_IV_LENGTH_BYTES) {
                throw new IllegalArgumentException(
                        "La valeur chiffrée est invalide"
                );
            }

            byte[] iv = new byte[GCM_IV_LENGTH_BYTES];

            System.arraycopy(
                    combined,
                    0,
                    iv,
                    0,
                    iv.length
            );

            byte[] cipherText =
                    new byte[combined.length - GCM_IV_LENGTH_BYTES];

            System.arraycopy(
                    combined,
                    GCM_IV_LENGTH_BYTES,
                    cipherText,
                    0,
                    cipherText.length
            );

            Cipher cipher = Cipher.getInstance(ALGORITHM);
            SecretKeySpec keySpec = createKeySpec();

            cipher.init(
                    Cipher.DECRYPT_MODE,
                    keySpec,
                    new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv)
            );

            byte[] plainText = cipher.doFinal(cipherText);

            return new String(
                    plainText,
                    StandardCharsets.UTF_8
            );
        } catch (Exception exception) {
            throw new IllegalStateException(
                    "Erreur de déchiffrement",
                    exception
            );
        }
    }

    private SecretKeySpec createKeySpec() {
        byte[] decodedKey = Base64.getDecoder().decode(base64Key);
        return new SecretKeySpec(decodedKey, KEY_ALGORITHM);
    }
}