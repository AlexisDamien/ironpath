package com.ironpath.backend.training.api.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record ProgramResponse(
        UUID id,
        String name,
        String description,
        Boolean isActive,
        List<ProgramExerciseResponse> exercises,
        LocalDateTime createdAt
) {}