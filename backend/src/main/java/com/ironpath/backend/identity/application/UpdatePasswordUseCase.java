package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdatePasswordUseCase {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public void execute(
            UUID userId,
            String currentPassword,
            String newPassword
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() ->
                        new UnauthorizedException("Utilisateur introuvable")
                );
        emailVerificationGuard.check(user);

        if (!passwordEncoder.matches(
                currentPassword,
                user.getPasswordHash()
        )) {
            throw new IllegalArgumentException(
                    "Mot de passe actuel incorrect"
            );
        }

        PasswordPolicy.validateOrThrow(newPassword);

        user.setPasswordHash(
                passwordEncoder.encode(newPassword)
        );

        userRepository.save(user);

        refreshTokenRepository.revokeAllByUserId(userId);
    }
}