package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EndSessionUseCaseTest {

    @Mock
    private TrainingSessionRepository sessionRepository;

    @Mock
    private SessionMapper sessionMapper;

    @InjectMocks
    private EndSessionUseCase endSessionUseCase;

    @Test
    void execute_shouldEndSession_whenOwnerRequests() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("IN_PROGRESS")
                .sets(new ArrayList<>())
                .build();

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(sessionId, null, "COMPLETED", null, null, null, null));

        endSessionUseCase.execute(userId, sessionId);

        verify(sessionRepository).save(any(TrainingSession.class));
    }

    @Test
    void execute_shouldThrowException_whenSessionNotFound() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                endSessionUseCase.execute(userId, sessionId)
        );
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenNotOwner() {
        UUID userId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User otherUser = User.builder().id(otherUserId).build();
        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(otherUser)
                .status("IN_PROGRESS")
                .sets(new ArrayList<>())
                .build();

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

        assertThrows(UnauthorizedException.class, () ->
                endSessionUseCase.execute(userId, sessionId)
        );
    }

    @Test
    void execute_shouldThrowException_whenSessionAlreadyCompleted() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("COMPLETED")
                .sets(new ArrayList<>())
                .build();

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                endSessionUseCase.execute(userId, sessionId)
        );
    }
}