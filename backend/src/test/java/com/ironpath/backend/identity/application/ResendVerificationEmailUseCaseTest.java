package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ResendVerificationEmailUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationTokenRepository tokenRepository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private ResendVerificationEmailUseCase resendVerificationEmailUseCase;

    @Test
    void execute_shouldRegenerateTokenAndSendEmail_whenEmailNotVerified() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).email("candidat@ironpath.com").emailVerifiedAt(null).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        resendVerificationEmailUseCase.execute(userId);

        verify(tokenRepository, times(1)).deleteByUserId(userId);

        ArgumentCaptor<EmailVerificationToken> tokenCaptor = ArgumentCaptor.forClass(EmailVerificationToken.class);
        verify(tokenRepository, times(1)).save(tokenCaptor.capture());
        assertEquals(user, tokenCaptor.getValue().getUser());

        verify(emailService, times(1)).sendVerificationEmail(eq("candidat@ironpath.com"), any(String.class));
    }

    @Test
    void execute_shouldThrowException_whenEmailAlreadyVerified() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        assertThrows(IllegalArgumentException.class, () ->
                resendVerificationEmailUseCase.execute(userId)
        );
        verify(tokenRepository, never()).deleteByUserId(any());
        verify(emailService, never()).sendVerificationEmail(any(), any());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenUserNotFound() {
        UUID userId = UUID.randomUUID();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                resendVerificationEmailUseCase.execute(userId)
        );
    }
}
