package com.ironpath.backend.bodymetrics.domain.model;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.infrastructure.EncryptedDoubleConverter;
import com.ironpath.backend.shared.infrastructure.EncryptedIntegerConverter;
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

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "body_fat", columnDefinition = "TEXT")
    private Double bodyFat;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "skeletal_muscle", columnDefinition = "TEXT")
    private Double skeletalMuscle;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "fat_free_mass", columnDefinition = "TEXT")
    private Double fatFreeMass;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "subcutaneous_fat", columnDefinition = "TEXT")
    private Double subcutaneousFat;

    @Convert(converter = EncryptedIntegerConverter.class)
    @Column(name = "visceral_fat", columnDefinition = "TEXT")
    private Integer visceralFat;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "body_water", columnDefinition = "TEXT")
    private Double bodyWater;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "muscle_mass", columnDefinition = "TEXT")
    private Double muscleMass;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "bone_mass", columnDefinition = "TEXT")
    private Double boneMass;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double protein;

    @Convert(converter = EncryptedIntegerConverter.class)
    @Column(columnDefinition = "TEXT")
    private Integer bmr;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double bmi;

    @Convert(converter = EncryptedIntegerConverter.class)
    @Column(name = "metabolic_age", columnDefinition = "TEXT")
    private Integer metabolicAge;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt;

    @Column(name = "source")
    @Builder.Default
    private String source = "MANUAL";

    @Column(name = "archived")
    @Builder.Default
    private Boolean archived = false;

    @PrePersist
    protected void onCreate() {
        if (recordedAt == null) {
            recordedAt = LocalDateTime.now();
        }
    }
}