package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.ProgramExercise;
import com.ironpath.backend.training.domain.model.ProgramExerciseSet;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ProgramMapperTest {

    private final ProgramMapper programMapper = new ProgramMapper();

    @Test
    void toResponse_shouldMapProgramWithNestedExercisesAndSets() {
        ProgramExerciseSet set = ProgramExerciseSet.builder()
                .id(UUID.randomUUID()).setOrder(1).targetReps(8).targetWeightKg(80.0)
                .restSeconds(120).isWarmup(false).build();

        ProgramExercise exercise = ProgramExercise.builder()
                .id(UUID.randomUUID()).exerciseId("0001").exerciseOrder(1)
                .sameConfigForAllSets(true).sets(List.of(set)).build();

        WorkoutProgram program = WorkoutProgram.builder()
                .id(UUID.randomUUID()).user(User.builder().id(UUID.randomUUID()).build())
                .name("PPL").description("Push Pull Legs").isActive(true)
                .exercises(List.of(exercise)).build();

        ProgramResponse response = programMapper.toResponse(program);

        assertEquals(program.getId(), response.id());
        assertEquals("PPL", response.name());
        assertTrue(response.isActive());
        assertEquals(1, response.exercises().size());
        assertEquals("0001", response.exercises().getFirst().exerciseId());
        assertEquals(1, response.exercises().getFirst().sets().size());
        assertEquals(8, response.exercises().getFirst().sets().getFirst().targetReps());
    }

    @Test
    void toResponse_shouldMapProgram_whenNoExercises() {
        WorkoutProgram program = WorkoutProgram.builder()
                .id(UUID.randomUUID()).name("Programme vide").isActive(false)
                .exercises(List.of()).build();

        ProgramResponse response = programMapper.toResponse(program);

        assertTrue(response.exercises().isEmpty());
    }
}
