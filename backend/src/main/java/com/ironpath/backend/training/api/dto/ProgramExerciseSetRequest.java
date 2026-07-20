package com.ironpath.backend.training.api.dto;

public record ProgramExerciseSetRequest(
        Integer setOrder,
        Integer targetReps,
        Double targetWeightKg,
        Integer restSeconds,
        Boolean isWarmup
) {}