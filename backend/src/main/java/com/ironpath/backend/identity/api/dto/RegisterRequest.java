package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(

        @NotBlank(message = "Email obligatoire")
        @Email(message = "Format email invalide")
        String email,

        @NotBlank(message = "Mot de passe obligatoire")
        @Size(min = 8, message = "Mot de passe minimum 8 caractères")
        String password,

        @AssertTrue (message = "Consentement RGPD obligatoire")
        boolean rgpdConsent
) {}