package com.ironpath.backend.shared.infrastructure;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class HtmlTemplateRendererTest {

    private HtmlTemplateRenderer renderer;

    @BeforeEach
    void setUp() {
        renderer = new HtmlTemplateRenderer();
    }

    @Test
    void render_shouldSubstituteAllVariables() {
        String result = renderer.render(
                "templates/test-template.html",
                Map.of("name", "Alexis", "code", "123456")
        );

        assertTrue(result.contains("Bonjour Alexis,"));
        assertTrue(result.contains("Votre code est 123456."));
        assertFalse(result.contains("{{name}}"));
        assertFalse(result.contains("{{code}}"));
    }

    @Test
    void render_shouldLeavePlaceholder_whenVariableNotProvided() {
        String result = renderer.render(
                "templates/test-template.html",
                Map.of("name", "Alexis")
        );

        assertTrue(result.contains("Bonjour Alexis,"));
        assertTrue(result.contains("{{code}}"));
    }

    @Test
    void render_shouldReturnTemplateUnchanged_whenNoVariablesProvided() {
        String result = renderer.render("templates/test-template.html", Map.of());

        assertTrue(result.contains("{{name}}"));
        assertTrue(result.contains("{{code}}"));
    }

    @Test
    void render_shouldThrowIllegalStateException_whenTemplateNotFound() {
        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> renderer.render("templates/does-not-exist.html", Map.of())
        );

        assertTrue(exception.getMessage().contains("templates/does-not-exist.html"));
    }
}
