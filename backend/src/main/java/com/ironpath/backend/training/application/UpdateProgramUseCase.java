package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.CreateProgramRequest;
import com.ironpath.backend.training.api.dto.ProgramExerciseRequest;
import com.ironpath.backend.training.api.dto.ProgramExerciseSetRequest;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.ProgramExerciseSet;
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
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public ProgramResponse execute(UUID userId, UUID programId, CreateProgramRequest request) {
        WorkoutProgram program = programRepository.findById(programId)
                .orElseThrow(() -> new IllegalArgumentException("Programme introuvable"));

        if (!program.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Ce programme ne vous appartient pas");
        }
        emailVerificationGuard.check(program.getUser());

        if (request.name() != null) {
            program.setName(request.name());
        }
        if (request.description() != null) {
            program.setDescription(request.description());
        }

        if (request.exercises() != null) {
            if (request.exercises().isEmpty()) {
                throw new IllegalArgumentException("Au moins un exercice est requis");
            }
            program.getExercises().clear();
            List<ProgramExercise> exercises = new ArrayList<>();
            for (ProgramExerciseRequest exerciseRequest : request.exercises()) {
                if (exerciseRequest.sets() == null || exerciseRequest.sets().isEmpty()) {
                    throw new IllegalArgumentException("Au moins une série est requise par exercice");
                }
                ProgramExercise exercise = ProgramExercise.builder()
                        .program(program)
                        .exerciseId(exerciseRequest.exerciseId())
                        .exerciseOrder(exerciseRequest.exerciseOrder())
                        .sameConfigForAllSets(exerciseRequest.sameConfigForAllSets())
                        .build();
                exercise.setSets(toSets(exerciseRequest.sets(), exercise));
                exercises.add(exercise);
            }
            program.getExercises().addAll(exercises);
        }

        WorkoutProgram savedProgram = programRepository.save(program);
        return programMapper.toResponse(savedProgram);
    }

    private List<ProgramExerciseSet> toSets(List<ProgramExerciseSetRequest> requests, ProgramExercise exercise) {
        List<ProgramExerciseSet> sets = new ArrayList<>();
        for (ProgramExerciseSetRequest setRequest : requests) {
            sets.add(ProgramExerciseSet.builder()
                    .programExercise(exercise)
                    .setOrder(setRequest.setOrder())
                    .targetReps(setRequest.targetReps())
                    .targetWeightKg(setRequest.targetWeightKg())
                    .restSeconds(setRequest.restSeconds())
                    .build());
        }
        return sets;
    }
}