package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.EmailChangeRequest;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailChangeRequestRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdateEmailUseCase {

    private final UserRepository userRepository;
    private final EmailChangeRequestRepository emailChangeRequestRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    public void execute(UUID userId, String currentPassword, String newEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new UnauthorizedException("Mot de passe incorrect");
        }

        if (userRepository.existsByEmail(newEmail.toLowerCase().trim())) {
            throw new IllegalArgumentException("Cet email est déjà utilisé");
        }

        String confirmationToken = UUID.randomUUID().toString();
        String cancelToken = UUID.randomUUID().toString();

        EmailChangeRequest request = EmailChangeRequest.builder()
                .user(user)
                .oldEmail(user.getEmail())
                .newEmail(newEmail.toLowerCase().trim())
                .confirmationToken(confirmationToken)
                .cancelToken(cancelToken)
                .expiresAt(LocalDateTime.now().plusHours(24))
                .confirmed(false)
                .cancelled(false)
                .build();

        saveRequest(request);

        emailService.sendEmailChangeConfirmation(newEmail, confirmationToken);
        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        emailService.sendEmailChangeCancellation(user.getEmail(), cancelToken, newEmail);
    }

    @Transactional
    protected void saveRequest(EmailChangeRequest request) {
        emailChangeRequestRepository.save(request);
    }
}