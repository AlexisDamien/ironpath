package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class VerifyEmailUseCase {

    private final EmailVerificationTokenRepository tokenRepository;
    private final UserRepository userRepository;

    @Transactional
    public void execute(String token) {
        EmailVerificationToken verificationToken = tokenRepository
                .findByToken(token)
                .orElseThrow(() -> new IllegalArgumentException("Token invalide"));

        if (!verificationToken.isValid()) {
            throw new IllegalArgumentException("Token expiré ou déjà utilisé");
        }

        User user = verificationToken.getUser();
        user.setEmailVerifiedAt(java.time.LocalDateTime.now());
        userRepository.save(user);

        verificationToken.setUsed(true);
        tokenRepository.save(verificationToken);
    }
}