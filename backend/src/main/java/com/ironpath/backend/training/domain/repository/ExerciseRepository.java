package com.ironpath.backend.training.domain.repository;

import com.ironpath.backend.training.domain.model.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, String> {

    @Query("SELECT e FROM Exercise e WHERE " +
            "(:search IS NULL OR LOWER(e.name) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%'))) AND " +
            "(:muscleGroup IS NULL OR LOWER(e.muscleGroup) = LOWER(CAST(:muscleGroup AS string)))")
    List<Exercise> search(@Param("search") String search, @Param("muscleGroup") String muscleGroup);
}