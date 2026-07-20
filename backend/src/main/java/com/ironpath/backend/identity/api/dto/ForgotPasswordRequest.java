package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record ForgotPasswordRequest(

        @NotBlank(message = "Email obligatoire")
        @Email(message = "Format email invalide")
        String email
) {}
