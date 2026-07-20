package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.PasswordResetToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.PasswordResetTokenRepository;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ResetPasswordUseCase {

    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordResetTokenCodec tokenCodec;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;

    public ResetPasswordUseCase(
            PasswordResetTokenRepository tokenRepository,
            PasswordResetTokenCodec tokenCodec,
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            RefreshTokenRepository refreshTokenRepository
    ) {
        this.tokenRepository = tokenRepository;
        this.tokenCodec = tokenCodec;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.refreshTokenRepository = refreshTokenRepository;
    }

    @Transactional
    public void execute(String token, String newPassword) {
        PasswordPolicy.validateOrThrow(newPassword);

        String tokenHash = tokenCodec.hashToken(token);
        PasswordResetToken resetToken = tokenRepository
                .findByTokenHash(tokenHash)
                .orElseThrow(ResetPasswordUseCase::invalidToken);

        if (!resetToken.isValid()) {
            throw invalidToken();
        }

        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        resetToken.setUsed(true);
        tokenRepository.save(resetToken);
        refreshTokenRepository.revokeAllByUserId(user.getId());
    }

    private static IllegalArgumentException invalidToken() {
        return new IllegalArgumentException(
                "Le lien de réinitialisation est invalide ou expiré"
        );
    }
}
