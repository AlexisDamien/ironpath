package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import com.ironpath.backend.shared.infrastructure.LoginRateLimiter;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LoginUserUseCase {

    private static final Logger SECURITY_LOG = LoggerFactory.getLogger("SECURITY");

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final LoginRateLimiter loginRateLimiter;

    @Transactional
    public LoginResponse execute(String email, String password) {
        String normalizedEmail = email.toLowerCase().trim();

        loginRateLimiter.checkAllowed(normalizedEmail);

        User user = userRepository.findByEmail(normalizedEmail)
                .orElseGet(() -> {
                    loginRateLimiter.recordFailedAttempt(normalizedEmail);
                    SECURITY_LOG.warn(
                            "Tentative de connexion refusée (email inconnu) : {}",
                            normalizedEmail
                    );
                    throw new UnauthorizedException("Email ou mot de passe incorrect");
                });

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            loginRateLimiter.recordFailedAttempt(normalizedEmail);
            SECURITY_LOG.warn(
                    "Tentative de connexion refusée (mot de passe invalide) pour userId={}",
                    user.getId()
            );
            throw new UnauthorizedException("Email ou mot de passe incorrect");
        }

        loginRateLimiter.recordSuccessfulAttempt(normalizedEmail);
        SECURITY_LOG.info("Connexion réussie pour userId={}", user.getId());

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        refreshTokenRepository.revokeAllByUserId(user.getId());

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .build();

        refreshTokenRepository.save(refreshToken);

        return new LoginResponse(token, refreshToken.getToken(), user.getEmailVerifiedAt() != null);
    }
}