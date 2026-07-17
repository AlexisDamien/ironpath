package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
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
        WorkoutProgram program = WorkoutProgram.builder()
                .user(user)
                .name(request.name())
                .description(request.description())
                .build();

        if (request.exercises() != null) {
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
            program.setExercises(exercises);
        }

        WorkoutProgram savedProgram = programRepository.save(program);
        return programMapper.toResponse(savedProgram);
    }
}