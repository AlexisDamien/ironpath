package com.ironpath.backend.shared.infrastructure;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void handleIllegalArgument_shouldReturn400WithMessage() {
        IllegalArgumentException exception = new IllegalArgumentException("Argument invalide");

        ResponseEntity<Map<String, String>> response = handler.handleIllegalArgument(exception);

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Argument invalide", response.getBody().get("error"));
    }

    @Test
    void handleUnauthorized_shouldReturn401WithMessage() {
        UnauthorizedException exception = new UnauthorizedException("Email ou mot de passe incorrect");

        ResponseEntity<Map<String, String>> response = handler.handleUnauthorized(exception);

        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Email ou mot de passe incorrect", response.getBody().get("error"));
    }

    @Test
    void handleTooManyAttempts_shouldReturn429WithMessage() {
        TooManyAttemptsException exception = new TooManyAttemptsException(
                "Trop de tentatives de connexion. Réessayez dans quelques minutes."
        );

        ResponseEntity<Map<String, String>> response = handler.handleTooManyAttempts(exception);

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(
                "Trop de tentatives de connexion. Réessayez dans quelques minutes.",
                response.getBody().get("error")
        );
    }
}
