package com.ironpath.backend.identity.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "consent_records")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConsentRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "consent_type", nullable = false)
    private String consentType;

    @Column(name = "consented_at", nullable = false)
    private LocalDateTime consentedAt;

    @Column(name = "ip_address")
    private String ipAddress;

    @PrePersist
    protected void onCreate() {
        if (consentedAt == null) {
            consentedAt = LocalDateTime.now();
        }
    }
}