package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
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

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CreateProgramUseCaseTest {

    @Mock
    private WorkoutProgramRepository programRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ProgramMapper programMapper;

    @Mock
    private EmailVerificationGuard emailVerificationGuard;

    @InjectMocks
    private CreateProgramUseCase createProgramUseCase;

    @Test
    void execute_shouldCreateProgram_whenValidRequest() {
        UUID userId = UUID.randomUUID();
        User user = User.builder()
                .id(userId)
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        CreateProgramRequest request = new CreateProgramRequest(
                "PPL - Push Pull Legs",
                "Programme 6 jours",
                List.of(new ProgramExerciseRequest(
                        "0001",
                        1,
                        true,
                        List.of(
                                new ProgramExerciseSetRequest(1, 8, 80.0, 120),
                                new ProgramExerciseSetRequest(2, 8, 80.0, 120),
                                new ProgramExerciseSetRequest(3, 8, 80.0, 120),
                                new ProgramExerciseSetRequest(4, 8, 80.0, 120)
                        )
                ))
        );

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(programRepository.save(any(WorkoutProgram.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(programMapper.toResponse(any(WorkoutProgram.class)))
                .thenReturn(new ProgramResponse(UUID.randomUUID(), "PPL", null, true, List.of(), null));

        ProgramResponse response = createProgramUseCase.execute(userId, request);

        assertNotNull(response);
        verify(programRepository).save(any(WorkoutProgram.class));
    }

    @Test
    void execute_shouldThrowUnauthorizedException_whenUserNotFound() {
        UUID userId = UUID.randomUUID();
        CreateProgramRequest request = new CreateProgramRequest("PPL", null, null);

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        assertThrows(UnauthorizedException.class, () ->
                createProgramUseCase.execute(userId, request)
        );
    }

    @Test
    void execute_shouldThrowIllegalArgumentException_whenExercisesNull() {
        UUID userId = UUID.randomUUID();
        User user = User.builder()
                .id(userId)
                .email("test@ironpath.com")
                .passwordHash("hashedPassword")
                .build();

        CreateProgramRequest request = new CreateProgramRequest("PPL", null, null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        assertThrows(IllegalArgumentException.class, () ->
                createProgramUseCase.execute(userId, request)
        );
    }
}