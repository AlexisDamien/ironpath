package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VerifyEmailUseCaseTest {

    @Mock
    private EmailVerificationTokenRepository tokenRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private VerifyEmailUseCase verifyEmailUseCase;

    @Test
    void execute_shouldVerifyEmail_whenValidToken() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        EmailVerificationToken token = EmailVerificationToken.builder()
                .id(UUID.randomUUID())
                .user(user)
                .token("valid-token")
                .used(false)
                .expiresAt(LocalDateTime.now().plusHours(24))
                .build();

        when(tokenRepository.findByToken("valid-token")).thenReturn(Optional.of(token));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        verifyEmailUseCase.execute("valid-token");

        verify(userRepository).save(any(User.class));
        verify(tokenRepository).save(any(EmailVerificationToken.class));
    }

    @Test
    void execute_shouldThrowException_whenTokenNotFound() {
        when(tokenRepository.findByToken("invalid-token")).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                verifyEmailUseCase.execute("invalid-token")
        );

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void execute_shouldThrowException_whenTokenExpired() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        EmailVerificationToken expiredToken = EmailVerificationToken.builder()
                .id(UUID.randomUUID())
                .user(user)
                .token("expired-token")
                .used(false)
                .expiresAt(LocalDateTime.now().minusHours(1))
                .build();

        when(tokenRepository.findByToken("expired-token")).thenReturn(Optional.of(expiredToken));

        assertThrows(IllegalArgumentException.class, () ->
                verifyEmailUseCase.execute("expired-token")
        );

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void execute_shouldThrowException_whenTokenAlreadyUsed() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        EmailVerificationToken usedToken = EmailVerificationToken.builder()
                .id(UUID.randomUUID())
                .user(user)
                .token("used-token")
                .used(true)
                .expiresAt(LocalDateTime.now().plusHours(24))
                .build();

        when(tokenRepository.findByToken("used-token")).thenReturn(Optional.of(usedToken));

        assertThrows(IllegalArgumentException.class, () ->
                verifyEmailUseCase.execute("used-token")
        );

        verify(userRepository, never()).save(any(User.class));
    }
}