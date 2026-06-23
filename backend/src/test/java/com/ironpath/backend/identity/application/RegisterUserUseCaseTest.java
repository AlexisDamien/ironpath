package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.ConsentRecordRepository;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RegisterUserUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailVerificationTokenRepository tokenRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private EmailService emailService;

    @Mock
    private ConsentRecordRepository consentRecordRepository;

    @InjectMocks
    private RegisterUserUseCase registerUserUseCase;

    @Test
    void execute_shouldRegisterUser_whenValidRequest() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "password123", true);

        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("hashedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(tokenRepository.save(any(EmailVerificationToken.class))).thenAnswer(invocation -> invocation.getArgument(0));

        registerUserUseCase.execute(request, "127.0.0.1");

        verify(userRepository).save(any(User.class));
        verify(tokenRepository).save(any(EmailVerificationToken.class));
        verify(emailService).sendVerificationEmail(anyString(), anyString());
    }

    @Test
    void execute_shouldThrowException_whenEmailAlreadyExists() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "password123", true);

        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        assertThrows(IllegalArgumentException.class, () ->
                registerUserUseCase.execute(request, "127.0.0.1")
        );

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void execute_shouldThrowException_whenRgpdConsentIsFalse() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "password123", false);

        when(userRepository.existsByEmail(anyString())).thenReturn(false);

        assertThrows(IllegalArgumentException.class, () ->
                registerUserUseCase.execute(request, "127.0.0.1")
        );

        verify(userRepository, never()).save(any(User.class));
    }
}