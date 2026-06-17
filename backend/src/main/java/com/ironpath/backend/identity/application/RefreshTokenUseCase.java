package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RefreshTokenUseCase {

    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;

    @Transactional
    public String execute(String refreshToken) {
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> new UnauthorizedException("Refresh token invalide"));

        if (!token.isValid()) {
            throw new UnauthorizedException("Refresh token expiré ou révoqué");
        }

        return jwtService.generateToken(
                token.getUser().getId(),
                token.getUser().getEmail()
        );
    }
}