package com.ironpath.backend.identity.application;

import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    public void sendVerificationEmail(String to, String token) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Confirmez votre compte IronPath");
        message.setText(
                "Bonjour,\n\n" +
                        "Cliquez sur le lien suivant pour activer votre compte :\n\n" +
                        "http://localhost:8080/api/auth/verify-email?token=" + token + "\n\n" +
                        "Ce lien expire dans 24 heures.\n\n" +
                        "L'équipe IronPath"
        );
        message.setFrom("noreply@ironpath.com");
        mailSender.send(message);
    }
}