package com.ironpath.backend.training.domain.repository;

import com.ironpath.backend.training.domain.model.TrainingSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TrainingSessionRepository extends JpaRepository<TrainingSession, UUID> {

    List<TrainingSession> findByUserIdOrderByStartedAtDesc(UUID userId);
    Optional<TrainingSession> findByUserIdAndStatus(UUID userId, String status);

    boolean existsByUserIdAndStatus(UUID userId, String status);
}