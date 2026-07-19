package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class RefreshTokenUseCaseTest {

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private JwtService jwtService;

    @InjectMocks
    private RefreshTokenUseCase refreshTokenUseCase;

    @Test
    void execute_shouldReturnNewAccessToken_whenRefreshTokenValid() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("test@ironpath.com")
                .emailVerifiedAt(LocalDateTime.now()).build();
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user).token("valid-refresh-token")
                .revoked(false).expiresAt(LocalDateTime.now().plusDays(1)).build();

        when(refreshTokenRepository.findByToken("valid-refresh-token")).thenReturn(Optional.of(refreshToken));
        when(jwtService.generateToken(userId, "test@ironpath.com")).thenReturn("new-access-token");

        LoginResponse response = refreshTokenUseCase.execute("valid-refresh-token");

        assertEquals("new-access-token", response.token());
        assertEquals("valid-refresh-token", response.refreshToken());
        assertTrue(response.emailVerified());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenTokenNotFound() {
        when(refreshTokenRepository.findByToken("unknown-token")).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                refreshTokenUseCase.execute("unknown-token")
        );
    }

    @Test
    void execute_shouldThrowUnauthorized_whenTokenRevoked() {
        User user = User.builder().id(UUID.randomUUID()).email("test@ironpath.com").build();
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user).token("revoked-token")
                .revoked(true).expiresAt(LocalDateTime.now().plusDays(1)).build();

        when(refreshTokenRepository.findByToken("revoked-token")).thenReturn(Optional.of(refreshToken));

        assertThrows(UnauthorizedException.class, () ->
                refreshTokenUseCase.execute("revoked-token")
        );
    }

    @Test
    void execute_shouldThrowUnauthorized_whenTokenExpired() {
        User user = User.builder().id(UUID.randomUUID()).email("test@ironpath.com").build();
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user).token("expired-token")
                .revoked(false).expiresAt(LocalDateTime.now().minusDays(1)).build();

        when(refreshTokenRepository.findByToken("expired-token")).thenReturn(Optional.of(refreshToken));

        assertThrows(UnauthorizedException.class, () ->
                refreshTokenUseCase.execute("expired-token")
        );
    }
}
