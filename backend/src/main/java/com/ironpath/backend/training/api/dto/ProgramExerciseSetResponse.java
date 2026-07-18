package com.ironpath.backend.training.api.dto;

import java.util.UUID;

public record ProgramExerciseSetResponse(
        UUID id,
        Integer setOrder,
        Integer targetReps,
        Double targetWeightKg,
        Integer restSeconds
) {}