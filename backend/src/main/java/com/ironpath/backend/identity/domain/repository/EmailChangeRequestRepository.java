package com.ironpath.backend.identity.domain.repository;

import com.ironpath.backend.identity.domain.model.EmailChangeRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmailChangeRequestRepository extends JpaRepository<EmailChangeRequest, UUID> {
    Optional<EmailChangeRequest> findByConfirmationToken(String token);
    Optional<EmailChangeRequest> findByCancelToken(String token);
}