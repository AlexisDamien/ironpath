package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.api.dto.EmailVerificationStatusResponse;
import com.ironpath.backend.identity.api.dto.LoginRequest;
import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.api.dto.RefreshRequest;
import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.application.GetEmailVerificationStatusUseCase;
import com.ironpath.backend.identity.application.LoginUserUseCase;
import com.ironpath.backend.identity.application.RefreshTokenUseCase;
import com.ironpath.backend.identity.application.RegisterUserUseCase;
import com.ironpath.backend.identity.application.ResendVerificationEmailUseCase;
import com.ironpath.backend.identity.application.VerifyEmailUseCase;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final RegisterUserUseCase registerUserUseCase;
    private final VerifyEmailUseCase verifyEmailUseCase;
    private final LoginUserUseCase loginUserUseCase;
    private final RefreshTokenUseCase refreshTokenUseCase;
    private final GetEmailVerificationStatusUseCase getEmailVerificationStatusUseCase;
    private final ResendVerificationEmailUseCase resendVerificationEmailUseCase;

    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest) {
        String ipAddress = httpRequest.getRemoteAddr();
        LoginResponse response = registerUserUseCase.execute(request, ipAddress);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/verify-email")
    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
        verifyEmailUseCase.execute(token);
        return ResponseEntity.ok("Email vérifié avec succès !");
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = loginUserUseCase.execute(request.email(), request.password());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    public ResponseEntity<String> me(Authentication authentication) {
        if (authentication == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok("Connecté en tant que : " + authentication.getName());
    }

    @PostMapping("/refresh")
    public ResponseEntity<LoginResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        LoginResponse response = refreshTokenUseCase.execute(request.refreshToken());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/email-verification-status")
    public ResponseEntity<EmailVerificationStatusResponse> emailVerificationStatus(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(getEmailVerificationStatusUseCase.execute(userId));
    }

    @PostMapping("/resend-verification")
    public ResponseEntity<Void> resendVerification(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        resendVerificationEmailUseCase.execute(userId);
        return ResponseEntity.noContent().build();
    }
}