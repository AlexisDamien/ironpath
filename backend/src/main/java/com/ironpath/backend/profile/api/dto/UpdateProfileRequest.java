package com.ironpath.backend.profile.api.dto;

import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record UpdateProfileRequest(

        @Size(max = 50, message = "Prénom trop long")
        String firstName,

        @Size(max = 50, message = "Nom trop long")
        String lastName,

        LocalDate birthDate,

        Double heightCm,

        @Size(max = 100, message = "Objectif trop long")
        String objective,

        @Size(min = 3, max = 30, message = "Pseudo entre 3 et 30 caractères")
        String username
) {}