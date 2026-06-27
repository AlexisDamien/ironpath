package com.ironpath.backend.bodymetrics.domain.repository;

import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BodyCompositionRepository extends JpaRepository<BodyComposition, UUID> {
    List<BodyComposition> findByUserIdOrderByRecordedAtDesc(UUID userId);
}