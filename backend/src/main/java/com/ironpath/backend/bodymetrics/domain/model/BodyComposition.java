package com.ironpath.backend.bodymetrics.domain.model;

import com.ironpath.backend.identity.domain.model.User;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "body_compositions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BodyComposition {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "body_fat")
    private Double bodyFat;

    @Column(name = "skeletal_muscle")
    private Double skeletalMuscle;

    @Column(name = "fat_free_mass")
    private Double fatFreeMass;

    @Column(name = "subcutaneous_fat")
    private Double subcutaneousFat;

    @Column(name = "visceral_fat")
    private Integer visceralFat;

    @Column(name = "body_water")
    private Double bodyWater;

    @Column(name = "muscle_mass")
    private Double muscleMass;

    @Column(name = "bone_mass")
    private Double boneMass;

    private Double protein;
    private Integer bmr;
    private Double bmi;

    @Column(name = "metabolic_age")
    private Integer metabolicAge;

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