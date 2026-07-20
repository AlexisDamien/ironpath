package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(

        @NotBlank(message = "Jeton de réinitialisation obligatoire")
        String token,

        @NotBlank(message = "Nouveau mot de passe obligatoire")
        @Size(min = 12, message = "Mot de passe minimum 12 caractères")
        String newPassword
) {}
