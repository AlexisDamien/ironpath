package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LoginUserUseCase {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public LoginResponse execute(String email, String password) {
        User user = userRepository.findByEmail(email.toLowerCase().trim())
                .orElseThrow(() -> new UnauthorizedException("Email ou mot de passe incorrect"));

        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new UnauthorizedException("Email ou mot de passe incorrect");
        }

        if (user.getEmailVerifiedAt() == null) {
            throw new UnauthorizedException("Veuillez confirmer votre email avant de vous connecter");
        }

        String token = jwtService.generateToken(user.getId(), user.getEmail());

        refreshTokenRepository.revokeAllByUserId(user.getId());

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .build();

        refreshTokenRepository.save(refreshToken);

        return new LoginResponse(token, refreshToken.getToken());
    }
}