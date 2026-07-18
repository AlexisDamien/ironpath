package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.ProgramExerciseResponse;
import com.ironpath.backend.training.api.dto.ProgramExerciseSetResponse;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.ProgramExerciseSet;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class ProgramMapper {

    public ProgramResponse toResponse(WorkoutProgram program) {
        List<ProgramExerciseResponse> exerciseResponses = program.getExercises()
                .stream()
                .map(this::toExerciseResponse)
                .toList();

        return new ProgramResponse(
                program.getId(),
                program.getName(),
                program.getDescription(),
                program.getIsActive(),
                exerciseResponses,
                program.getCreatedAt()
        );
    }

    private ProgramExerciseResponse toExerciseResponse(ProgramExercise exercise) {
        List<ProgramExerciseSetResponse> setResponses = exercise.getSets()
                .stream()
                .map(this::toSetResponse)
                .toList();

        return new ProgramExerciseResponse(
                exercise.getId(),
                exercise.getExerciseId(),
                exercise.getExerciseOrder(),
                exercise.getSameConfigForAllSets(),
                setResponses
        );
    }

    private ProgramExerciseSetResponse toSetResponse(ProgramExerciseSet set) {
        return new ProgramExerciseSetResponse(
                set.getId(),
                set.getSetOrder(),
                set.getTargetReps(),
                set.getTargetWeightKg(),
                set.getRestSeconds()
        );
    }
}