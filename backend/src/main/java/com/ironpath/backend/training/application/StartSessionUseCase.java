package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.StartSessionRequest;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StartSessionUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final UserRepository userRepository;
    private final WorkoutProgramRepository programRepository;
    private final SessionMapper sessionMapper;

    @Transactional
    public SessionResponse execute(UUID userId, StartSessionRequest request) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));
        boolean hasActiveSession = sessionRepository
                .existsByUserIdAndStatus(userId, "IN_PROGRESS");
        if (hasActiveSession) {
            throw new IllegalArgumentException("Une session est déjà en cours");
        }
        TrainingSession.TrainingSessionBuilder sessionBuilder = TrainingSession.builder()
                .user(user)
                .name(request.name());

        if (request.programId() != null) {
            var program = programRepository.findById(request.programId())
                    .orElseThrow(() -> new IllegalArgumentException("Programme introuvable"));

            if (!program.getUser().getId().equals(userId)) {
                throw new UnauthorizedException("Ce programme ne vous appartient pas");
            }

            sessionBuilder.program(program);

            if (request.name() == null) {
                sessionBuilder.name(program.getName());
            }
        }

        TrainingSession session = sessionRepository.save(sessionBuilder.build());
        return sessionMapper.toResponse(session);
    }
}