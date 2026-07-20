package com.ironpath.backend.shared.application;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import org.springframework.stereotype.Component;

@Component
public class EmailVerificationGuard {

    public void check(User user) {
        if (user.getEmailVerifiedAt() == null) {
            throw new UnauthorizedException(
                    "Veuillez vérifier votre email avant d'effectuer cette action"
            );
        }
    }
}