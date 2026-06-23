package com.ironpath.backend.training.api.dto;

public record ProgramExerciseRequest(
        String exerciseId,
        Integer exerciseOrder,
        Integer targetSets,
        Integer targetReps,
        Double targetWeightKg,
        Integer restSeconds
) {}