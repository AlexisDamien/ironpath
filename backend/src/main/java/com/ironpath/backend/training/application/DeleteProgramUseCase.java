package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.training.domain.repository.WorkoutProgramRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeleteProgramUseCase {

    private final WorkoutProgramRepository programRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public void execute(UUID userId, UUID programId) {
        var program = programRepository.findById(programId)
                .orElseThrow(() -> new IllegalArgumentException("Programme introuvable"));

        if (!program.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Ce programme ne vous appartient pas");
        }
        emailVerificationGuard.check(program.getUser());

        programRepository.delete(program);
    }
}