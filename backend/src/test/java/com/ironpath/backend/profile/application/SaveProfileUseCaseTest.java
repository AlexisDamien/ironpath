package com.ironpath.backend.profile.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.profile.api.dto.ProfileResponse;
import com.ironpath.backend.profile.api.dto.UpdateProfileRequest;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SaveProfileUseCaseTest {

    @Mock
    private ProfileRepository profileRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private SaveProfileUseCase saveProfileUseCase;

    @Test
    void execute_shouldCreateProfile_whenNoneExistsYet() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        UpdateProfileRequest request = new UpdateProfileRequest(
                "Camille", "Dupont", LocalDate.of(1995, 1, 1), 170.0, "FEMALE", "Perte de poids", "camille_dev"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(profileRepository.existsByUsernameAndUserIdNot("camille_dev", userId)).thenReturn(false);
        when(profileRepository.save(any(Profile.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ProfileResponse response = saveProfileUseCase.execute(userId, request);

        assertEquals("Camille", response.firstName());
        assertEquals("camille_dev", response.username());
        assertTrue(response.profileComplete());
    }

    @Test
    void execute_shouldUpdateOnlyProvidedFields_whenProfileAlreadyExists() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Profile existing = Profile.builder().user(user).firstName("Ancien").lastName("Nom").build();
        UpdateProfileRequest request = new UpdateProfileRequest(
                "Nouveau", null, null, null, null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.of(existing));
        when(profileRepository.save(any(Profile.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ProfileResponse response = saveProfileUseCase.execute(userId, request);

        assertEquals("Nouveau", response.firstName());
        assertEquals("Nom", response.lastName());
    }

    @Test
    void execute_shouldThrowException_whenUsernameAlreadyTaken() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        UpdateProfileRequest request = new UpdateProfileRequest(
                null, null, null, null, null, null, "already_taken"
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(profileRepository.findByUserId(userId)).thenReturn(Optional.empty());
        when(profileRepository.existsByUsernameAndUserIdNot("already_taken", userId)).thenReturn(true);

        assertThrows(IllegalArgumentException.class, () ->
                saveProfileUseCase.execute(userId, request)
        );
        verify_neverSaved();
    }

    @Test
    void execute_shouldThrowUnauthorized_whenUserNotFound() {
        UUID userId = UUID.randomUUID();
        UpdateProfileRequest request = new UpdateProfileRequest(
                "Camille", null, null, null, null, null, null
        );

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                saveProfileUseCase.execute(userId, request)
        );
    }

    private void verify_neverSaved() {
        org.mockito.Mockito.verify(profileRepository, never()).save(any());
    }
}
