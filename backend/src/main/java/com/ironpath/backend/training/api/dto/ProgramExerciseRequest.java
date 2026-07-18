package com.ironpath.backend.training.api.dto;

import java.util.List;

public record ProgramExerciseRequest(
        String exerciseId,
        Integer exerciseOrder,
        Boolean sameConfigForAllSets,
        List<ProgramExerciseSetRequest> sets
) {}