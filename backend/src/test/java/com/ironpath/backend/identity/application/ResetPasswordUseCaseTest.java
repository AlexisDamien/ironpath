package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.PasswordResetToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.PasswordResetTokenRepository;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ResetPasswordUseCaseTest {

    @Mock
    private PasswordResetTokenRepository tokenRepository;

    @Mock
    private PasswordResetTokenCodec tokenCodec;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private ResetPasswordUseCase resetPasswordUseCase;

    @Test
    void execute_shouldUpdatePasswordUseTokenAndRevokeSessions_whenTokenValid() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).passwordHash("old-hash").build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(false)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));
        when(passwordEncoder.encode("New-password-123!")).thenReturn("new-hash");

        resetPasswordUseCase.execute("raw-token", "New-password-123!");

        assertEquals("new-hash", user.getPasswordHash());
        assertTrue(resetToken.getUsed());
        verify(userRepository, times(1)).save(user);
        verify(tokenRepository, times(1)).save(resetToken);
        verify(refreshTokenRepository, times(1)).revokeAllByUserId(userId);
    }

    @Test
    void execute_shouldRejectExpiredToken_withoutChangingPassword() {
        User user = User.builder().id(UUID.randomUUID()).passwordHash("old-hash").build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(false)
                .expiresAt(LocalDateTime.now().minusMinutes(1))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));

        assertThrows(
                IllegalArgumentException.class,
                () -> resetPasswordUseCase.execute("raw-token", "New-password-123!")
        );

        verify(userRepository, never()).save(any());
        verify(refreshTokenRepository, never()).revokeAllByUserId(
                any()
        );
    }

    @Test
    void execute_shouldRejectWeakPassword_beforeUsingToken() {
        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> resetPasswordUseCase.execute(
                        "raw-token",
                        "weak-password"
                )
        );

        assertEquals(
                "Ajoutez au moins une majuscule.",
                exception.getMessage()
        );
        verify(tokenRepository, never()).findByTokenHash(any());
        verify(userRepository, never()).save(any());
    }

    @Test
    void isTokenValid_shouldReturnTrue_whenTokenExistsAndIsValid() {
        User user = User.builder().id(UUID.randomUUID()).build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(false)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));

        assertTrue(resetPasswordUseCase.isTokenValid("raw-token"));
    }

    @Test
    void isTokenValid_shouldReturnFalse_whenTokenExpired() {
        User user = User.builder().id(UUID.randomUUID()).build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(false)
                .expiresAt(LocalDateTime.now().minusMinutes(1))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));

        assertFalse(resetPasswordUseCase.isTokenValid("raw-token"));
    }

    @Test
    void isTokenValid_shouldReturnFalse_whenTokenAlreadyUsed() {
        User user = User.builder().id(UUID.randomUUID()).build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(true)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));

        assertFalse(resetPasswordUseCase.isTokenValid("raw-token"));
    }

    @Test
    void isTokenValid_shouldReturnFalse_whenTokenNotFound() {
        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.empty());

        assertFalse(resetPasswordUseCase.isTokenValid("raw-token"));
    }

    @Test
    void isTokenValid_shouldNotConsumeTheToken() {
        User user = User.builder().id(UUID.randomUUID()).build();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash("hashed-token")
                .used(false)
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .build();

        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");
        when(tokenRepository.findByTokenHash("hashed-token"))
                .thenReturn(Optional.of(resetToken));

        resetPasswordUseCase.isTokenValid("raw-token");

        verify(tokenRepository, never()).save(any());
        verify(userRepository, never()).save(any());
        assertFalse(resetToken.getUsed());
    }
}
