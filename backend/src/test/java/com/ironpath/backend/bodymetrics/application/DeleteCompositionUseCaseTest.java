package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DeleteCompositionUseCaseTest {

    @Mock
    private BodyCompositionRepository compositionRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private DeleteCompositionUseCase deleteCompositionUseCase;

    @Test
    void execute_shouldDeleteComposition_whenOwnedByUserAndVerified() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(LocalDateTime.now()).build();
        BodyComposition composition = BodyComposition.builder().id(compositionId).user(user).build();

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(composition));

        deleteCompositionUseCase.execute(userId, compositionId);

        verify(compositionRepository, times(1)).delete(composition);
    }

    @Test
    void execute_shouldThrowException_whenCompositionNotFound() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                deleteCompositionUseCase.execute(userId, compositionId)
        );
        verify(compositionRepository, never()).delete(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void execute_shouldThrowUnauthorized_whenCompositionBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        BodyComposition composition = BodyComposition.builder().id(compositionId).user(owner).build();

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(composition));

        UnauthorizedException exception = assertThrows(UnauthorizedException.class, () ->
                deleteCompositionUseCase.execute(userId, compositionId)
        );
        assertEquals("Cette composition ne vous appartient pas", exception.getMessage());
        verify(compositionRepository, never()).delete(org.mockito.ArgumentMatchers.any());
    }

    @Test
    void execute_shouldThrowException_whenEmailNotVerified() {
        UUID userId = UUID.randomUUID();
        UUID compositionId = UUID.randomUUID();
        User user = User.builder().id(userId).emailVerifiedAt(null).build();
        BodyComposition composition = BodyComposition.builder().id(compositionId).user(user).build();

        when(compositionRepository.findById(compositionId)).thenReturn(Optional.of(composition));
        org.mockito.Mockito.doThrow(new UnauthorizedException("Veuillez vérifier votre email avant d'effectuer cette action"))
                .when(emailVerificationGuard).check(user);

        assertThrows(UnauthorizedException.class, () ->
                deleteCompositionUseCase.execute(userId, compositionId)
        );
        verify(compositionRepository, never()).delete(org.mockito.ArgumentMatchers.any());
    }
}
