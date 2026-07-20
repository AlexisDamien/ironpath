package com.ironpath.backend.training.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record AddSetRequest(

        @NotBlank(message = "Exercise ID obligatoire")
        String exerciseId,

        @NotNull(message = "Ordre du set obligatoire")
        Integer setOrder,

        Integer reps,

        Double weightKg,

        Integer restSeconds,

        Boolean isWarmup
) {}