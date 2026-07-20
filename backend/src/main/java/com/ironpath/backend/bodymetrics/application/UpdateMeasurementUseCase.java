package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdateMeasurementUseCase {

    private final BodyMeasurementRepository measurementRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public MeasurementResponse execute(UUID userId, UUID measurementId, SaveMeasurementRequest request) {
        BodyMeasurement measurement = measurementRepository.findById(measurementId)
                .orElseThrow(() -> new IllegalArgumentException("Mesure introuvable"));

        if (!measurement.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Cette mesure ne vous appartient pas");
        }
        emailVerificationGuard.check(measurement.getUser());

        if (request.weight() != null) { measurement.setWeight(request.weight()); }
        if (request.chest() != null) { measurement.setChest(request.chest()); }
        if (request.waist() != null) { measurement.setWaist(request.waist()); }
        if (request.hips() != null) { measurement.setHips(request.hips()); }
        if (request.leftArm() != null) { measurement.setLeftArm(request.leftArm()); }
        if (request.rightArm() != null) { measurement.setRightArm(request.rightArm()); }
        if (request.leftThigh() != null) { measurement.setLeftThigh(request.leftThigh()); }
        if (request.rightThigh() != null) { measurement.setRightThigh(request.rightThigh()); }
        if (request.leftCalf() != null) { measurement.setLeftCalf(request.leftCalf()); }
        if (request.rightCalf() != null) { measurement.setRightCalf(request.rightCalf()); }
        if (request.notes() != null) { measurement.setNotes(request.notes()); }

        BodyMeasurement saved = measurementRepository.save(measurement);
        return SaveMeasurementUseCase.toResponse(saved);
    }
}