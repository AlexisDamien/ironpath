package com.ironpath.backend.profile.application;

import com.ironpath.backend.profile.api.dto.ProfileResponse;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetProfileUseCase {

    private final ProfileRepository profileRepository;

    public Optional<ProfileResponse> execute(UUID userId) {
        return profileRepository.findByUserId(userId)
                .map(profile -> new ProfileResponse(
                        profile.getId(),
                        profile.getFirstName(),
                        profile.getLastName(),
                        profile.getBirthDate(),
                        profile.getHeight(),
                        profile.getGender(),
                        profile.getObjective(),
                        profile.getUsername(),
                        profile.getAvatarUrl()
                ));
    }
}