package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.StartSessionRequest;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.ProgramExerciseSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
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

    @Test
    void execute_shouldThrowException_whenActiveSessionAlreadyExists() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        StartSessionRequest request = new StartSessionRequest(null, "Session libre");

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.existsByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(true);

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () ->
                startSessionUseCase.execute(userId, request)
        );
        assertEquals("Une session est déjà en cours", exception.getMessage());
        verify(sessionRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowException_whenProgramNotFound() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        StartSessionRequest request = new StartSessionRequest(programId, null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.existsByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(false);
        when(programRepository.findById(programId)).thenReturn(Optional.empty());

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () ->
                startSessionUseCase.execute(userId, request)
        );
        assertEquals("Programme introuvable", exception.getMessage());
        verify(sessionRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowForbidden_whenProgramBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        User owner = User.builder().id(ownerId).build();
        WorkoutProgram program = WorkoutProgram.builder().id(programId).user(owner).name("PPL").build();
        StartSessionRequest request = new StartSessionRequest(programId, null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.existsByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(false);
        when(programRepository.findById(programId)).thenReturn(Optional.of(program));

        ForbiddenException exception = assertThrows(ForbiddenException.class, () ->
                startSessionUseCase.execute(userId, request)
        );
        assertEquals("Ce programme ne vous appartient pas", exception.getMessage());
        verify(sessionRepository, never()).save(any());
    }

    @Test
    void execute_shouldKeepProvidedName_whenNameAndProgramIdBothProvided() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        WorkoutProgram program = WorkoutProgram.builder().id(programId).user(user).name("PPL").build();
        StartSessionRequest request = new StartSessionRequest(programId, "Nom personnalisé");

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.existsByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(false);
        when(programRepository.findById(programId)).thenReturn(Optional.of(program));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(UUID.randomUUID(), "Nom personnalisé", "IN_PROGRESS", programId, List.of(), List.of(), null, null));

        ArgumentCaptor<TrainingSession> captor = ArgumentCaptor.forClass(TrainingSession.class);

        startSessionUseCase.execute(userId, request);

        verify(sessionRepository, atLeastOnce()).save(captor.capture());
        assertEquals("Nom personnalisé", captor.getValue().getName());
    }

    @Test
    void execute_shouldSnapshotProgramExercisesAndSets_whenProgramHasExercises() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        ProgramExerciseSet programSet = ProgramExerciseSet.builder()
                .setOrder(1).targetReps(8).targetWeightKg(80.0).restSeconds(120).isWarmup(false).build();
        ProgramExercise programExercise = ProgramExercise.builder()
                .exerciseId("0001").exerciseOrder(1).sameConfigForAllSets(true)
                .sets(List.of(programSet)).build();
        WorkoutProgram program = WorkoutProgram.builder()
                .id(programId).user(user).name("PPL").exercises(List.of(programExercise)).build();

        StartSessionRequest request = new StartSessionRequest(programId, null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(sessionRepository.existsByUserIdAndStatus(userId, "IN_PROGRESS")).thenReturn(false);
        when(programRepository.findById(programId)).thenReturn(Optional.of(program));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(UUID.randomUUID(), "PPL", "IN_PROGRESS", programId, List.of(), List.of(), null, null));

        ArgumentCaptor<TrainingSession> captor = ArgumentCaptor.forClass(TrainingSession.class);

        startSessionUseCase.execute(userId, request);

        verify(sessionRepository, times(2)).save(captor.capture());
        TrainingSession finalSession = captor.getAllValues().get(1);

        assertEquals(1, finalSession.getPlannedExercises().size());
        assertEquals("0001", finalSession.getPlannedExercises().getFirst().getExerciseId());
        assertEquals(1, finalSession.getPlannedExercises().getFirst().getSets().size());
        assertEquals(8, finalSession.getPlannedExercises().getFirst().getSets().getFirst().getTargetReps());
    }
}