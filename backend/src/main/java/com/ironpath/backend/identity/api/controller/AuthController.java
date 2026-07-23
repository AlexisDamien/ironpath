package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.api.dto.EmailVerificationStatusResponse;
import com.ironpath.backend.identity.api.dto.ForgotPasswordRequest;
import com.ironpath.backend.identity.api.dto.LoginRequest;
import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.api.dto.RefreshRequest;
import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.api.dto.ResetPasswordRequest;
import com.ironpath.backend.identity.application.ForgotPasswordUseCase;
import com.ironpath.backend.identity.application.GetEmailVerificationStatusUseCase;
import com.ironpath.backend.identity.application.LoginUserUseCase;
import com.ironpath.backend.identity.application.RefreshTokenUseCase;
import com.ironpath.backend.identity.application.RegisterUserUseCase;
import com.ironpath.backend.identity.application.ResetPasswordUseCase;
import com.ironpath.backend.identity.application.ResendVerificationEmailUseCase;
import com.ironpath.backend.identity.application.VerifyEmailUseCase;
import com.ironpath.backend.shared.infrastructure.HtmlTemplateRenderer;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.HtmlUtils;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private static final String VERIFY_SUCCESS_TEMPLATE =
            "templates/email-verification/success.html";
    private static final String VERIFY_EXPIRED_TEMPLATE =
            "templates/email-verification/expired.html";

    private final RegisterUserUseCase registerUserUseCase;
    private final LoginUserUseCase loginUserUseCase;
    private final RefreshTokenUseCase refreshTokenUseCase;
    private final GetEmailVerificationStatusUseCase getEmailVerificationStatusUseCase;
    private final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
    private final ForgotPasswordUseCase forgotPasswordUseCase;
    private final ResetPasswordUseCase resetPasswordUseCase;
    private final VerifyEmailUseCase verifyEmailUseCase;
    private final HtmlTemplateRenderer templateRenderer;

    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(
            @Valid @RequestBody RegisterRequest request,
            HttpServletRequest httpRequest) {
        String ipAddress = httpRequest.getRemoteAddr();
        LoginResponse response = registerUserUseCase.execute(request, ipAddress);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = loginUserUseCase.execute(request.email(), request.password());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(
            @Valid @RequestBody ForgotPasswordRequest request
    ) {
        forgotPasswordUseCase.execute(request.email());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Void> resetPassword(
            @Valid @RequestBody ResetPasswordRequest request
    ) {
        resetPasswordUseCase.execute(
                request.token(),
                request.newPassword()
        );
        return ResponseEntity.noContent().build();
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

    @GetMapping(value = "/verify-email", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
        try {
            verifyEmailUseCase.execute(token);
            return verifyEmailHtmlResponse(
                    templateRenderer.render(VERIFY_SUCCESS_TEMPLATE, Map.of())
            );
        } catch (IllegalArgumentException exception) {
            String message = HtmlUtils.htmlEscape(exception.getMessage());
            return verifyEmailHtmlResponse(
                    templateRenderer.render(
                            VERIFY_EXPIRED_TEMPLATE,
                            Map.of("MESSAGE", message)
                    )
            );
        }
    }

    private static ResponseEntity<String> verifyEmailHtmlResponse(String body) {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .header("Referrer-Policy", "no-referrer")
                .header("X-Content-Type-Options", "nosniff")
                .header("Permissions-Policy", "camera=(), microphone=()")
                .header(
                        "Content-Security-Policy",
                        "default-src 'none'; style-src 'self'; "
                                + "form-action 'self'; base-uri 'none'; "
                                + "frame-ancestors 'none'"
                )
                .contentType(MediaType.TEXT_HTML)
                .body(body);
    }
}
