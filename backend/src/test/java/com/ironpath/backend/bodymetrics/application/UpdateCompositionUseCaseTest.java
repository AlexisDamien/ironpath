package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UpdateCompositionUseCaseTest {

    @Mock
    private BodyCompositionRepository compositionRepository;

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private UpdateCompositionUseCase updateCompositionUseCase;

    @Test
    void execute_shouldUpdateOnlyProvidedFields_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition existing = BodyComposition.builder()
                .id(compositionId).user(user).bodyFat(15.0).notes("Ancienne note").build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                14.0, null, null, null, null, null, null, null, null, null, "Nouvelle note", null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));
        lenient().when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        lenient().when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = updateCompositionUseCase.execute(userId, compositionId, request);

        assertEquals(14.0, response.bodyFat());
        assertEquals("Nouvelle note", response.notes());
    }

    @Test
    void execute_shouldUpdateEveryField_whenAllProvidedInRequest() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition existing = BodyComposition.builder().id(compositionId).user(user).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                15.0, 44.0, 63.0, 14.0, 7,
                58.0, 61.0, 3.0, 17.0, 1800,
                "Toutes les valeurs", null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));
        lenient().when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        lenient().when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = updateCompositionUseCase.execute(userId, compositionId, request);

        assertEquals(15.0, response.bodyFat());
        assertEquals(44.0, response.skeletalMuscle());
        assertEquals(63.0, response.fatFreeMass());
        assertEquals(14.0, response.subcutaneousFat());
        assertEquals(7, response.visceralFat());
        assertEquals(58.0, response.bodyWater());
        assertEquals(61.0, response.muscleMass());
        assertEquals(3.0, response.boneMass());
        assertEquals(17.0, response.protein());
        assertEquals(1800, response.bmr());
        assertEquals("Toutes les valeurs", response.notes());
    }

    @Test
    void execute_shouldThrowException_whenCompositionNotFound() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        SaveCompositionRequest request = new SaveCompositionRequest(
                14.0, null, null, null, null, null, null, null, null, null, null, null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                updateCompositionUseCase.execute(userId, compositionId, request)
        );
    }

    @Test
    void execute_shouldThrowUnauthorized_whenCompositionBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        BodyComposition existing = BodyComposition.builder().id(compositionId).user(owner).build();
        SaveCompositionRequest request = new SaveCompositionRequest(
                14.0, null, null, null, null, null, null, null, null, null, null, null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));

        UnauthorizedException exception = assertThrows(UnauthorizedException.class, () ->
                updateCompositionUseCase.execute(userId, compositionId, request)
        );
        assertEquals("Cette composition ne vous appartient pas", exception.getMessage());
    }

    @Test
    void execute_shouldComputeBmiAndBmr_whenProfileAndWeightAvailableAndBmrNotProvided() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition existing = BodyComposition.builder().id(compositionId).user(user).build();
        Profile profile = Profile.builder()
                .height(180.0).birthDate(LocalDate.now().minusYears(30)).gender("MALE").build();
        BodyMeasurement measurement = BodyMeasurement.builder().weight(80.0).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null, null, null, null, null, null, null, null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of(measurement));
        when(compositionRepository.save(any(BodyComposition.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = updateCompositionUseCase.execute(userId, compositionId, request);

        assertNotNull(response.bmi());
        assertNotNull(response.bmr());
        assertNotNull(response.metabolicAge());
    }

    @Test
    void execute_shouldNotComputeBmi_whenProfileIsAbsent() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition existing = BodyComposition.builder().id(compositionId).user(user).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null, null, null, null, null, null, null, null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        lenient().when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = updateCompositionUseCase.execute(userId, compositionId, request);

        assertNull(response.bmi());
        assertNull(response.bmr());
    }

    @Test
    void execute_shouldUseProvidedBmr_whenBmrExplicitlyGiven() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition existing = BodyComposition.builder().id(compositionId).user(user).build();
        Profile profile = Profile.builder()
                .height(180.0).birthDate(LocalDate.now().minusYears(30)).gender("MALE").build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null, null, null, null, null, 1800, null, null, null
        );

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(existing));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
        lenient().when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class))).thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = updateCompositionUseCase.execute(userId, compositionId, request);

        assertEquals(1800, response.bmr());
    }
}
