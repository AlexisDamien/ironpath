package com.ironpath.backend.identity.application;

import com.ironpath.backend.shared.infrastructure.AppProperties;
import com.ironpath.backend.shared.infrastructure.HtmlTemplateRenderer;
import jakarta.mail.Multipart;
import jakarta.mail.Part;
import jakarta.mail.Session;
import jakarta.mail.internet.MimeMessage;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;

import java.net.URI;
import java.util.Properties;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EmailServiceTest {

    @Mock
    private JavaMailSender mailSender;

    private EmailService emailService;

    @BeforeEach
    void setUp() {
        AppProperties appProperties = new AppProperties();
        appProperties.setPublicBaseUrl(URI.create("http://localhost:8080"));
        appProperties.getMail().setFrom("noreply@ironpath.com");

        emailService = new EmailService(
                mailSender,
                appProperties,
                new HtmlTemplateRenderer()
        );
    }

    @Test
    void sendVerificationEmail_shouldSendHtmlAndText_withClickableLink()
            throws Exception {
        String to = "candidat@ironpath.com";
        String token = "abc-123-token";
        MimeMessage message = newMessage();
        when(mailSender.createMimeMessage()).thenReturn(message);

        emailService.sendVerificationEmail(to, token);

        verify(mailSender, times(1)).send(message);
        message.saveChanges();
        assertEquals(to, message.getAllRecipients()[0].toString());
        assertTrue(message.getFrom()[0].toString().contains("noreply@ironpath.com"));
        assertEquals("Confirmez votre compte IronPath", message.getSubject());

        String html = findContent(message, "text/html");
        String text = findContent(message, "text/plain");
        assertTrue(html.contains("<a href=\"http://localhost:8080/api/auth/verify-email?token="));
        assertTrue(html.contains(token));
        assertTrue(text.contains("verify-email?token=" + token));
    }

    @Test
    void sendPasswordResetEmail_shouldSendHtmlAndText_withClickableLink()
            throws Exception {
        String to = "candidat@ironpath.com";
        String token = "reset-token";
        MimeMessage message = newMessage();
        when(mailSender.createMimeMessage()).thenReturn(message);

        emailService.sendPasswordResetEmail(to, token);

        verify(mailSender, times(1)).send(message);
        message.saveChanges();
        assertEquals(to, message.getAllRecipients()[0].toString());
        assertTrue(message.getFrom()[0].toString().contains("noreply@ironpath.com"));
        assertEquals(
                "Réinitialisez votre mot de passe IronPath",
                message.getSubject()
        );

        String html = findContent(message, "text/html");
        String text = findContent(message, "text/plain");
        assertTrue(html.contains("<a href=\"http://localhost:8080/api/auth/reset-password-page?token="));
        assertTrue(html.contains(token));
        assertTrue(text.contains("reset-password-page?token=" + token));
    }

    private static MimeMessage newMessage() {
        return new MimeMessage(Session.getInstance(new Properties()));
    }

    private static String findContent(Part part, String mimeType)
            throws Exception {
        if (part.isMimeType(mimeType)) {
            return (String) part.getContent();
        }
        if (part.isMimeType("multipart/*")) {
            Multipart multipart = (Multipart) part.getContent();
            for (int index = 0; index < multipart.getCount(); index++) {
                String content = findContent(
                        multipart.getBodyPart(index),
                        mimeType
                );
                if (!content.isEmpty()) {
                    return content;
                }
            }
        }
        return "";
    }
}
