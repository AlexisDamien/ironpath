package com.ironpath.backend.bodymetrics.api.dto;

import java.time.LocalDateTime;

public record SaveMeasurementRequest(
        Double weight,
        Double chest,
        Double waist,
        Double hips,
        Double leftArm,
        Double rightArm,
        Double leftThigh,
        Double rightThigh,
        Double leftCalf,
        Double rightCalf,
        String notes,
        LocalDateTime recordedAt
) {}