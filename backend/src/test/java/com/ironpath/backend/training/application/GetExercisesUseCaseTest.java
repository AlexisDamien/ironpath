package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.ExerciseResponse;
import com.ironpath.backend.training.domain.model.Exercise;
import com.ironpath.backend.training.domain.repository.ExerciseRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetExercisesUseCaseTest {

    @Mock
    private ExerciseRepository exerciseRepository;

    @InjectMocks
    private GetExercisesUseCase getExercisesUseCase;

    @Test
    void execute_shouldReturnMappedExercises_whenSearchAndMuscleGroupProvided() {
        Exercise exercise = Exercise.builder()
                .id("0001").name("Développé couché").muscleGroup("Pectoraux")
                .equipment("Barre").description("Exercice polyarticulaire").build();

        when(exerciseRepository.search("développé", "Pectoraux")).thenReturn(List.of(exercise));

        List<ExerciseResponse> responses = getExercisesUseCase.execute("développé", "Pectoraux");

        assertEquals(1, responses.size());
        assertEquals("0001", responses.getFirst().id());
        assertEquals("Développé couché", responses.getFirst().name());
    }

    @Test
    void execute_shouldNormalizeBlankSearch_toNull() {
        when(exerciseRepository.search(isNull(), isNull())).thenReturn(List.of());

        getExercisesUseCase.execute("   ", "");

        org.mockito.Mockito.verify(exerciseRepository).search(isNull(), isNull());
    }

    @Test
    void execute_shouldReturnEmptyList_whenNoExercisesMatch() {
        when(exerciseRepository.search(eq("inexistant"), isNull())).thenReturn(List.of());

        List<ExerciseResponse> responses = getExercisesUseCase.execute("inexistant", null);

        assertTrue(responses.isEmpty());
    }
}
