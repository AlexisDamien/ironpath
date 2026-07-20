package com.ironpath.backend.training.api.dto;

public record ExerciseResponse(
        String id,
        String name,
        String muscleGroup,
        String equipment,
        String description
) {}