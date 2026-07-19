package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DeleteMeasurementUseCaseTest {

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private DeleteMeasurementUseCase deleteMeasurementUseCase;

    @Test
    void execute_shouldDeleteMeasurement_whenOwnedByUserAndVerified() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyMeasurement measurement = BodyMeasurement.builder().id(measurementId).user(user).build();

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(measurement));

        deleteMeasurementUseCase.execute(userId, measurementId);

        verify(measurementRepository, times(1)).delete(measurement);
    }

    @Test
    void execute_shouldThrowException_whenMeasurementNotFound() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                deleteMeasurementUseCase.execute(userId, measurementId)
        );
        verify(measurementRepository, never()).delete(any());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenMeasurementBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        BodyMeasurement measurement = BodyMeasurement.builder().id(measurementId).user(owner).build();

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(measurement));

        UnauthorizedException exception = assertThrows(UnauthorizedException.class, () ->
                deleteMeasurementUseCase.execute(userId, measurementId)
        );
        assertEquals("Cette mesure ne vous appartient pas", exception.getMessage());
        verify(measurementRepository, never()).delete(any());
    }

    @Test
    void execute_shouldThrowException_whenEmailNotVerified() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(null).build();
        BodyMeasurement measurement = BodyMeasurement.builder().id(measurementId).user(user).build();

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(measurement));
        org.mockito.Mockito.doThrow(new UnauthorizedException("Veuillez vérifier votre email avant d'effectuer cette action"))
                .when(emailVerificationGuard).check(user);

        assertThrows(UnauthorizedException.class, () ->
                deleteMeasurementUseCase.execute(userId, measurementId)
        );
        verify(measurementRepository, never()).delete(any());
    }
}
