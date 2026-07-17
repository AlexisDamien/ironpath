package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeleteMeasurementUseCase {

    private final BodyMeasurementRepository measurementRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public void execute(UUID userId, UUID measurementId) {
        var measurement = measurementRepository.findById(measurementId)
                .orElseThrow(() -> new IllegalArgumentException("Mesure introuvable"));

        if (!measurement.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Cette mesure ne vous appartient pas");
        }
        emailVerificationGuard.check(measurement.getUser());

        measurementRepository.delete(measurement);
    }
}