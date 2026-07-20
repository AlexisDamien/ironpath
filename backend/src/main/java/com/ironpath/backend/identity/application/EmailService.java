package com.ironpath.backend.identity.application;

import com.ironpath.backend.shared.infrastructure.AppProperties;
import com.ironpath.backend.shared.infrastructure.HtmlTemplateRenderer;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.mail.MailException;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.web.util.HtmlUtils;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Service
public class EmailService {

    private static final Logger LOGGER = LoggerFactory.getLogger(
            EmailService.class
    );
    private static final String VERIFICATION_TEMPLATE =
            "templates/email/verification.html";
    private static final String PASSWORD_RESET_TEMPLATE =
            "templates/email/password-reset.html";

    private final JavaMailSender mailSender;
    private final AppProperties appProperties;
    private final HtmlTemplateRenderer templateRenderer;

    public EmailService(
            JavaMailSender mailSender,
            AppProperties appProperties,
            HtmlTemplateRenderer templateRenderer
    ) {
        this.mailSender = mailSender;
        this.appProperties = appProperties;
        this.templateRenderer = templateRenderer;
    }

    public void sendVerificationEmail(
            String to,
            String token
    ) {
        validateConfiguration();

        String verificationUrl = buildUrl(
                "/api/auth/verify-email",
                token
        );
        String plainText = "Bonjour,\n\n"
                + "Confirmez votre adresse email pour activer votre compte "
                + "IronPath :\n"
                + verificationUrl
                + "\n\nCe lien expire dans 24 heures.\n\n"
                + "Si vous n'avez pas créé de compte IronPath, "
                + "ignorez simplement cet email.\n\n"
                + "L'équipe IronPath";
        String html = templateRenderer.render(
                VERIFICATION_TEMPLATE,
                Map.of("ACTION_URL", HtmlUtils.htmlEscape(verificationUrl))
        );

        sendHtmlEmail(
                to,
                "Confirmez votre compte IronPath",
                plainText,
                html
        );
    }

    public void sendPasswordResetEmail(
            String to,
            String token
    ) {
        validateConfiguration();

        String resetUrl = buildUrl(
                "/api/auth/reset-password-page",
                token
        );
        String plainText = "Bonjour,\n\n"
                + "Une réinitialisation de votre mot de passe IronPath "
                + "a été demandée.\n\n"
                + "Choisissez un nouveau mot de passe ici :\n"
                + resetUrl
                + "\n\nCe lien expire dans 30 minutes et ne peut être "
                + "utilisé qu'une seule fois.\n\n"
                + "Si vous n'êtes pas à l'origine de cette demande, "
                + "ignorez simplement cet email.\n\n"
                + "L'équipe IronPath";
        String html = templateRenderer.render(
                PASSWORD_RESET_TEMPLATE,
                Map.of("ACTION_URL", HtmlUtils.htmlEscape(resetUrl))
        );

        sendHtmlEmail(
                to,
                "Réinitialisez votre mot de passe IronPath",
                plainText,
                html
        );
    }

    private String buildUrl(String path, String token) {
        return UriComponentsBuilder
                .fromUriString(appProperties.getPublicBaseUrl().toString())
                .path(path)
                .queryParam("token", token)
                .build()
                .toUriString();
    }

    private void sendHtmlEmail(
            String to,
            String subject,
            String plainText,
            String html
    ) {
        MimeMessage message = mailSender.createMimeMessage();
        String from = appProperties.getMail().getFrom().trim();

        try {
            MimeMessageHelper helper = new MimeMessageHelper(
                    message,
                    true,
                    StandardCharsets.UTF_8.name()
            );
            helper.setValidateAddresses(true);
            helper.setTo(to.trim());
            helper.setFrom(from, "IronPath");
            helper.setReplyTo(from, "IronPath");
            helper.setSubject(subject);
            helper.setSentDate(new Date());
            helper.setText(plainText, html);

            message.saveChanges();
            mailSender.send(message);

            LOGGER.info(
                    "Email '{}' accepté par le serveur SMTP pour {} "
                            + "(messageId={})",
                    subject,
                    maskEmail(to),
                    message.getMessageID()
            );
        } catch (MessagingException | UnsupportedEncodingException exception) {
            LOGGER.error(
                    "Impossible de préparer l'email '{}' pour {}",
                    subject,
                    maskEmail(to),
                    exception
            );
            throw new IllegalStateException(
                    "Impossible de préparer l'email IronPath.",
                    exception
            );
        } catch (MailException exception) {
            LOGGER.error(
                    "Le serveur SMTP a refusé l'email '{}' pour {}",
                    subject,
                    maskEmail(to),
                    exception
            );
            throw new IllegalStateException(
                    "Impossible d'envoyer l'email IronPath.",
                    exception
            );
        }
    }

    private String maskEmail(String email) {
        int separatorIndex = email.indexOf('@');
        if (separatorIndex <= 1) {
            return "***";
        }
        return email.charAt(0)
                + "***"
                + email.substring(separatorIndex);
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
