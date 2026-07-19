package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.training.api.dto.ExerciseStatsResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.OneRepMax;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.repository.OneRepMaxRepository;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetExerciseStatsUseCaseTest {

    @Mock
    private TrainingSessionRepository sessionRepository;

    @Mock
    private OneRepMaxRepository oneRepMaxRepository;

    @InjectMocks
    private GetExerciseStatsUseCase getExerciseStatsUseCase;

    private TrainingSession completedSessionWithSet(User user, ExerciseSet set, LocalDateTime startedAt) {
        TrainingSession session = TrainingSession.builder()
                .id(UUID.randomUUID()).user(user).status("COMPLETED")
                .startedAt(startedAt).sets(List.of(set)).build();
        set.setSession(session);
        return session;
    }

    @Test
    void execute_shouldReturnEmptyStats_whenNoDataAvailable() {
        UUID userId = UUID.randomUUID();

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of());
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.empty());

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertEquals("0001", response.exerciseId());
        assertNull(response.lastWeightKg());
        assertNull(response.lastReps());
        assertNull(response.estimatedOneRepMax());
    }

    @Test
    void execute_shouldReturnLastSetAndCalculatedOrm_whenNoStoredOneRepMax() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        LocalDateTime startedAt = LocalDateTime.now().minusDays(1);

        ExerciseSet set = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(8).weightKg(100.0).isWarmup(false).build();
        TrainingSession session = completedSessionWithSet(user, set, startedAt);

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of(session));
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.empty());

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertEquals(100.0, response.lastWeightKg());
        assertEquals(8, response.lastReps());
        assertEquals(startedAt, response.lastPerformedAt());
        assertEquals(126.7, response.estimatedOneRepMax());
    }

    @Test
    void execute_shouldUseStoredOneRepMax_whenAvailable() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        LocalDateTime startedAt = LocalDateTime.now().minusDays(1);
        LocalDateTime calculatedAt = LocalDateTime.now();

        ExerciseSet set = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(8).weightKg(100.0).isWarmup(false).build();
        TrainingSession session = completedSessionWithSet(user, set, startedAt);

        OneRepMax storedOrm = OneRepMax.builder()
                .user(user).exerciseId("0001").weightKg(140.0)
                .calculatedAt(calculatedAt).formula("epley").build();

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of(session));
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.of(storedOrm));

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertEquals(140.0, response.estimatedOneRepMax());
        assertEquals(calculatedAt, response.oneRepMaxCalculatedAt());
    }

    @Test
    void execute_shouldIgnoreWarmupSets_andSetsFromOtherExercises() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();

        ExerciseSet warmupSet = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(15).weightKg(40.0).isWarmup(true).build();
        ExerciseSet otherExerciseSet = ExerciseSet.builder()
                .exerciseId("0002").setOrder(2).reps(10).weightKg(60.0).isWarmup(false).build();

        TrainingSession session = TrainingSession.builder()
                .id(UUID.randomUUID()).user(user).status("COMPLETED")
                .startedAt(LocalDateTime.now())
                .sets(List.of(warmupSet, otherExerciseSet)).build();
        warmupSet.setSession(session);
        otherExerciseSet.setSession(session);

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of(session));
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.empty());

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertNull(response.lastWeightKg());
        assertNull(response.lastReps());
    }

    @Test
    void execute_shouldPickMostRecentSet_whenMultipleCompletedSetsExist() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();

        ExerciseSet olderSet = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(10).weightKg(90.0).isWarmup(false).build();
        TrainingSession olderSession = completedSessionWithSet(user, olderSet, LocalDateTime.now().minusDays(10));

        ExerciseSet recentSet = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(6).weightKg(110.0).isWarmup(false).build();
        TrainingSession recentSession = completedSessionWithSet(user, recentSet, LocalDateTime.now().minusDays(1));

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId))
                .thenReturn(List.of(recentSession, olderSession));
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.empty());

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertEquals(110.0, response.lastWeightKg());
        assertEquals(6, response.lastReps());
    }

    @Test
    void execute_shouldReturnStoredOneRepMax_whenNoCompletedSetExistsYet() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        LocalDateTime calculatedAt = LocalDateTime.now();

        OneRepMax storedOrm = OneRepMax.builder()
                .user(user).exerciseId("0001").weightKg(120.0)
                .calculatedAt(calculatedAt).formula("epley").build();

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of());
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.of(storedOrm));

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertNull(response.lastWeightKg());
        assertNull(response.lastReps());
        assertNull(response.lastPerformedAt());
        assertEquals(120.0, response.estimatedOneRepMax());
        assertEquals(calculatedAt, response.oneRepMaxCalculatedAt());
    }

    @Test
    void execute_shouldIgnoreSessionsNotCompleted() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();

        ExerciseSet set = ExerciseSet.builder()
                .exerciseId("0001").setOrder(1).reps(8).weightKg(100.0).isWarmup(false).build();
        TrainingSession inProgressSession = TrainingSession.builder()
                .id(UUID.randomUUID()).user(user).status("IN_PROGRESS")
                .startedAt(LocalDateTime.now()).sets(List.of(set)).build();
        set.setSession(inProgressSession);

        when(sessionRepository.findByUserIdOrderByStartedAtDesc(userId)).thenReturn(List.of(inProgressSession));
        when(oneRepMaxRepository.findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(userId, "0001"))
                .thenReturn(Optional.empty());

        ExerciseStatsResponse response = getExerciseStatsUseCase.execute(userId, "0001");

        assertNull(response.lastWeightKg());
    }
}
