package com.ironpath.backend.training.api.dto;

import java.util.UUID;

public record SetResponse(
        UUID id,
        String exerciseId,
        Integer setOrder,
        Integer reps,
        Double weightKg,
        Integer restSeconds,
        Boolean isWarmup
) {}