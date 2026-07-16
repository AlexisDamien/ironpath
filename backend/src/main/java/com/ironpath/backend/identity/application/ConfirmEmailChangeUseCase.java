package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.repository.EmailChangeRequestRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ConfirmEmailChangeUseCase {

    private final EmailChangeRequestRepository emailChangeRequestRepository;
    private final UserRepository userRepository;

    @Transactional
    public void execute(String token) {
        var request = emailChangeRequestRepository.findByConfirmationToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Token invalide"));

        if (request.isCancelled()) {
            throw new IllegalArgumentException("Ce changement a été annulé");
        }
        if (request.isConfirmed()) {
            throw new IllegalArgumentException("Ce changement a déjà été confirmé");
        }
        if (request.getExpiresAt().isBefore(java.time.LocalDateTime.now())) {
            throw new IllegalArgumentException("Ce lien a expiré");
        }

        var user = request.getUser();
        user.setEmail(request.getNewEmail());
        user.setEmailVerifiedAt(java.time.LocalDateTime.now());
        userRepository.save(user);

        request.setConfirmed(true);
        emailChangeRequestRepository.save(request);
    }
}