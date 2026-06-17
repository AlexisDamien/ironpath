package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.application.LogoutUserUseCase;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
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
}