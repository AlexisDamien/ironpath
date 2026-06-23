package com.ironpath.backend.training.domain.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "exercise_sets")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExerciseSet {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private TrainingSession session;

    @Column(name = "exercise_id", nullable = false)
    private String exerciseId;

    @Column(name = "set_order", nullable = false)
    private Integer setOrder;

    @Column(name = "reps")
    private Integer reps;

    @Column(name = "weight_kg")
    private Double weightKg;

    @Column(name = "rest_seconds")
    private Integer restSeconds;

    @Column(name = "is_warmup", nullable = false)
    private Boolean isWarmup;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (isWarmup == null) {
            isWarmup = false;
        }
    }
}