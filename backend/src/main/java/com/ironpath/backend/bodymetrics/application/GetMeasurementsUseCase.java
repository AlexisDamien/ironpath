package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetMeasurementsUseCase {

    private final BodyMeasurementRepository measurementRepository;

    public List<MeasurementResponse> execute(UUID userId) {
        return measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)
                .stream()
                .map(SaveMeasurementUseCase::toResponse)
                .toList();
    }
}