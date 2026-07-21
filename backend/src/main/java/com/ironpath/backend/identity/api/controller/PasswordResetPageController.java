package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.application.PasswordPolicy;
import com.ironpath.backend.identity.application.ResetPasswordUseCase;
import com.ironpath.backend.shared.infrastructure.HtmlTemplateRenderer;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.util.HtmlUtils;

import java.util.Map;

@Controller
public class PasswordResetPageController {

    private static final String FORM_TEMPLATE =
            "templates/password-reset/form.html";
    private static final String SUCCESS_TEMPLATE =
            "templates/password-reset/success.html";

    private final ResetPasswordUseCase resetPasswordUseCase;
    private final HtmlTemplateRenderer templateRenderer;

    public PasswordResetPageController(
            ResetPasswordUseCase resetPasswordUseCase,
            HtmlTemplateRenderer templateRenderer
    ) {
        this.resetPasswordUseCase = resetPasswordUseCase;
        this.templateRenderer = templateRenderer;
    }

    @GetMapping(
            value = "/api/auth/reset-password-page",
            produces = MediaType.TEXT_HTML_VALUE
    )
    public ResponseEntity<String> resetPasswordPage(@RequestParam String token) {
        return htmlResponse(renderForm(token, null));
    }

    @PostMapping(
            value = "/api/auth/reset-password-form",
            consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE,
            produces = MediaType.TEXT_HTML_VALUE
    )
    public ResponseEntity<String> submitResetPassword(
            @RequestParam String token,
            @RequestParam String newPassword,
            @RequestParam String confirmPassword
    ) {
        String validationError = validatePasswords(
                newPassword,
                confirmPassword
        );
        if (validationError != null) {
            return htmlResponse(renderForm(token, validationError));
        }

        try {
            resetPasswordUseCase.execute(token, newPassword);
            return htmlResponse(renderSuccess());
        } catch (IllegalArgumentException exception) {
            return htmlResponse(renderForm(token, exception.getMessage()));
        }
    }

    private static String validatePasswords(String password, String confirmation) {
        String passwordError = PasswordPolicy.validate(password);
        if (passwordError != null) {
            return passwordError;
        }
        if (!password.equals(confirmation)) {
            return "Les deux mots de passe ne correspondent pas.";
        }
        return null;
    }

    private static ResponseEntity<String> htmlResponse(String body) {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .header("Referrer-Policy", "no-referrer")
                .header("X-Content-Type-Options", "nosniff")
                .header("Permissions-Policy", "camera=(), microphone=()")
                .header(
                        "Content-Security-Policy",
                        "default-src 'none'; style-src 'self'; "
                                + "script-src 'self'; form-action 'self'; "
                                + "base-uri 'none'; frame-ancestors 'none'"
                )
                .contentType(MediaType.TEXT_HTML)
                .body(body);
    }

    private String renderForm(String token, String error) {
        String errorBlock = error == null
                ? ""
                : "<div class=\"error\" role=\"alert\">"
                + "<span aria-hidden=\"true\">⚠</span> "
                + HtmlUtils.htmlEscape(error)
                + "</div>";

        return templateRenderer.render(
                FORM_TEMPLATE,
                Map.of(
                        "TOKEN", HtmlUtils.htmlEscape(token),
                        "ERROR_BLOCK", errorBlock
                )
        );
    }

    private String renderSuccess() {
        return templateRenderer.render(SUCCESS_TEMPLATE, Map.of());
    }
}
