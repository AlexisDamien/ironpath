package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DeleteAccountUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private DeleteAccountUseCase deleteAccountUseCase;

    @Test
    void execute_shouldDeleteAccount_whenValidCredentials() {
        UUID userId = UUID.randomUUID();
        User user = User.builder()
                .id(userId)
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);

        deleteAccountUseCase.execute(userId, "password123");

        verify(refreshTokenRepository).revokeAllByUserId(userId);
        verify(refreshTokenRepository).deleteAllByUserId(userId);
        verify(userRepository).delete(user);
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenUserNotFound() {
        UUID userId = UUID.randomUUID();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                deleteAccountUseCase.execute(userId, "password123")
        );

        verify(userRepository, never()).delete(any(User.class));
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenWrongPassword() {
        UUID userId = UUID.randomUUID();
        User user = User.builder()
                .id(userId)
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        assertThrows(UnauthorizedException.class, () ->
                deleteAccountUseCase.execute(userId, "wrongpassword")
        );

        verify(userRepository, never()).delete(any(User.class));
    }
}