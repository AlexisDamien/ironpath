package com.ironpath.backend.identity.domain.repository;

import com.ironpath.backend.identity.domain.model.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    @Modifying
    @Query("UPDATE RefreshToken refreshToken SET refreshToken.revoked = true WHERE refreshToken.user.id = :userId")
    void revokeAllByUserId(@Param("userId") UUID userId);
}