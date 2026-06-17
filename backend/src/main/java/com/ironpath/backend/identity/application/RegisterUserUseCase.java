package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.domain.model.ConsentRecord;
import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.ConsentRecordRepository;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RegisterUserUseCase {

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final ConsentRecordRepository consentRecordRepository;

    @Transactional
    public void execute(RegisterRequest request, String ipAdress) {

        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Un compte existe déjà avec cet email");
        }

        if (!request.rgpdConsent()) {
            throw new IllegalArgumentException("Le consentement RGPD est obligatoire");
        }
        User user = User.builder()
                .email(request.email().toLowerCase().trim())
                .passwordHash(passwordEncoder.encode(request.password()))
                .build();
        userRepository.save(user);

        ConsentRecord consent = ConsentRecord.builder()
                .user(user)
                .consentType("RGPD_HEALTH_DATA")
                .ipAddress(ipAdress)
                .build();
        consentRecordRepository.save(consent);

        String token = UUID.randomUUID().toString();
        EmailVerificationToken verificationToken = EmailVerificationToken.builder()
                .user(user)
                .token(token)
                .build();

        tokenRepository.save(verificationToken);
        emailService.sendVerificationEmail(user.getEmail(), token);
    }
}