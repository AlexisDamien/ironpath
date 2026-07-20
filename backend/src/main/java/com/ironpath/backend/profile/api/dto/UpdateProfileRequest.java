package com.ironpath.backend.profile.api.dto;

import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record UpdateProfileRequest(

        @Size(max = 50, message = "Prénom limité à 50 caractères")
        String firstName,

        @Size(max = 50, message = "Nom limité à 50 caractères")
        String lastName,

        @Past(message = "La date de naissance doit être dans le passé")
        LocalDate birthDate,

        @Positive(message = "La taille doit être supérieure à 0")
        Double height,

        @Size(max = 10, message = "Genre invalide")
        String gender,

        @Size(max = 100, message = "Objectif limité à 100 caractères")
        String objective,

        @Size(
                min = 3,
                max = 30,
                message = "Nom d’utilisateur entre 3 et 30 caractères"
        )
        String username
) {
}
