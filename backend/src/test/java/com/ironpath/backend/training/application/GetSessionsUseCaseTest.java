package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetSessionsUseCaseTest {

    @Mock
    private TrainingSessionRepository sessionRepository;

    @Mock
    private SessionMapper sessionMapper;

    @InjectMocks
    private GetSessionsUseCase getSessionsUseCase;

    @Test
    void execute_shouldReturnCompletedSessions_excludingInProgress() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder().id(UUID.randomUUID()).user(user).status("COMPLETED").build();
        SessionResponse expectedResponse = new SessionResponse(session.getId(), null, "COMPLETED", null, List.of(), List.of(), null, null);

        when(sessionRepository.findByUserIdAndStatusNotOrderByStartedAtDesc(userId, "IN_PROGRESS"))
                .thenReturn(List.of(session));
        when(sessionMapper.toResponse(session)).thenReturn(expectedResponse);

        List<SessionResponse> responses = getSessionsUseCase.execute(userId);

        assertEquals(1, responses.size());
        assertEquals(expectedResponse, responses.getFirst());
    }

    @Test
    void execute_shouldReturnEmptyList_whenNoSessions() {
        UUID userId = UUID.randomUUID();

        when(sessionRepository.findByUserIdAndStatusNotOrderByStartedAtDesc(userId, "IN_PROGRESS"))
                .thenReturn(List.of());

        assertTrue(getSessionsUseCase.execute(userId).isEmpty());
    }

    @Test
    void getActiveSession_shouldReturnSession_whenInProgressSessionExists() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder().id(UUID.randomUUID()).user(user).status("IN_PROGRESS").build();
        SessionResponse expectedResponse = new SessionResponse(session.getId(), null, "IN_PROGRESS", null, List.of(), List.of(), null, null);

        when(sessionRepository.findByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(Optional.of(session));
        when(sessionMapper.toResponse(session)).thenReturn(expectedResponse);

        Optional<SessionResponse> response = getSessionsUseCase.getActiveSession(userId);

        assertTrue(response.isPresent());
        assertEquals("IN_PROGRESS", response.get().status());
    }

    @Test
    void getActiveSession_shouldReturnEmpty_whenNoActiveSession() {
        UUID userId = UUID.randomUUID();

        when(sessionRepository.findByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(Optional.empty());

        assertFalse(getSessionsUseCase.getActiveSession(userId).isPresent());
    }
}
