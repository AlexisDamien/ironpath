package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.UUID;

import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class LogoutUserUseCaseTest {

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private LogoutUserUseCase logoutUserUseCase;

    @Test
    void execute_shouldRevokeAllTokens_whenValidUserId() {
        UUID userId = UUID.randomUUID();

        logoutUserUseCase.execute(userId);

        verify(refreshTokenRepository).revokeAllByUserId(userId);
    }
}