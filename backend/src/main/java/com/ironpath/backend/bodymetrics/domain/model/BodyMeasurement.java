package com.ironpath.backend.bodymetrics.domain.model;

import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.shared.infrastructure.EncryptedDoubleConverter;
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

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double weight;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double chest;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double waist;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(columnDefinition = "TEXT")
    private Double hips;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "left_arm", columnDefinition = "TEXT")
    private Double leftArm;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "right_arm", columnDefinition = "TEXT")
    private Double rightArm;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "left_thigh", columnDefinition = "TEXT")
    private Double leftThigh;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "right_thigh", columnDefinition = "TEXT")
    private Double rightThigh;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "left_calf", columnDefinition = "TEXT")
    private Double leftCalf;

    @Convert(converter = EncryptedDoubleConverter.class)
    @Column(name = "right_calf", columnDefinition = "TEXT")
    private Double rightCalf;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt;

    @Column(name = "archived")
    private Boolean archived = false;

    @PrePersist
    protected void onCreate() {
        if (recordedAt == null) {
            recordedAt = LocalDateTime.now();
        }
    }
}