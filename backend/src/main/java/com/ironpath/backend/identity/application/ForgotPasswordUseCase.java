package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.domain.model.PasswordResetToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.PasswordResetTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ForgotPasswordUseCase {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final PasswordResetTokenCodec tokenCodec;
    private final EmailService emailService;

    @Transactional
    public void execute(String email) {
        String normalizedEmail = email.toLowerCase(Locale.ROOT).trim();
        Optional<User> optionalUser = userRepository.findByEmail(normalizedEmail);

        if (optionalUser.isEmpty()) {
            return;
        }

        User user = optionalUser.get();
        tokenRepository.deleteByUserId(user.getId());
        tokenRepository.flush();

        String rawToken = tokenCodec.generateToken();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash(tokenCodec.hashToken(rawToken))
                .build();

        tokenRepository.save(resetToken);
        emailService.sendPasswordResetEmail(user.getEmail(), rawToken);
    }
}
