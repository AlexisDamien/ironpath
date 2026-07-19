package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.training.api.dto.CreateProgramRequest;
import com.ironpath.backend.training.api.dto.ProgramExerciseRequest;
import com.ironpath.backend.training.api.dto.ProgramExerciseSetRequest;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UpdateProgramUseCaseTest {

    @Mock
    private WorkoutProgramRepository programRepository;

    @Mock
    private ProgramMapper programMapper;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private UpdateProgramUseCase updateProgramUseCase;

    @Test
    void execute_shouldUpdateNameAndDescription_whenExercisesNotProvided() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        WorkoutProgram existing = WorkoutProgram.builder()
                .id(programId).user(user).name("Ancien nom").description("Ancienne description")
                .exercises(new java.util.ArrayList<>()).build();

        CreateProgramRequest request = new CreateProgramRequest("Nouveau nom", "Nouvelle description", null);

        when(programRepository.findById(programId)).thenReturn(Optional.of(existing));
        when(programRepository.save(any(WorkoutProgram.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(programMapper.toResponse(any(WorkoutProgram.class)))
                .thenReturn(new ProgramResponse(programId, "Nouveau nom", "Nouvelle description", true, List.of(), null));

        ProgramResponse response = updateProgramUseCase.execute(userId, programId, request);

        assertEquals("Nouveau nom", response.name());
        assertEquals("Nouvelle description", response.description());
    }

    @Test
    void execute_shouldReplaceExercises_whenExercisesProvided() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        WorkoutProgram existing = WorkoutProgram.builder()
                .id(programId).user(user).name("PPL")
                .exercises(new java.util.ArrayList<>()).build();

        CreateProgramRequest request = new CreateProgramRequest(
                null, null,
                List.of(new ProgramExerciseRequest(
                        "0001", 1, true,
                        List.of(new ProgramExerciseSetRequest(1, 8, 80.0, 120, false))
                ))
        );

        when(programRepository.findById(programId)).thenReturn(Optional.of(existing));
        when(programRepository.save(any(WorkoutProgram.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(programMapper.toResponse(any(WorkoutProgram.class)))
                .thenReturn(new ProgramResponse(programId, "PPL", null, true, List.of(), null));

        ProgramResponse response = updateProgramUseCase.execute(userId, programId, request);

        assertNotNull(response);
        assertEquals(1, existing.getExercises().size());
        assertEquals("0001", existing.getExercises().getFirst().getExerciseId());
    }

    @Test
    void execute_shouldThrowException_whenExercisesListIsEmpty() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        WorkoutProgram existing = WorkoutProgram.builder()
                .id(programId).user(user).name("PPL")
                .exercises(new java.util.ArrayList<>()).build();

        CreateProgramRequest request = new CreateProgramRequest(null, null, List.of());

        when(programRepository.findById(programId)).thenReturn(Optional.of(existing));

        assertThrows(IllegalArgumentException.class, () ->
                updateProgramUseCase.execute(userId, programId, request)
        );
        verify(programRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowException_whenExerciseHasNoSets() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        WorkoutProgram existing = WorkoutProgram.builder()
                .id(programId).user(user).name("PPL")
                .exercises(new java.util.ArrayList<>()).build();

        CreateProgramRequest request = new CreateProgramRequest(
                null, null,
                List.of(new ProgramExerciseRequest("0001", 1, true, List.of()))
        );

        when(programRepository.findById(programId)).thenReturn(Optional.of(existing));

        assertThrows(IllegalArgumentException.class, () ->
                updateProgramUseCase.execute(userId, programId, request)
        );
        verify(programRepository, never()).save(any());
    }

    @Test
    void execute_shouldThrowException_whenProgramNotFound() {
        UUID userId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        CreateProgramRequest request = new CreateProgramRequest("Nom", null, null);

        when(programRepository.findById(programId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () ->
                updateProgramUseCase.execute(userId, programId, request)
        );
    }

    @Test
    void execute_shouldThrowUnauthorized_whenProgramBelongsToAnotherUser() {
        UUID userId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        UUID programId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        WorkoutProgram existing = WorkoutProgram.builder().id(programId).user(owner).build();
        CreateProgramRequest request = new CreateProgramRequest("Nom", null, null);

        when(programRepository.findById(programId)).thenReturn(Optional.of(existing));

        UnauthorizedException exception = assertThrows(UnauthorizedException.class, () ->
                updateProgramUseCase.execute(userId, programId, request)
        );
        assertEquals("Ce programme ne vous appartient pas", exception.getMessage());
        verify(programRepository, never()).save(any());
    }
}
