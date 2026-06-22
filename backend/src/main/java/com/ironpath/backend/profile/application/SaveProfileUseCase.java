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
public class SaveProfileUseCase  {

    private final ProfileRepository profileRepository;
    private final UserRepository userRepository;

    @Transactional
    public ProfileResponse execute(UUID userId, UpdateProfileRequest request) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        if (request.username() != null &&
                profileRepository.existsByUsername(request.username())) {
            throw new IllegalArgumentException("Ce pseudonyme est déjà utilisé");
        }

        Profile profile = profileRepository.findByUserId(userId)
                .orElse(Profile.builder().user(user).build());

        if (request.firstName() != null) {
            profile.setFirstName(request.firstName());
        }
        if (request.lastName() != null) {
            profile.setLastName(request.lastName());
        }
        if (request.birthDate() != null) {
            profile.setBirthDate(request.birthDate());
        }
        if (request.heightCm() != null) {
            profile.setHeightCm(request.heightCm());
        }
        if (request.objective() != null) {
            profile.setObjective(request.objective());
        }
        if (request.username() != null) {
            profile.setUsername(request.username());
        }

        Profile savedProfile = profileRepository.save(profile);

        return toResponse(savedProfile);
    }

    private ProfileResponse toResponse(Profile profile) {
        return new ProfileResponse(
                profile.getId(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getBirthDate(),
                profile.getHeightCm(),
                profile.getObjective(),
                profile.getUsername(),
                profile.getAvatarUrl()
        );
    }
}