package com.ironpath.backend.shared.infrastructure;

import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Component
public class HtmlTemplateRenderer {

    public String render(
            String classpathLocation,
            Map<String, String> variables
    ) {
        String template = load(classpathLocation);
        String rendered = template;

        for (Map.Entry<String, String> variable : variables.entrySet()) {
            rendered = rendered.replace(
                    "{{" + variable.getKey() + "}}",
                    variable.getValue()
            );
        }

        return rendered;
    }

    private String load(String classpathLocation) {
        ClassLoader classLoader = HtmlTemplateRenderer.class.getClassLoader();

        try (InputStream inputStream = classLoader.getResourceAsStream(
                classpathLocation
        )) {
            if (inputStream == null) {
                throw new IllegalStateException(
                        "Template HTML introuvable : " + classpathLocation
                );
            }
            return new String(
                    inputStream.readAllBytes(),
                    StandardCharsets.UTF_8
            );
        } catch (IOException exception) {
            throw new IllegalStateException(
                    "Impossible de lire le template HTML : "
                            + classpathLocation,
                    exception
            );
        }
    }
}
