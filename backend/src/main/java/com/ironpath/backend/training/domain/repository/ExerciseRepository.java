package com.ironpath.backend.training.domain.repository;

import com.ironpath.backend.training.domain.model.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, String> {
    List<Exercise> findByMuscleGroupIgnoreCase(String muscleGroup);
    List<Exercise> findByNameContainingIgnoreCase(String name);
}