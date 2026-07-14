package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetSessionsUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final SessionMapper sessionMapper;

    @Transactional(readOnly = true)
    public List<SessionResponse> execute(UUID userId) {
        return sessionRepository.findByUserIdOrderByStartedAtDesc(userId)
                .stream()
                .map(sessionMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<SessionResponse> getActiveSession(UUID userId) {
        return sessionRepository
                .findByUserIdAndStatus(userId, "IN_PROGRESS")
                .map(sessionMapper::toResponse);
    }
}