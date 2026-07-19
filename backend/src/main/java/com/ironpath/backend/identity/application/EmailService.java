package com.ironpath.backend.identity.application;

import com.ironpath.backend.shared.infrastructure.AppProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final AppProperties appProperties;

    public void sendVerificationEmail(
            String to,
            String token
    ) {
        validateConfiguration();

        String verificationUrl = UriComponentsBuilder
                .fromUriString(
                        appProperties
                                .getPublicBaseUrl()
                                .toString()
                )
                .path("/api/auth/verify-email")
                .queryParam("token", token)
                .build()
                .toUriString();

        SimpleMailMessage message = new SimpleMailMessage();

        message.setTo(to);
        message.setFrom(appProperties.getMail().getFrom());
        message.setSubject("Confirmez votre compte IronPath");
        message.setText(
                "Bonjour,\n\n"
                        + "Cliquez sur le lien suivant "
                        + "pour activer votre compte :\n\n"
                        + verificationUrl
                        + "\n\n"
                        + "Ce lien expire dans 24 heures.\n\n"
                        + "L'équipe IronPath"
        );

        mailSender.send(message);
    }

    private void validateConfiguration() {
        if (appProperties.getPublicBaseUrl() == null) {
            throw new IllegalStateException(
                    "La propriété app.public-base-url "
                            + "n'est pas configurée."
            );
        }

        String from = appProperties.getMail().getFrom();

        if (from == null || from.isBlank()) {
            throw new IllegalStateException(
                    "La propriété app.mail.from "
                            + "n'est pas configurée."
            );
        }
    }
}