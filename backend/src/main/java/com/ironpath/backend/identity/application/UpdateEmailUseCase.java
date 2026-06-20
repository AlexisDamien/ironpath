package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdateEmailUseCase {

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

    @Transactional
    public void execute(UUID userId, String currentPassword, String newEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UnauthorizedException("Utilisateur introuvable"));

        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            throw new UnauthorizedException("Mot de passe incorrect");
        }

        if (userRepository.existsByEmail(newEmail.toLowerCase().trim())) {
            throw new IllegalArgumentException("Cet email est déjà utilisé");
        }

        user.setEmail(newEmail.toLowerCase().trim());
        user.setEmailVerifiedAt(null);
        userRepository.save(user);

        String token = UUID.randomUUID().toString();
        EmailVerificationToken verificationToken = EmailVerificationToken.builder()
                .user(user)
                .token(token)
                .build();
        tokenRepository.save(verificationToken);

        emailService.sendVerificationEmail(newEmail, token);
    }
}