package com.ironpath.backend.training.api.dto;

import java.util.List;
import java.util.UUID;

public record SessionPlannedExerciseResponse(
        UUID id,
        String exerciseId,
        Integer exerciseOrder,
        List<SessionPlannedSetResponse> sets
) {}