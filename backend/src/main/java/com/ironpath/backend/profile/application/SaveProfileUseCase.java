package com.ironpath.backend.profile.application;

import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.profile.api.dto.ProfileResponse;
import com.ironpath.backend.profile.api.dto.UpdateProfileRequest;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SaveProfileUseCase {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    @Transactional
    public ProfileResponse execute(
            UUID userId,
            UpdateProfileRequest request
    ) {
        var user = userRepository.findById(userId)
                .orElseThrow(() ->
                        new UnauthorizedException("Utilisateur introuvable")
                );

        Profile profile = profileRepository.findByUserId(userId)
                .orElse(Profile.builder().user(user).build());

        if (request.firstName() != null) {
            profile.setFirstName(normalizeNullable(request.firstName()));
        }
        if (request.lastName() != null) {
            profile.setLastName(normalizeNullable(request.lastName()));
        }
        if (request.birthDate() != null) {
            profile.setBirthDate(request.birthDate());
        }
        if (request.height() != null) {
            profile.setHeight(request.height());
        }
        if (request.gender() != null) {
            profile.setGender(request.gender());
        }
        if (request.objective() != null) {
            profile.setObjective(request.objective());
        }
        if (request.username() != null) {
            updateUsername(profile, userId, request.username());
        }

        Profile savedProfile = profileRepository.save(profile);
        return toResponse(savedProfile);
    }

    private void updateUsername(
            Profile profile,
            UUID userId,
            String rawUsername
    ) {
        String username = normalizeNullable(rawUsername);

        if (username == null) {
            profile.setUsername(null);
            return;
        }
        if (username.length() < 3 || username.length() > 30) {
            throw new IllegalArgumentException(
                    "Le nom d’utilisateur doit contenir entre 3 et 30 caractères"
            );
        }
        if (profileRepository.existsByUsernameAndUserIdNot(
                username,
                userId
        )) {
            throw new IllegalArgumentException(
                    "Ce pseudonyme est déjà utilisé"
            );
        }

        profile.setUsername(username);
    }

    private String normalizeNullable(String value) {
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private ProfileResponse toResponse(Profile profile) {
        return new ProfileResponse(
                profile.getId(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getBirthDate(),
                profile.getHeight(),
                profile.getGender(),
                profile.getObjective(),
                profile.getUsername(),
                profile.getAvatarUrl(),
                GetProfileUseCase.isComplete(profile)
        );
    }
}
