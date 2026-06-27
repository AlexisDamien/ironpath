package com.ironpath.backend.bodymetrics.api.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record CompositionResponse(
        UUID id,
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
        Double bmi,
        Integer metabolicAge,
        String notes,
        LocalDateTime recordedAt
) {}