package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
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
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UpdateEmailUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationTokenRepository tokenRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private EmailService emailService;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private UpdateEmailUseCase updateEmailUseCase;

    @Test
    void execute_shouldUpdateEmailAndResetVerification_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("old@ironpath.com")
                .passwordHash("hashed").emailVerifiedAt(LocalDateTime.now()).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("correctPassword", "hashed")).thenReturn(true);
        when(userRepository.existsByEmail("new@ironpath.com")).thenReturn(false);

        updateEmailUseCase.execute(userId, "correctPassword", "New@Ironpath.com");

        assertEquals("new@ironpath.com", user.getEmail());
        assertNull(user.getEmailVerifiedAt());
        verify(userRepository, times(1)).save(user);
        verify(tokenRepository, times(1)).save(any());
        verify(emailService, times(1)).sendVerificationEmail(org.mockito.ArgumentMatchers.eq("New@Ironpath.com"), any(String.class));
    }

    @Test
    void execute_shouldThrowException_whenCurrentPasswordIncorrect() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).passwordHash("hashed").build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongPassword", "hashed")).thenReturn(false);

        assertThrows(UnauthorizedException.class, () ->
                updateEmailUseCase.execute(userId, "wrongPassword", "new@ironpath.com")
        );
        verify(userRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowException_whenNewEmailAlreadyUsed() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).passwordHash("hashed").build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("correctPassword", "hashed")).thenReturn(true);
        when(userRepository.existsByEmail("taken@ironpath.com")).thenReturn(true);

        assertThrows(IllegalArgumentException.class, () ->
                updateEmailUseCase.execute(userId, "correctPassword", "taken@ironpath.com")
        );
        verify(userRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenUserNotFound() {
        UUID userId = UUID.randomUUID();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                updateEmailUseCase.execute(userId, "any", "new@ironpath.com")
        );
    }
}
