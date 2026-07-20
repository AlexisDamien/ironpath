package com.ironpath.backend.identity.application;

import java.util.regex.Pattern;

public final class PasswordPolicy {

    public static final int MIN_LENGTH = 12;

    private static final Pattern UPPERCASE = Pattern.compile("[A-Z]");
    private static final Pattern LOWERCASE = Pattern.compile("[a-z]");
    private static final Pattern DIGIT = Pattern.compile("[0-9]");
    private static final Pattern SPECIAL = Pattern.compile(
            "[!@#$%^&*(),.?\":{}|<>]"
    );

    private PasswordPolicy() {
    }

    public static String validate(String password) {
        if (password == null || password.isEmpty()) {
            return "Le mot de passe est obligatoire.";
        }
        if (password.length() < MIN_LENGTH) {
            return "Utilisez au moins 12 caractères.";
        }
        if (!UPPERCASE.matcher(password).find()) {
            return "Ajoutez au moins une majuscule.";
        }
        if (!LOWERCASE.matcher(password).find()) {
            return "Ajoutez au moins une minuscule.";
        }
        if (!DIGIT.matcher(password).find()) {
            return "Ajoutez au moins un chiffre.";
        }
        if (!SPECIAL.matcher(password).find()) {
            return "Ajoutez au moins un caractère spécial.";
        }
        return null;
    }

    public static void validateOrThrow(String password) {
        String validationError = validate(password);
        if (validationError != null) {
            throw new IllegalArgumentException(validationError);
        }
    }
}
