package com.ironpath.backend.training.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.model.WorkoutProgram;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetProgramsUseCaseTest {

    @Mock
    private WorkoutProgramRepository programRepository;

    @Mock
    private ProgramMapper programMapper;

    @InjectMocks
    private GetProgramsUseCase getProgramsUseCase;

    @Test
    void execute_shouldReturnMappedPrograms_whenProgramsExist() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        WorkoutProgram program = WorkoutProgram.builder().id(UUID.randomUUID()).user(user).name("PPL").build();
        ProgramResponse expectedResponse = new ProgramResponse(program.getId(), "PPL", null, true, List.of(), null);

        when(programRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(List.of(program));
        when(programMapper.toResponse(program)).thenReturn(expectedResponse);

        List<ProgramResponse> responses = getProgramsUseCase.execute(userId);

        assertEquals(1, responses.size());
        assertEquals(expectedResponse, responses.getFirst());
    }

    @Test
    void execute_shouldReturnEmptyList_whenNoProgramsExist() {
        UUID userId = UUID.randomUUID();

        when(programRepository.findByUserIdOrderByCreatedAtDesc(userId)).thenReturn(List.of());

        List<ProgramResponse> responses = getProgramsUseCase.execute(userId);

        assertTrue(responses.isEmpty());
    }
}
