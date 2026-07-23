package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.StartSessionRequest;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.ProgramExerciseSet;
import com.ironpath.backend.training.domain.model.SessionPlannedExercise;
import com.ironpath.backend.training.domain.model.SessionPlannedSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StartSessionUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final WorkoutProgramRepository programRepository;
    private final SessionMapper sessionMapper;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public SessionResponse execute(UUID userId, StartSessionRequest request) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));
        emailVerificationGuard.check(user);
        boolean hasActiveSession = sessionRepository
                .existsByUserIdAndStatus(userId, "IN_PROGRESS");
        if (hasActiveSession) {
            throw new IllegalArgumentException("Une session est déjà en cours");
        }

        TrainingSession.TrainingSessionBuilder sessionBuilder = TrainingSession.builder()
                .user(user)
                .name(request.name());

        WorkoutProgram program = null;
        if (request.programId() != null) {
            program = programRepository.findById(request.programId())
                    .orElseThrow(() -> new IllegalArgumentException("Programme introuvable"));

            if (!program.getUser().getId().equals(userId)) {
                throw new ForbiddenException("Ce programme ne vous appartient pas");
            }

            sessionBuilder.program(program);

            if (request.name() == null) {
                sessionBuilder.name(program.getName());
            }
        }

        TrainingSession session = sessionRepository.save(sessionBuilder.build());

        if (program != null) {
            session.setPlannedExercises(snapshotProgramExercises(program, session));
            session = sessionRepository.save(session);
        }

        return sessionMapper.toResponse(session);
    }

    private List<SessionPlannedExercise> snapshotProgramExercises(
            WorkoutProgram program, TrainingSession session) {
        List<SessionPlannedExercise> plannedExercises = new ArrayList<>();

        for (ProgramExercise programExercise : program.getExercises()) {
            SessionPlannedExercise plannedExercise = SessionPlannedExercise.builder()
                    .session(session)
                    .exerciseId(programExercise.getExerciseId())
                    .exerciseOrder(programExercise.getExerciseOrder())
                    .build();

            List<SessionPlannedSet> plannedSets = new ArrayList<>();
            for (ProgramExerciseSet programSet : programExercise.getSets()) {
                plannedSets.add(SessionPlannedSet.builder()
                        .plannedExercise(plannedExercise)
                        .setOrder(programSet.getSetOrder())
                        .targetReps(programSet.getTargetReps())
                        .targetWeightKg(programSet.getTargetWeightKg())
                        .restSeconds(programSet.getRestSeconds())
                        .isWarmup(programSet.getIsWarmup())
                        .build());
            }
            plannedExercise.setSets(plannedSets);
            plannedExercises.add(plannedExercise);
        }

        return plannedExercises;
    }
}