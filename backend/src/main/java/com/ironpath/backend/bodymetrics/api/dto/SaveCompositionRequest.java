package com.ironpath.backend.bodymetrics.api.dto;

import java.time.LocalDateTime;

public record SaveCompositionRequest(
        Double bodyFat,
        Double skeletalMuscle,
        Double fatFreeMass,
        Double subcutaneousFat,
        Integer visceralFat,
        Double bodyWater,
        Double muscleMass,
        Double boneMass,
        Double protein,
        Integer bmr,
        String notes,
        LocalDateTime recordedAt,
        String source
) {}