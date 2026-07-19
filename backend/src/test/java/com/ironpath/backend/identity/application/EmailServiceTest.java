package com.ironpath.backend.identity.application;

import com.ironpath.backend.shared.infrastructure.AppProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import java.net.URI;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

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

        emailService = new EmailService(mailSender, appProperties);
    }

    @Test
    void sendVerificationEmail_shouldSendMessage_withTokenLinkAndCorrectRecipient() {
        String to = "candidat@ironpath.com";
        String token = "abc-123-token";

        emailService.sendVerificationEmail(to, token);

        ArgumentCaptor<SimpleMailMessage> captor = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender, times(1)).send(captor.capture());

        SimpleMailMessage sent = captor.getValue();
        assert sent.getTo() != null;
        assertEquals(to, sent.getTo()[0]);
        assertEquals("noreply@ironpath.com", sent.getFrom());
        assertEquals("Confirmez votre compte IronPath", sent.getSubject());
        assert sent.getText() != null;
        assertTrue(sent.getText().contains(token));
        assertTrue(sent.getText().contains("verify-email?token=" + token));
    }
}