package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.NotBlank;

public record DeleteAccountRequest(

        @NotBlank(message = "Mot de passe obligatoire")
        String currentPassword
) {}