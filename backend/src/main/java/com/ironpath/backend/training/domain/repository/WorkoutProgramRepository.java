package com.ironpath.backend.training.domain.repository;

import com.ironpath.backend.training.domain.model.WorkoutProgram;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.UUID;

@Repository
public interface WorkoutProgramRepository extends JpaRepository<WorkoutProgram, UUID> {

    List<WorkoutProgram> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<WorkoutProgram> findByUserIdAndIsActiveTrue(UUID userId);
}