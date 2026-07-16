package com.ironpath.backend.identity.domain.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "email_change_requests")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmailChangeRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "old_email", nullable = false)
    private String oldEmail;

    @Column(name = "new_email", nullable = false)
    private String newEmail;

    @Column(name = "confirmation_token", nullable = false, unique = true)
    private String confirmationToken;

    @Column(name = "cancel_token", nullable = false, unique = true)
    private String cancelToken;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "confirmed", nullable = false)
    private boolean confirmed;

    @Column(name = "cancelled", nullable = false)
    private boolean cancelled;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}