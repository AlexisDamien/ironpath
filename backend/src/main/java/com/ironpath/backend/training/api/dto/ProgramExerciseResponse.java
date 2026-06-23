package com.ironpath.backend.training.api.dto;

import java.util.UUID;

public record ProgramExerciseResponse(
        UUID id,
        String exerciseId,
        Integer exerciseOrder,
        Integer targetSets,
        Integer targetReps,
        Double targetWeightKg,
        Integer restSeconds
) {}