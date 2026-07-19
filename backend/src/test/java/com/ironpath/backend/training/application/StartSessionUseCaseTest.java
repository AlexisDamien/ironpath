package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.StartSessionRequest;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StartSessionUseCaseTest {

    @Mock
    private TrainingSessionRepository sessionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private WorkoutProgramRepository programRepository;

    @Mock
    private SessionMapper sessionMapper;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private StartSessionUseCase startSessionUseCase;

    @Test
    void execute_shouldStartFreeSession_whenNoProgramProvided() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        StartSessionRequest request = new StartSessionRequest(null, "Session libre");

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(UUID.randomUUID(), "Session libre", "IN_PROGRESS", null, null, List.of(), null, null));
        SessionResponse response = startSessionUseCase.execute(userId, request);

        assertNotNull(response);
    }

    @Test
    void execute_shouldStartSessionFromProgram_whenProgramIdProvided() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        WorkoutProgram program = WorkoutProgram.builder()
                .id(programId)
                .user(user)
                .name("PPL")
                .build();
        StartSessionRequest request = new StartSessionRequest(programId, null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(programRepository.findById(programId)).thenReturn(Optional.of(program));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(UUID.randomUUID(), "PPL", "IN_PROGRESS", programId, null, List.of(), null, null));
        SessionResponse response = startSessionUseCase.execute(userId, request);

        assertNotNull(response);
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenUserNotFound() {
        UUID userId = UUID.randomUUID();
        StartSessionRequest request = new StartSessionRequest(null, "Session libre");

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                startSessionUseCase.execute(userId, request)
        );
    }
}