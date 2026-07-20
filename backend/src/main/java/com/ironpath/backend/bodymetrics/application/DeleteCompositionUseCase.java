package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeleteCompositionUseCase {

    private final BodyCompositionRepository compositionRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public void execute(UUID userId, UUID compositionId) {
        var composition = compositionRepository.findById(compositionId)
                .orElseThrow(() -> new IllegalArgumentException("Composition introuvable"));

        if (!composition.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Cette composition ne vous appartient pas");
        }
        emailVerificationGuard.check(composition.getUser());

        compositionRepository.delete(composition);
    }
}