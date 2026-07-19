package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
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
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UpdatePasswordUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private UpdatePasswordUseCase updatePasswordUseCase;

    @Test
    void execute_shouldUpdatePasswordAndRevokeRefreshTokens_whenCurrentPasswordCorrect() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).passwordHash("oldHash")
                .emailVerifiedAt(LocalDateTime.now()).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("oldPassword", "oldHash")).thenReturn(true);
        when(passwordEncoder.encode("newPassword")).thenReturn("newHash");

        updatePasswordUseCase.execute(userId, "oldPassword", "newPassword");

        assertEquals("newHash", user.getPasswordHash());
        verify(userRepository, times(1)).save(user);
        verify(refreshTokenRepository, times(1)).revokeAllByUserId(userId);
    }

    @Test
    void execute_shouldThrowException_whenCurrentPasswordIncorrect() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).passwordHash("oldHash").build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongPassword", "oldHash")).thenReturn(false);

        assertThrows(IllegalArgumentException.class, () ->
                updatePasswordUseCase.execute(userId, "wrongPassword", "newPassword")
        );
        verify(userRepository, never()).save(any());
        verify(refreshTokenRepository, never()).revokeAllByUserId(any());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenUserNotFound() {
        UUID userId = UUID.randomUUID();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                updatePasswordUseCase.execute(userId, "old", "new")
        );
    }
}
