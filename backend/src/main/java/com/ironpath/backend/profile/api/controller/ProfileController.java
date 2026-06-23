package com.ironpath.backend.profile.api.controller;

import com.ironpath.backend.profile.api.dto.ProfileResponse;
import com.ironpath.backend.profile.api.dto.UpdateProfileRequest;
import com.ironpath.backend.profile.application.GetProfileUseCase;
import com.ironpath.backend.profile.application.SaveProfileUseCase;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class ProfileController {

    private final SaveProfileUseCase saveProfileUseCase;
    private final GetProfileUseCase getProfileUseCase;

    @GetMapping
    public ResponseEntity<ProfileResponse> getProfile(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return getProfileUseCase.execute(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }

    @PutMapping
    public ResponseEntity<ProfileResponse> saveProfile(
            @Valid @RequestBody UpdateProfileRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        ProfileResponse response = saveProfileUseCase.execute(userId, request);
        return ResponseEntity.ok(response);
    }
}