package com.ironpath.backend.training.domain.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "program_exercise_sets")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProgramExerciseSet {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "program_exercise_id", nullable = false)
    private ProgramExercise programExercise;

    @Column(name = "set_order", nullable = false)
    private Integer setOrder;

    @Column(name = "target_reps")
    private Integer targetReps;

    @Column(name = "target_weight_kg")
    private Double targetWeightKg;

    @Column(name = "rest_seconds")
    private Integer restSeconds;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}