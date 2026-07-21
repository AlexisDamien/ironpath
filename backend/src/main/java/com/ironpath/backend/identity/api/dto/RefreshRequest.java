package com.ironpath.backend.identity.api.dto;

import jakarta.validation.constraints.NotBlank;

public record RefreshRequest(@NotBlank(message = "Refresh token obligatoire") String refreshToken) {}