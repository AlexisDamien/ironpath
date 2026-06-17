package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.application.RegisterUserUseCase;
import com.ironpath.backend.identity.application.VerifyEmailUseCase;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final RegisterUserUseCase registerUserUseCase;

    @PostMapping("/register")
    public ResponseEntity<Void> register(@Valid @RequestBody RegisterRequest request) {
        registerUserUseCase.execute(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }
    private final VerifyEmailUseCase verifyEmailUseCase;

    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
        verifyEmailUseCase.execute(token);
        return ResponseEntity.ok("Email vérifié avec succès !");
    }
}