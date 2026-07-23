package com.ironpath.backend.identity.api.controller;

import com.ironpath.backend.identity.application.VerifyEmailUseCase;
import com.ironpath.backend.shared.infrastructure.HtmlTemplateRenderer;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.util.HtmlUtils;

import java.util.Map;

@Controller
public class EmailVerificationPageController {

    private static final String SUCCESS_TEMPLATE =
            "templates/email-verification/success.html";
    private static final String EXPIRED_TEMPLATE =
            "templates/email-verification/expired.html";

    private final VerifyEmailUseCase verifyEmailUseCase;
    private final HtmlTemplateRenderer templateRenderer;

    public EmailVerificationPageController(
            VerifyEmailUseCase verifyEmailUseCase,
            HtmlTemplateRenderer templateRenderer
    ) {
        this.verifyEmailUseCase = verifyEmailUseCase;
        this.templateRenderer = templateRenderer;
    }

    @GetMapping(
            value = "/api/auth/verify-email",
            produces = MediaType.TEXT_HTML_VALUE
    )
    public ResponseEntity<String> verifyEmail(@RequestParam String token) {
        try {
            verifyEmailUseCase.execute(token);
            return htmlResponse(
                    templateRenderer.render(SUCCESS_TEMPLATE, Map.of())
            );
        } catch (IllegalArgumentException exception) {
            String message = HtmlUtils.htmlEscape(exception.getMessage());
            return htmlResponse(
                    templateRenderer.render(
                            EXPIRED_TEMPLATE,
                            Map.of("MESSAGE", message)
                    )
            );
        }
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
                                + "form-action 'self'; base-uri 'none'; "
                                + "frame-ancestors 'none'"
                )
                .contentType(MediaType.TEXT_HTML)
                .body(body);
    }
}
