package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record UpdateEmailRequest(

        @NotBlank(message = "Mot de passe actuel obligatoire")
        String currentPassword,

        @NotBlank(message = "Nouvel email obligatoire")
        @Email(message = "Format email invalide")
        String newEmail
) {}