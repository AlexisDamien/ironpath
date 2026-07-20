package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.repository.UserRepository;
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
public class CreateProgramUseCase {

    private final WorkoutProgramRepository programRepository;
    private final UserRepository userRepository;
    private final ProgramMapper programMapper;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public ProgramResponse execute(UUID userId, CreateProgramRequest request) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));
        emailVerificationGuard.check(user);

        if (request.exercises() == null || request.exercises().isEmpty()) {
            throw new IllegalArgumentException("Au moins un exercice est requis");
        }

        WorkoutProgram program = WorkoutProgram.builder()
                .user(user)
                .name(request.name())
                .description(request.description())
                .build();

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
        program.setExercises(exercises);

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
                    .isWarmup(setRequest.isWarmup() != null && setRequest.isWarmup())
                    .build());
        }
        return sets;
    }
}