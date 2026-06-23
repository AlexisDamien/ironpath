package com.ironpath.backend.training.domain.model;

import com.ironpath.backend.identity.domain.model.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "one_rep_maxes")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OneRepMax {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "exercise_id", nullable = false)
    private String exerciseId;

    @Column(name = "weight_kg", nullable = false)
    private Double weightKg;

    @Column(name = "calculated_at", nullable = false)
    private LocalDateTime calculatedAt;

    @Column(name = "formula", nullable = false)
    private String formula;

    @PrePersist
    protected void onCreate() {
        calculatedAt = LocalDateTime.now();
        if (formula == null) {
            formula = "epley";
        }
    }
}