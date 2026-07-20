package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdatePasswordRequest(

        @NotBlank(message = "Mot de passe actuel obligatoire")
        String currentPassword,

        @NotBlank(message = "Nouveau mot de passe obligatoire")
        @Size(min = 12, message = "Mot de passe minimum 12 caractères")
        String newPassword
) {}