package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetProgramsUseCase {

    private final WorkoutProgramRepository programRepository;
    private final ProgramMapper programMapper;

    @Transactional(readOnly = true)
    public List<ProgramResponse> execute(UUID userId) {
        return programRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(programMapper::toResponse)
                .toList();
    }
}