package com.ironpath.backend.bodymetrics.api.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record MeasurementResponse(
        UUID id,
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
        LocalDateTime recordedAt,
        Boolean archived
) {}