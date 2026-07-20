package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SaveMeasurementUseCase {

    private final BodyMeasurementRepository measurementRepository;
    private final UserRepository userRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public MeasurementResponse execute(UUID userId, SaveMeasurementRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));
        emailVerificationGuard.check(user);

        List<BodyMeasurement> existing = measurementRepository
                .findByUserIdOrderByRecordedAtDesc(userId);
        for (BodyMeasurement old : existing) {
            old.setArchived(true);
        }
        measurementRepository.saveAll(existing);

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
                .archived(false)
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
                measurement.getRecordedAt(),
                measurement.getArchived()
        );
    }
}