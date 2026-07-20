package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.ConsentRecordRepository;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNotNull;
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

    @Mock
    private JwtService jwtService;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private RegisterUserUseCase registerUserUseCase;

    @Test
    void execute_shouldRegisterUser_whenValidRequest() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "Password123!", true);

        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("hashedPassword");
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> {
            User savedUser = invocation.getArgument(0);
            savedUser.setId(UUID.randomUUID());
            return savedUser;
        });
        when(tokenRepository.save(any(EmailVerificationToken.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(jwtService.generateToken(any(UUID.class), anyString())).thenReturn("accessToken");
        when(refreshTokenRepository.save(any(RefreshToken.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        LoginResponse response = registerUserUseCase.execute(request, "127.0.0.1");

        assertNotNull(response);
        assertNotNull(response.token());
        assertNotNull(response.refreshToken());
        verify(userRepository).save(any(User.class));
        verify(tokenRepository).save(any(EmailVerificationToken.class));
        verify(emailService).sendVerificationEmail(anyString(), anyString());
    }

    @Test
    void execute_shouldThrowException_whenEmailAlreadyExists() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "Password123!", true);

        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        assertThrows(IllegalArgumentException.class, () ->
                registerUserUseCase.execute(request, "127.0.0.1")
        );

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void execute_shouldThrowException_whenRgpdConsentIsFalse() {
        RegisterRequest request = new RegisterRequest("test@ironpath.com", "Password123!", false);

        when(userRepository.existsByEmail(anyString())).thenReturn(false);

        assertThrows(IllegalArgumentException.class, () ->
                registerUserUseCase.execute(request, "127.0.0.1")
        );

        verify(userRepository, never()).save(any(User.class));
    }
}