package com.ironpath.backend.identity.api.dto;

public record LoginResponse(String token, String refreshToken, boolean emailVerified) {}