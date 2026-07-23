package com.ironpath.backend.shared.infrastructure;

/**
 * Levée lorsqu'un utilisateur authentifié tente d'accéder à une ressource
 * qui ne lui appartient pas. Distincte de {@link UnauthorizedException},
 * qui signale une absence/invalidité d'authentification (401) : ici
 * l'utilisateur est bien identifié, il n'a simplement pas le droit sur
 * cette ressource précise (403).
 */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
