package com.ironpath.backend.training.api.dto;

import java.util.List;
import java.util.UUID;

public record ProgramExerciseResponse(
        UUID id,
        String exerciseId,
        Integer exerciseOrder,
        Boolean sameConfigForAllSets,
        List<ProgramExerciseSetResponse> sets
) {}