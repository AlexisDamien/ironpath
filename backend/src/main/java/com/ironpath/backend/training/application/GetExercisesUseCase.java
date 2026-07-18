package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.ExerciseResponse;
import com.ironpath.backend.training.domain.repository.ExerciseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GetExercisesUseCase {

    private final ExerciseRepository exerciseRepository;

    public List<ExerciseResponse> execute(String search, String muscleGroup) {
        String normalizedSearch = (search != null && !search.isBlank()) ? search : null;
        String normalizedMuscleGroup = (muscleGroup != null && !muscleGroup.isBlank()) ? muscleGroup : null;

        return exerciseRepository.search(normalizedSearch, normalizedMuscleGroup)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private ExerciseResponse toResponse(com.ironpath.backend.training.domain.model.Exercise exercise) {
        return new ExerciseResponse(
                exercise.getId(),
                exercise.getName(),
                exercise.getMuscleGroup(),
                exercise.getEquipment(),
                exercise.getDescription()
        );
    }
}