package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import com.ironpath.backend.training.api.dto.AddSetRequest;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AddSetUseCaseTest {

    @Mock
    private TrainingSessionRepository sessionRepository;

    @Mock
    private SessionMapper sessionMapper;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private AddSetUseCase addSetUseCase;

    @Test
    void execute_shouldAddSet_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("IN_PROGRESS")
                .sets(new ArrayList<>())
                .build();

        AddSetRequest request = new AddSetRequest("0001", 1, 8, 80.0, 120, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(sessionId, null, "IN_PROGRESS", null, null, List.of(), null, null));

        addSetUseCase.execute(userId, sessionId, request);

        verify(sessionRepository).save(any(TrainingSession.class));
    }

    @Test
    void execute_shouldThrowException_whenSessionNotFound() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();
        AddSetRequest request = new AddSetRequest("0001", 1, 8, 80.0, 120, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                addSetUseCase.execute(userId, sessionId, request)
        );
    }

    @Test
    void execute_shouldThrowForbiddenException_whenNotOwner() {
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

        AddSetRequest request = new AddSetRequest("0001", 1, 8, 80.0, 120, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

        assertThrows(ForbiddenException.class, () ->
                addSetUseCase.execute(userId, sessionId, request)
        );
    }

    @Test
    void execute_shouldThrowException_whenSessionCompleted() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();
        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("COMPLETED")
                .sets(new ArrayList<>())
                .build();

        AddSetRequest request = new AddSetRequest("0001", 1, 8, 80.0, 120, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));

        assertThrows(IllegalArgumentException.class, () ->
                addSetUseCase.execute(userId, sessionId, request)
        );
    }

    @Test
    void execute_shouldUpdateExistingSet_whenSameExerciseAndSetOrder() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();

        ExerciseSet existingSet = ExerciseSet.builder()
                .id(UUID.randomUUID())
                .exerciseId("0001")
                .setOrder(1)
                .reps(8)
                .weightKg(80.0)
                .restSeconds(90)
                .isWarmup(false)
                .build();

        List<ExerciseSet> sets = new ArrayList<>();
        sets.add(existingSet);

        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("IN_PROGRESS")
                .sets(sets)
                .build();

        AddSetRequest request = new AddSetRequest("0001", 1, 10, 85.0, 120, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(sessionId, null, "IN_PROGRESS", null, null, List.of(), null, null));

        addSetUseCase.execute(userId, sessionId, request);

        assertEquals(1, session.getSets().size());
        ExerciseSet updatedSet = session.getSets().get(0);
        assertEquals(10, updatedSet.getReps());
        assertEquals(85.0, updatedSet.getWeightKg());
        assertEquals(120, updatedSet.getRestSeconds());
    }

    @Test
    void execute_shouldAddNewSet_whenDifferentSetOrderOnSameExercise() {
        UUID userId = UUID.randomUUID();
        UUID sessionId = UUID.randomUUID();

        User user = User.builder().id(userId).build();

        ExerciseSet existingSet = ExerciseSet.builder()
                .id(UUID.randomUUID())
                .exerciseId("0001")
                .setOrder(1)
                .reps(8)
                .weightKg(80.0)
                .isWarmup(false)
                .build();

        List<ExerciseSet> sets = new ArrayList<>();
        sets.add(existingSet);

        TrainingSession session = TrainingSession.builder()
                .id(sessionId)
                .user(user)
                .status("IN_PROGRESS")
                .sets(sets)
                .build();

        AddSetRequest request = new AddSetRequest("0001", 2, 8, 80.0, 90, false);

        when(sessionRepository.findById(sessionId)).thenReturn(Optional.of(session));
        when(sessionRepository.save(any(TrainingSession.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(sessionMapper.toResponse(any(TrainingSession.class)))
                .thenReturn(new SessionResponse(sessionId, null, "IN_PROGRESS", null, null, List.of(), null, null));

        addSetUseCase.execute(userId, sessionId, request);

        assertEquals(2, session.getSets().size());
    }
}