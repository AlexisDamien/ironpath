package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.CreateProgramRequest;
import com.ironpath.backend.training.api.dto.ProgramExerciseRequest;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdateProgramUseCase {

    private final WorkoutProgramRepository programRepository;
    private final ProgramMapper programMapper;

    @Transactional
    public ProgramResponse execute(UUID userId, UUID programId, CreateProgramRequest request) {
        WorkoutProgram program = programRepository.findById(programId)
                .orElseThrow(() -> new IllegalArgumentException("Programme introuvable"));

        if (!program.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Ce programme ne vous appartient pas");
        }

        if (request.name() != null) {
            program.setName(request.name());
        }
        if (request.description() != null) {
            program.setDescription(request.description());
        }

        if (request.exercises() != null) {
            program.getExercises().clear();
            List<ProgramExercise> exercises = new ArrayList<>();
            for (ProgramExerciseRequest exerciseRequest : request.exercises()) {
                ProgramExercise exercise = ProgramExercise.builder()
                        .program(program)
                        .exerciseId(exerciseRequest.exerciseId())
                        .exerciseOrder(exerciseRequest.exerciseOrder())
                        .targetSets(exerciseRequest.targetSets())
                        .targetReps(exerciseRequest.targetReps())
                        .targetWeightKg(exerciseRequest.targetWeightKg())
                        .restSeconds(exerciseRequest.restSeconds())
                        .build();
                exercises.add(exercise);
            }
            program.getExercises().addAll(exercises);
        }

        WorkoutProgram savedProgram = programRepository.save(program);
        return programMapper.toResponse(savedProgram);
    }
}