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

    public void sendEmailChangeConfirmation(String to, String token) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Confirmez votre nouvel email IronPath");
        message.setText(
                "Bonjour,\n\n" +
                        "Une demande de changement d'adresse email a été effectuée sur votre compte IronPath.\n\n" +
                        "Cliquez sur le lien suivant pour confirmer votre nouvel email :\n\n" +
                        "http://localhost:8080/api/users/email/confirm/" + token + "\n\n" +
                        "Ce lien expire dans 24 heures.\n\n" +
                        "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.\n\n" +
                        "L'équipe IronPath"
        );
        message.setFrom("noreply@ironpath.com");
        mailSender.send(message);
    }

    public void sendEmailChangeCancellation(String to, String cancelToken, String newEmail) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Alerte sécurité — Changement d'email IronPath");
        message.setText(
                "Bonjour,\n\n" +
                        "Une demande de changement d'adresse email vers " + newEmail + " a été effectuée sur votre compte IronPath.\n\n" +
                        "Si vous êtes à l'origine de cette demande, vous n'avez rien à faire.\n\n" +
                        "Si vous n'êtes PAS à l'origine de cette demande, cliquez sur le lien suivant pour annuler immédiatement :\n\n" +
                        "http://localhost:8080/api/users/email/cancel/" + cancelToken + "\n\n" +
                        "Ce lien expire dans 24 heures.\n\n" +
                        "L'équipe IronPath"
        );
        message.setFrom("noreply@ironpath.com");
        mailSender.send(message);
    }
}