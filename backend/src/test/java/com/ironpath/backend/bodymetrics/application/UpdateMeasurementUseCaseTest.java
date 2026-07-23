package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.ForbiddenException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UpdateMeasurementUseCaseTest {

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private UpdateMeasurementUseCase updateMeasurementUseCase;

    @Test
    void execute_shouldUpdateOnlyProvidedFields_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyMeasurement existing = BodyMeasurement.builder()
                .id(measurementId).user(user)
                .weight(80.0).chest(100.0).waist(85.0).notes("Ancienne note")
                .build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null,
                null, null, null, null,
                null, null, "Nouvelle note", null
        );

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(existing));
        when(measurementRepository.save(any(BodyMeasurement.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MeasurementResponse response = updateMeasurementUseCase.execute(userId, measurementId, request);

        assertEquals(78.5, response.weight());
        assertEquals(100.0, response.chest());
        assertEquals("Nouvelle note", response.notes());
    }

    @Test
    void execute_shouldUpdateEveryField_whenAllProvidedInRequest() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyMeasurement existing = BodyMeasurement.builder().id(measurementId).user(user).build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, 98.0, 82.0, 95.0,
                33.0, 34.0, 55.0, 56.0,
                38.0, 38.5, "Toutes les mesures", null
        );

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(existing));
        when(measurementRepository.save(any(BodyMeasurement.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MeasurementResponse response = updateMeasurementUseCase.execute(userId, measurementId, request);

        assertEquals(78.5, response.weight());
        assertEquals(98.0, response.chest());
        assertEquals(82.0, response.waist());
        assertEquals(95.0, response.hips());
        assertEquals(33.0, response.leftArm());
        assertEquals(34.0, response.rightArm());
        assertEquals(55.0, response.leftThigh());
        assertEquals(56.0, response.rightThigh());
        assertEquals(38.0, response.leftCalf());
        assertEquals(38.5, response.rightCalf());
        assertEquals("Toutes les mesures", response.notes());
    }

    @Test
    void execute_shouldThrowException_whenMeasurementNotFound() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null, null, null, null, null, null, null, null, null
        );

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                updateMeasurementUseCase.execute(userId, measurementId, request)
        );
        verify_neverSaved();
    }

    @Test
    void execute_shouldThrowForbidden_whenMeasurementBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        BodyMeasurement existing = BodyMeasurement.builder().id(measurementId).user(owner).build();
        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null, null, null, null, null, null, null, null, null
        );

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(existing));

        ForbiddenException exception = assertThrows(ForbiddenException.class, () ->
                updateMeasurementUseCase.execute(userId, measurementId, request)
        );
        assertEquals("Cette mesure ne vous appartient pas", exception.getMessage());
    }

    @Test
    void execute_shouldKeepExistingValue_whenFieldNotProvidedInRequest() {
        UUID userId = UUID.randomUUID();
        UUID measurementId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyMeasurement existing = BodyMeasurement.builder()
                .id(measurementId).user(user).weight(80.0).build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                null, null, null, null, null, null, null, null, null, null, null, null
        );

        when(measurementRepository.findById(measurementId)).thenReturn(Optional.of(existing));
        when(measurementRepository.save(any(BodyMeasurement.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MeasurementResponse response = updateMeasurementUseCase.execute(userId, measurementId, request);

        assertNotNull(response);
        assertEquals(80.0, response.weight());
    }

    private void verify_neverSaved() {
        org.mockito.Mockito.verify(measurementRepository, never()).save(any());
    }
}
