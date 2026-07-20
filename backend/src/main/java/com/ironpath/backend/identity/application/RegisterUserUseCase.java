package com.ironpath.backend.identity.application;

import com.ironpath.backend.identity.api.dto.LoginResponse;
import com.ironpath.backend.identity.api.dto.RegisterRequest;
import com.ironpath.backend.identity.domain.model.ConsentRecord;
import com.ironpath.backend.identity.domain.model.EmailVerificationToken;
import com.ironpath.backend.identity.domain.model.RefreshToken;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.ConsentRecordRepository;
import com.ironpath.backend.identity.domain.repository.EmailVerificationTokenRepository;
import com.ironpath.backend.identity.domain.repository.RefreshTokenRepository;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.shared.infrastructure.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RegisterUserUseCase {

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;
    private final ConsentRecordRepository consentRecordRepository;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional
    public LoginResponse execute(RegisterRequest request, String ipAddress) {
        String normalizedEmail = request.email()
                .toLowerCase(Locale.ROOT)
                .trim();

        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException(
                    "Un compte existe déjà avec cet email"
            );
        }

        PasswordPolicy.validateOrThrow(request.password());

        if (!request.rgpdConsent()) {
            throw new IllegalArgumentException(
                    "Le consentement RGPD est obligatoire"
            );
        }

        User user = User.builder()
                .email(normalizedEmail)
                .passwordHash(passwordEncoder.encode(request.password()))
                .build();
        userRepository.save(user);

        ConsentRecord consent = ConsentRecord.builder()
                .user(user)
                .consentType("RGPD_HEALTH_DATA")
                .ipAddress(ipAddress)
                .build();
        consentRecordRepository.save(consent);

        String verificationTokenValue = UUID.randomUUID().toString();
        EmailVerificationToken verificationToken =
                EmailVerificationToken.builder()
                        .user(user)
                        .token(verificationTokenValue)
                        .build();

        tokenRepository.save(verificationToken);
        emailService.sendVerificationEmail(
                user.getEmail(),
                verificationTokenValue
        );

        String jwt = jwtService.generateToken(
                user.getId(),
                user.getEmail()
        );

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .build();
        refreshTokenRepository.save(refreshToken);

        return new LoginResponse(
                jwt,
                refreshToken.getToken(),
                false
        );
    }
}
