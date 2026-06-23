package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.ProgramExerciseResponse;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.ProgramExercise;
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
        return new ProgramExerciseResponse(
                exercise.getId(),
                exercise.getExerciseId(),
                exercise.getExerciseOrder(),
                exercise.getTargetSets(),
                exercise.getTargetReps(),
                exercise.getTargetWeightKg(),
                exercise.getRestSeconds()
        );
    }
}