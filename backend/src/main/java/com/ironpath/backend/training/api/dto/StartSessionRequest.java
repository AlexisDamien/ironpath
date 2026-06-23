package com.ironpath.backend.training.api.dto;

import java.util.UUID;

public record StartSessionRequest(
        UUID programId,
        String name
) {}