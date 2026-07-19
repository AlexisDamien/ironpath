package com.ironpath.backend.training.domain.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "session_planned_exercises")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SessionPlannedExercise {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private TrainingSession session;

    @Column(name = "exercise_id", nullable = false)
    private String exerciseId;

    @Column(name = "exercise_order", nullable = false)
    private Integer exerciseOrder;

    @OneToMany(mappedBy = "plannedExercise", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("setOrder ASC")
    @Builder.Default
    private List<SessionPlannedSet> sets = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}