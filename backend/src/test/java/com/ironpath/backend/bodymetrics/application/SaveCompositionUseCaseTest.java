package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SaveCompositionUseCaseTest {

    @Mock
    private BodyCompositionRepository compositionRepository;

    @Mock
    private BodyMeasurementRepository measurementRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private SaveCompositionUseCase saveCompositionUseCase;


    @Test
    void execute_shouldCalculateBmiAndBmr_whenProfileAndWeightAvailable() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        Profile profile = Profile.builder()
                .user(user)
                .height(178.0)
                .birthDate(LocalDate.of(1998, 3, 15))
                .gender("MALE")
                .build();

        BodyMeasurement lastMeasurement = BodyMeasurement.builder()
                .weight(78.5)
                .build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                18.5, 44.2, 63.9, 14.2, 7,
                58.3, 61.0, 3.2, 17.8, null,
                "Test", null, "MANUAL"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(lastMeasurement));
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = saveCompositionUseCase.execute(userId, request);

        assertNotNull(response);
        assertNotNull(response.bmi());
        assertNotNull(response.bmr());
        assertNotNull(response.metabolicAge());
    }

    @Test
    void execute_shouldNotCalculateBmi_whenNoWeightInMeasurements() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        Profile profile = Profile.builder()
                .user(user)
                .height(178.0)
                .birthDate(LocalDate.of(1998, 3, 15))
                .gender("MALE")
                .build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                18.5, 44.2, 63.9, 14.2, 7,
                58.3, 61.0, 3.2, 17.8, null,
                "Test", null, "MANUAL"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = saveCompositionUseCase.execute(userId, request);

        assertNotNull(response);
        assertNull(response.bmi());
    }

    @Test
    void execute_shouldArchivePreviousCompositions_whenOnesAlreadyExist() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        BodyComposition previous1 = BodyComposition.builder().archived(false).build();
        BodyComposition previous2 = BodyComposition.builder().archived(false).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                18.5, null, null, null, null,
                null, null, null, null, null,
                null, null, "MANUAL"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(previous1, previous2));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        saveCompositionUseCase.execute(userId, request);

        assertTrue(previous1.getArchived());
        assertTrue(previous2.getArchived());
        verify(compositionRepository).saveAll(List.of(previous1, previous2));
    }

    @Test
    void execute_shouldNotCalculateBmiOrBmr_whenProfileIsAbsent() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        BodyMeasurement lastMeasurement = BodyMeasurement.builder().weight(78.5).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                18.5, null, null, null, null,
                null, null, null, null, null,
                null, null, "MANUAL"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(lastMeasurement));
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = saveCompositionUseCase.execute(userId, request);

        assertNull(response.bmi());
        assertNull(response.bmr());
        assertNull(response.metabolicAge());
    }

    @Test
    void execute_shouldUseExplicitBmr_whenProvidedInRequest() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();
        Profile profile = Profile.builder()
                .user(user).height(178.0).birthDate(LocalDate.of(1998, 3, 15)).gender("MALE").build();
        BodyMeasurement lastMeasurement = BodyMeasurement.builder().weight(78.5).build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null,
                null, null, null, null, 1750,
                null, null, "MANUAL"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(lastMeasurement));
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = saveCompositionUseCase.execute(userId, request);

        assertEquals(1750, response.bmr());
        assertNotNull(response.metabolicAge());
    }

    @Test
    void execute_shouldDefaultSourceToManual_whenSourceNotProvided() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com").build();

        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null,
                null, null, null, null, null,
                null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(measurementRepository.findByUserIdOrderByRecordedAtDesc(userId)).thenReturn(List.of());
        when(compositionRepository.save(any(BodyComposition.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CompositionResponse response = saveCompositionUseCase.execute(userId, request);

        assertEquals("MANUAL", response.source());
    }

    @Test
    void execute_shouldThrowException_whenUserNotFound() {
        UUID userId = UUID.randomUUID();
        SaveCompositionRequest request = new SaveCompositionRequest(
                null, null, null, null, null,
                null, null, null, null, null,
                null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                saveCompositionUseCase.execute(userId, request)
        );
    }
}