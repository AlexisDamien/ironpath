package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetMeasurementsUseCaseTest {

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @InjectMocks
    private GetMeasurementsUseCase getMeasurementsUseCase;

    @Test
    void execute_shouldReturnMeasurements_orderedAsReturnedByRepository() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();

        BodyMeasurement recent = BodyMeasurement.builder()
                .id(UUID.randomUUID()).user(user).weight(80.0)
                .recordedAt(LocalDateTime.now()).build();
        BodyMeasurement older = BodyMeasurement.builder()
                .id(UUID.randomUUID()).user(user).weight(82.0)
                .recordedAt(LocalDateTime.now().minusDays(10)).build();

        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(recent, older));

        List<MeasurementResponse> responses = getMeasurementsUseCase.execute(userId);

        assertEquals(2, responses.size());
        assertEquals(recent.getId(), responses.get(0).id());
        assertEquals(older.getId(), responses.get(1).id());
    }

    @Test
    void execute_shouldReturnEmptyList_whenNoMeasurements() {
        UUID userId = UUID.randomUUID();

        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of());

        List<MeasurementResponse> responses = getMeasurementsUseCase.execute(userId);

        assertTrue(responses.isEmpty());
    }
}
