package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.repository.EmailChangeRequestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class CancelEmailChangeUseCase {

    private final EmailChangeRequestRepository emailChangeRequestRepository;

    @Transactional
    public void execute(String token) {
        var request = emailChangeRequestRepository.findByCancelToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Token invalide"));

        if (request.isCancelled()) {
            throw new IllegalArgumentException("Ce changement a déjà été annulé");
        }
        if (request.isConfirmed()) {
            throw new IllegalArgumentException("Ce changement a déjà été confirmé");
        }

        request.setCancelled(true);
        emailChangeRequestRepository.save(request);
    }
}