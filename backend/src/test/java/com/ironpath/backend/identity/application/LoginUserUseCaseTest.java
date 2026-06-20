package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
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

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LoginUserUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @InjectMocks
    private LoginUserUseCase loginUserUseCase;

    @Test
    void execute_shouldReturnTokens_whenValidCredentials() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .emailVerifiedAt(LocalDateTime.now())
                .build();

        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);
        when(jwtService.generateToken(any(UUID.class), anyString())).thenReturn("accessToken");
        when(refreshTokenRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        LoginResponse response = loginUserUseCase.execute("test@ironpath.com", "password123");

        assertNotNull(response.token());
        assertNotNull(response.refreshToken());
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenUserNotFound() {
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                loginUserUseCase.execute("unknown@ironpath.com", "password123")
        );
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenWrongPassword() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .emailVerifiedAt(LocalDateTime.now())
                .build();

        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(false);

        assertThrows(UnauthorizedException.class, () ->
                loginUserUseCase.execute("test@ironpath.com", "wrongpassword")
        );
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenEmailNotVerified() {
        User user = User.builder()
                .id(UUID.randomUUID())
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .emailVerifiedAt(null)
                .build();

        when(userRepository.findByEmail(anyString())).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(anyString(), anyString())).thenReturn(true);

        assertThrows(UnauthorizedException.class, () ->
                loginUserUseCase.execute("test@ironpath.com", "password123")
        );
    }
}