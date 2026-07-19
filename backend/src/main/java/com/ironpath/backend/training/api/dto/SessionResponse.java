package com.ironpath.backend.training.api.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record SessionResponse(
        UUID id,
        String name,
        String status,
        UUID programId,
        List<SetResponse> sets,
        List<SessionPlannedExerciseResponse> plannedExercises,
        LocalDateTime startedAt,
        LocalDateTime endedAt
) {}