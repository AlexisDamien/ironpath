package com.ironpath.backend.bodymetrics.domain.repository;

import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface BodyMeasurementRepository extends JpaRepository<BodyMeasurement, UUID> {
    List<BodyMeasurement> findByUserIdOrderByRecordedAtDesc(UUID userId);
}