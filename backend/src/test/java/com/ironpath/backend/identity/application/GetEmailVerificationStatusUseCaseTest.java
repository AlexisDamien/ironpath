package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.EmailVerificationStatusResponse;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetEmailVerificationStatusUseCaseTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private GetEmailVerificationStatusUseCase getEmailVerificationStatusUseCase;

    @Test
    void execute_shouldReturnTrue_whenEmailVerified() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        EmailVerificationStatusResponse response = getEmailVerificationStatusUseCase.execute(userId);

        assertTrue(response.emailVerified());
    }

    @Test
    void execute_shouldReturnFalse_whenEmailNotVerified() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(null).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        EmailVerificationStatusResponse response = getEmailVerificationStatusUseCase.execute(userId);

        assertFalse(response.emailVerified());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenUserNotFound() {
        UUID userId = UUID.randomUUID();

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                getEmailVerificationStatusUseCase.execute(userId)
        );
    }
}
