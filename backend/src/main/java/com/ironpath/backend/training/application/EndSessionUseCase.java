package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EndSessionUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final SessionMapper sessionMapper;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public SessionResponse execute(UUID userId, UUID sessionId) {
        TrainingSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Session introuvable"));

        if (!session.getUser().getId().equals(userId)) {
            throw new ForbiddenException("Cette session ne vous appartient pas");
        }
        emailVerificationGuard.check(session.getUser());

        if (!"IN_PROGRESS".equals(session.getStatus())) {
            throw new IllegalArgumentException("La session est déjà terminée");
        }

        session.setStatus("COMPLETED");
        session.setEndedAt(LocalDateTime.now());

        TrainingSession savedSession = sessionRepository.save(session);
        return sessionMapper.toResponse(savedSession);
    }
}