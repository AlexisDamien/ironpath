package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.api.dto.UpdateEmailRequest;
import com.ironpath.backend.identity.api.dto.UpdatePasswordRequest;
import com.ironpath.backend.identity.application.LogoutUserUseCase;
import com.ironpath.backend.identity.application.UpdateEmailUseCase;
import com.ironpath.backend.identity.application.UpdatePasswordUseCase;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final LogoutUserUseCase logoutUserUseCase;
    private final UpdateEmailUseCase updateEmailUseCase;

    @GetMapping("/me")
    public ResponseEntity<String> me(Authentication authentication) {
        return ResponseEntity.ok("Connecté en tant que : " + authentication.getName());
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        logoutUserUseCase.execute(userId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/email")
    public ResponseEntity<Void> updateEmail(
            @Valid @RequestBody UpdateEmailRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        updateEmailUseCase.execute(userId, request.currentPassword(), request.newEmail());
        return ResponseEntity.ok().build();
    }

    private final UpdatePasswordUseCase updatePasswordUseCase;

    @PutMapping("/password")
    public ResponseEntity<Void> updatePassword(
            @Valid @RequestBody UpdatePasswordRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        updatePasswordUseCase.execute(userId, request.currentPassword(), request.newPassword());
        return ResponseEntity.ok().build();
    }
}