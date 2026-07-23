package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import com.ironpath.backend.training.api.dto.AddSetRequest;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AddSetUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final SessionMapper sessionMapper;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public SessionResponse execute(
            UUID userId,
            UUID sessionId,
            AddSetRequest request
    ) {
        TrainingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Session introuvable")
                );

        if (!session.getUser().getId().equals(userId)) {
            throw new ForbiddenException(
                    "Cette session ne vous appartient pas"
            );
        }

        emailVerificationGuard.check(session.getUser());

        if (!"IN_PROGRESS".equals(session.getStatus())) {
            throw new IllegalArgumentException(
                    "La session est déjà terminée"
            );
        }

        boolean isWarmup = request.isWarmup() != null && request.isWarmup();

        Optional<ExerciseSet> existingSet = session.getSets().stream()
                .filter(set ->
                        set.getExerciseId().equals(request.exerciseId())
                                && set.getSetOrder().equals(request.setOrder())
                )
                .findFirst();

        if (existingSet.isPresent()) {
            ExerciseSet set = existingSet.get();
            set.setReps(request.reps());
            set.setWeightKg(request.weightKg());
            set.setRestSeconds(request.restSeconds());
            set.setIsWarmup(isWarmup);
        } else {
            ExerciseSet set = ExerciseSet.builder()
                    .session(session)
                    .exerciseId(request.exerciseId())
                    .setOrder(request.setOrder())
                    .reps(request.reps())
                    .weightKg(request.weightKg())
                    .restSeconds(request.restSeconds())
                    .isWarmup(isWarmup)
                    .build();

            session.getSets().add(set);
        }

        TrainingSession savedSession = sessionRepository.save(session);

        return sessionMapper.toResponse(savedSession);
    }
}