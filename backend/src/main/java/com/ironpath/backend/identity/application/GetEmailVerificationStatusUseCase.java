package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.EmailVerificationStatusResponse;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetEmailVerificationStatusUseCase {

    private final UserRepository userRepository;

    public EmailVerificationStatusResponse execute(UUID userId) {
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));
        return new EmailVerificationStatusResponse(user.getEmailVerifiedAt() != null);
    }
}