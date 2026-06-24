package com.ironpath.backend.training.api.dto;

import java.time.LocalDateTime;

public record ExerciseStatsResponse(
        String exerciseId,
        Double lastWeightKg,
        Integer lastReps,
        LocalDateTime lastPerformedAt,
        Double estimatedOneRepMax,
        LocalDateTime oneRepMaxCalculatedAt
) {}