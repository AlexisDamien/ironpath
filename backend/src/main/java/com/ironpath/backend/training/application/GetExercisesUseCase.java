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
        if (search != null && !search.isBlank()) {
            return exerciseRepository.findByNameContainingIgnoreCase(search)
                    .stream()
                    .map(this::toResponse)
                    .toList();
        }
        if (muscleGroup != null && !muscleGroup.isBlank()) {
            return exerciseRepository.findByMuscleGroupIgnoreCase(muscleGroup)
                    .stream()
                    .map(this::toResponse)
                    .toList();
        }
        return exerciseRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private ExerciseResponse toResponse(
            com.ironpath.backend.training.domain.model.Exercise exercise) {
        return new ExerciseResponse(
                exercise.getId(),
                exercise.getName(),
                exercise.getMuscleGroup(),
                exercise.getEquipment(),
                exercise.getDescription()
        );
    }
}