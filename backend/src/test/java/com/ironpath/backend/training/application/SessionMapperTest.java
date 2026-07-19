package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.SessionPlannedExercise;
import com.ironpath.backend.training.domain.model.SessionPlannedSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SessionMapperTest {

    private final SessionMapper sessionMapper = new SessionMapper();

    @Test
    void toResponse_shouldMapSessionWithSetsAndPlannedExercises() {
        WorkoutProgram program = WorkoutProgram.builder().id(UUID.randomUUID()).name("PPL").build();

        ExerciseSet set = ExerciseSet.builder()
                .id(UUID.randomUUID()).exerciseId("0001").setOrder(1)
                .reps(8).weightKg(80.0).restSeconds(120).isWarmup(false).build();

        SessionPlannedSet plannedSet = SessionPlannedSet.builder()
                .id(UUID.randomUUID()).setOrder(1).targetReps(8).targetWeightKg(80.0)
                .restSeconds(120).isWarmup(false).build();

        SessionPlannedExercise plannedExercise = SessionPlannedExercise.builder()
                .id(UUID.randomUUID()).exerciseId("0001").exerciseOrder(1)
                .sets(List.of(plannedSet)).build();

        TrainingSession session = TrainingSession.builder()
                .id(UUID.randomUUID()).user(User.builder().id(UUID.randomUUID()).build())
                .name("Séance push").status("COMPLETED").program(program)
                .sets(List.of(set)).plannedExercises(List.of(plannedExercise))
                .startedAt(LocalDateTime.now().minusHours(1)).endedAt(LocalDateTime.now())
                .build();

        SessionResponse response = sessionMapper.toResponse(session);

        assertEquals(session.getId(), response.id());
        assertEquals("COMPLETED", response.status());
        assertEquals(program.getId(), response.programId());
        assertEquals(1, response.sets().size());
        assertEquals("0001", response.sets().getFirst().exerciseId());
        assertEquals(1, response.plannedExercises().size());
        assertEquals(1, response.plannedExercises().getFirst().sets().size());
    }

    @Test
    void toResponse_shouldReturnNullProgramId_whenSessionHasNoProgram() {
        TrainingSession session = TrainingSession.builder()
                .id(UUID.randomUUID()).status("IN_PROGRESS")
                .sets(List.of()).plannedExercises(List.of())
                .build();

        SessionResponse response = sessionMapper.toResponse(session);

        assertNull(response.programId());
        assertTrue(response.sets().isEmpty());
        assertTrue(response.plannedExercises().isEmpty());
    }
}
