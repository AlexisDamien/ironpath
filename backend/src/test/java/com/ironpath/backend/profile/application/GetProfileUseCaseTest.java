package com.ironpath.backend.profile.application;

import com.ironpath.backend.profile.api.dto.ProfileResponse;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetProfileUseCaseTest {

    @Mock
    private ProfileRepository profileRepository;

    @InjectMocks
    private GetProfileUseCase getProfileUseCase;

    @Test
    void execute_shouldReturnEmpty_whenProfileDoesNotExist() {
        UUID userId = UUID.randomUUID();

        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());

        Optional<ProfileResponse> response = getProfileUseCase.execute(userId);

        assertFalse(response.isPresent());
    }

    @Test
    void execute_shouldReturnProfileComplete_whenAllRequiredFieldsFilled() {
        UUID userId = UUID.randomUUID();
        Profile profile = Profile.builder()
                .id(UUID.randomUUID())
                .firstName("Camille")
                .username("camille_dev")
                .height(170.0)
                .birthDate(LocalDate.of(1995, 1, 1))
                .gender("FEMALE")
                .build();

        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));

        Optional<ProfileResponse> response = getProfileUseCase.execute(userId);

        assertTrue(response.isPresent());
        assertTrue(response.get().profileComplete());
    }

    @Test
    void execute_shouldReturnProfileIncomplete_whenRequiredFieldMissing() {
        UUID userId = UUID.randomUUID();
        Profile profile = Profile.builder()
                .id(UUID.randomUUID())
                .firstName("Camille")
                .username(null)
                .height(170.0)
                .birthDate(LocalDate.of(1995, 1, 1))
                .gender("FEMALE")
                .build();

        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(profile));

        Optional<ProfileResponse> response = getProfileUseCase.execute(userId);

        assertTrue(response.isPresent());
        assertFalse(response.get().profileComplete());
    }

    @Test
    void isComplete_shouldReturnFalse_whenProfileHasNoFields() {
        Profile emptyProfile = Profile.builder().build();

        assertFalse(GetProfileUseCase.isComplete(emptyProfile));
    }
}
