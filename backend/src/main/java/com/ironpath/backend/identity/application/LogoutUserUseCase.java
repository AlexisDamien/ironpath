package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class LogoutUserUseCase {

    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public void execute(UUID userId) {
        refreshTokenRepository.revokeAllByUserId(userId);
    }
}