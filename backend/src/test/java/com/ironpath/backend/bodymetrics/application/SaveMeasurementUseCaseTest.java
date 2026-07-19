package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
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
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SaveMeasurementUseCaseTest {

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private SaveMeasurementUseCase saveMeasurementUseCase;

    @Test
    void execute_shouldSaveMeasurement_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, 98.0, 82.0, 95.0,
                33.0, 34.0, 55.0, 56.0,
                38.0, 38.5, "Mesure matin", null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(measurementRepository.save(any(BodyMeasurement.class)))
                .thenAnswer(invocation -> {
                    BodyMeasurement m = invocation.getArgument(0);
                    m.setId(UUID.randomUUID());
                    return m;
                });

        MeasurementResponse response = saveMeasurementUseCase.execute(userId, request);

        assertNotNull(response);
        assertEquals(78.5, response.weight());
        assertEquals(98.0, response.chest());
        assertEquals("Mesure matin", response.notes());
    }

    @Test
    void execute_shouldArchivePreviousMeasurements_whenOnesAlreadyExist() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        BodyMeasurement previous1 = BodyMeasurement.builder().archived(false).build();
        BodyMeasurement previous2 = BodyMeasurement.builder().archived(false).build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null,
                null, null, null, null,
                null, null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(java.util.List.of(previous1, previous2));
        when(measurementRepository.save(any(BodyMeasurement.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        saveMeasurementUseCase.execute(userId, request);

        assertTrue(previous1.getArchived());
        assertTrue(previous2.getArchived());
        verify(measurementRepository).saveAll(java.util.List.of(previous1, previous2));
    }

    @Test
    void execute_shouldUseProvidedRecordedAt_whenExplicitlySet() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        LocalDateTime explicitDate = LocalDateTime.of(2026, 1, 15, 8, 0);

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null,
                null, null, null, null,
                null, null, null, explicitDate
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(measurementRepository.save(any(BodyMeasurement.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        MeasurementResponse response = saveMeasurementUseCase.execute(userId, request);

        assertEquals(explicitDate, response.recordedAt());
    }

    @Test
    void execute_shouldThrowException_whenUserNotFound() {
        UUID userId = UUID.randomUUID();
        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null,
                null, null, null, null,
                null, null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                saveMeasurementUseCase.execute(userId, request)
        );
    }

    @Test
    void execute_shouldSetRecordedAtToNow_whenNotProvided() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        SaveMeasurementRequest request = new SaveMeasurementRequest(
                78.5, null, null, null,
                null, null, null, null,
                null, null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(measurementRepository.save(any(BodyMeasurement.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        MeasurementResponse response = saveMeasurementUseCase.execute(userId, request);

        assertNotNull(response.recordedAt());
    }
}