package com.ironpath.backend.identity.application;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.NullAndEmptySource;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

class PasswordPolicyTest {

    private static final String VALID_PASSWORD = "Str0ng!Passw0rd";

    @ParameterizedTest
    @NullAndEmptySource
    void validate_shouldReturnError_whenPasswordIsNullOrEmpty(String password) {
        assertEquals("Le mot de passe est obligatoire.", PasswordPolicy.validate(password));
    }

    @Test
    void validate_shouldReturnError_whenTooShort() {
        assertEquals(
                "Utilisez au moins 12 caractères.",
                PasswordPolicy.validate("Sh0rt!Aa")
        );
    }

    @Test
    void validate_shouldReturnError_whenMissingUppercase() {
        assertEquals(
                "Ajoutez au moins une majuscule.",
                PasswordPolicy.validate("str0ng!passw0rd")
        );
    }

    @Test
    void validate_shouldReturnError_whenMissingLowercase() {
        assertEquals(
                "Ajoutez au moins une minuscule.",
                PasswordPolicy.validate("STR0NG!PASSW0RD")
        );
    }

    @Test
    void validate_shouldReturnError_whenMissingDigit() {
        assertEquals(
                "Ajoutez au moins un chiffre.",
                PasswordPolicy.validate("Strong!Password")
        );
    }

    @Test
    void validate_shouldReturnError_whenMissingSpecialCharacter() {
        assertEquals(
                "Ajoutez au moins un caractère spécial.",
                PasswordPolicy.validate("Str0ngPassword")
        );
    }

    @ParameterizedTest
    @ValueSource(strings = {
            VALID_PASSWORD,
            "An0ther#ValidOne",
            "C0mplex.Pass-word"
    })
    void validate_shouldReturnNull_whenPasswordIsValid(String password) {
        assertNull(PasswordPolicy.validate(password));
    }

    @Test
    void validateOrThrow_shouldNotThrow_whenPasswordIsValid() {
        PasswordPolicy.validateOrThrow(VALID_PASSWORD);
    }

    @Test
    void validateOrThrow_shouldThrowIllegalArgumentException_whenPasswordIsInvalid() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> PasswordPolicy.validateOrThrow("weak")
        );

        assertEquals("Utilisez au moins 12 caractères.", exception.getMessage());
    }
}
