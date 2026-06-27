package com.ironpath.backend.profile.api.dto;

import java.time.LocalDate;
import java.util.UUID;

public record ProfileResponse(
        UUID id,
        String firstName,
        String lastName,
        LocalDate birthDate,
        Double height,
        String gender,
        String objective,
        String username,
        String avatarUrl
) {}