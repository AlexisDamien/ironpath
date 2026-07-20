package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.PasswordResetToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.PasswordResetTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ForgotPasswordUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordResetTokenRepository tokenRepository;

    @Mock
    private PasswordResetTokenCodec tokenCodec;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private ForgotPasswordUseCase forgotPasswordUseCase;

    @Test
    void execute_shouldCreateTokenAndSendEmail_whenUserExists() {
        UUID userId = UUID.randomUUID();
        User user = User.builder()
                .id(userId)
                .email("user@ironpath.com")
                .build();

        when(userRepository.findByEmail("user@ironpath.com"))
                .thenReturn(Optional.of(user));
        when(tokenCodec.generateToken()).thenReturn("raw-token");
        when(tokenCodec.hashToken("raw-token")).thenReturn("hashed-token");

        forgotPasswordUseCase.execute("  USER@ironpath.com ");

        verify(tokenRepository, times(1)).deleteByUserId(userId);
        verify(tokenRepository, times(1)).flush();

        ArgumentCaptor<PasswordResetToken> captor =
                ArgumentCaptor.forClass(PasswordResetToken.class);
        verify(tokenRepository, times(1)).save(captor.capture());
        assertEquals(user, captor.getValue().getUser());
        assertEquals("hashed-token", captor.getValue().getTokenHash());
        verify(emailService, times(1))
                .sendPasswordResetEmail("user@ironpath.com", "raw-token");
    }

    @Test
    void execute_shouldReturnGenericSuccess_withoutSendingEmail_whenUserMissing() {
        when(userRepository.findByEmail("missing@ironpath.com"))
                .thenReturn(Optional.empty());

        forgotPasswordUseCase.execute("missing@ironpath.com");

        verify(tokenRepository, never()).save(any());
        verify(emailService, never()).sendPasswordResetEmail(
                anyString(),
                anyString()
        );
    }
}
