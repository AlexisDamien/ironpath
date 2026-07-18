package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DeleteProgramUseCaseTest {

    @Mock
    private WorkoutProgramRepository programRepository;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private DeleteProgramUseCase deleteProgramUseCase;

    @Test
    void execute_shouldDeleteProgram_whenOwnerRequests() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();

        User user = User.builder().id(userId).build();
        WorkoutProgram program = WorkoutProgram.builder()
                .id(programId)
                .user(user)
                .name("PPL")
                .build();

        when(programRepository.findById(programId)).thenReturn(Optional.of(program));

        deleteProgramUseCase.execute(userId, programId);

        verify(programRepository).delete(program);
    }

    @Test
    void execute_shouldThrowException_whenProgramNotFound() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();

        when(programRepository.findById(programId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                deleteProgramUseCase.execute(userId, programId)
        );

        verify(programRepository, never()).delete(any(WorkoutProgram.class));    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenNotOwner() {
        UUID userId = UUID.randomUUID();
        UUID otherUserId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();

        User otherUser = User.builder().id(otherUserId).build();
        WorkoutProgram program = WorkoutProgram.builder()
                .id(programId)
                .user(otherUser)
                .name("PPL")
                .build();

        when(programRepository.findById(programId)).thenReturn(Optional.of(program));

        assertThrows(UnauthorizedException.class, () ->
                deleteProgramUseCase.execute(userId, programId)
        );

        verify(programRepository, never()).delete(program);
    }
}