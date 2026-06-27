package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SaveMeasurementUseCase {

    private final BodyMeasurementRepository measurementRepository;
    private final UserRepository userRepository;

    public MeasurementResponse execute(UUID userId, SaveMeasurementRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));

        BodyMeasurement measurement = BodyMeasurement.builder()
                .user(user)
                .weight(request.weight())
                .chest(request.chest())
                .waist(request.waist())
                .hips(request.hips())
                .leftArm(request.leftArm())
                .rightArm(request.rightArm())
                .leftThigh(request.leftThigh())
                .rightThigh(request.rightThigh())
                .leftCalf(request.leftCalf())
                .rightCalf(request.rightCalf())
                .notes(request.notes())
                .recordedAt(request.recordedAt() != null ? request.recordedAt() : LocalDateTime.now())
                .build();

        BodyMeasurement saved = measurementRepository.save(measurement);
        return toResponse(saved);
    }

    public static MeasurementResponse toResponse(BodyMeasurement measurement) {
        return new MeasurementResponse(
                measurement.getId(),
                measurement.getWeight(),
                measurement.getChest(),
                measurement.getWaist(),
                measurement.getHips(),
                measurement.getLeftArm(),
                measurement.getRightArm(),
                measurement.getLeftThigh(),
                measurement.getRightThigh(),
                measurement.getLeftCalf(),
                measurement.getRightCalf(),
                measurement.getNotes(),
                measurement.getRecordedAt()
        );
    }
}