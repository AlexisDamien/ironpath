package com.ironpath.backend.training.domain.repository;

import com.ironpath.backend.training.domain.model.OneRepMax;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OneRepMaxRepository extends JpaRepository<OneRepMax, UUID> {

    Optional<OneRepMax> findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(UUID userId, String exerciseId);

    List<OneRepMax> findByUserIdAndExerciseIdOrderByCalculatedAtAsc(UUID userId, String exerciseId);
}