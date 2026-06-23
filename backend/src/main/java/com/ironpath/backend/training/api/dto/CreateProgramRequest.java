package com.ironpath.backend.training.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public record CreateProgramRequest(

        @NotBlank(message = "Nom du programme obligatoire")
        @Size(max = 100, message = "Nom trop long")
        String name,

        String description,

        List<ProgramExerciseRequest> exercises
) {}