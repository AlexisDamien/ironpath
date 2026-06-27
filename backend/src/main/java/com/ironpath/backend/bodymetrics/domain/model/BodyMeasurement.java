package com.ironpath.backend.bodymetrics.domain.model;

import com.ironpath.backend.identity.domain.model.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "body_measurements")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BodyMeasurement {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    private Double weight;
    private Double chest;
    private Double waist;
    private Double hips;

    @Column(name = "left_arm")
    private Double leftArm;

    @Column(name = "right_arm")
    private Double rightArm;

    @Column(name = "left_thigh")
    private Double leftThigh;

    @Column(name = "right_thigh")
    private Double rightThigh;

    @Column(name = "left_calf")
    private Double leftCalf;

    @Column(name = "right_calf")
    private Double rightCalf;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt;

    @PrePersist
    protected void onCreate() {
        if (recordedAt == null) {
            recordedAt = LocalDateTime.now();
        }
    }
}