package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.infrastructure.UnauthorizedException;
import com.ironpath.backend.shared.utils.FormatUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.Period;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UpdateCompositionUseCase {

    private final BodyCompositionRepository compositionRepository;
    private final BodyMeasurementRepository measurementRepository;
    private final ProfileRepository profileRepository;

    public CompositionResponse execute(UUID userId, UUID compositionId, SaveCompositionRequest request) {
        BodyComposition composition = compositionRepository.findById(compositionId)
                .orElseThrow(() -> new IllegalArgumentException("Composition introuvable"));

        if (!composition.getUser().getId().equals(userId)) {
            throw new UnauthorizedException("Cette composition ne vous appartient pas");
        }

        Profile profile = profileRepository.findByUserId(userId).orElse(null);

        Double weight = measurementRepository
                .findByUserIdOrderByRecordedAtDesc(userId)
                .stream()
                .findFirst()
                .map(BodyMeasurement::getWeight)
                .orElse(null);

        if (request.bodyFat() != null) { composition.setBodyFat(request.bodyFat()); }
        if (request.skeletalMuscle() != null) { composition.setSkeletalMuscle(request.skeletalMuscle()); }
        if (request.fatFreeMass() != null) { composition.setFatFreeMass(request.fatFreeMass()); }
        if (request.subcutaneousFat() != null) { composition.setSubcutaneousFat(request.subcutaneousFat()); }
        if (request.visceralFat() != null) { composition.setVisceralFat(request.visceralFat()); }
        if (request.bodyWater() != null) { composition.setBodyWater(request.bodyWater()); }
        if (request.muscleMass() != null) { composition.setMuscleMass(request.muscleMass()); }
        if (request.boneMass() != null) { composition.setBoneMass(request.boneMass()); }
        if (request.protein() != null) { composition.setProtein(request.protein()); }
        if (request.notes() != null) { composition.setNotes(request.notes()); }

        Integer bmr = request.bmr();
        if (bmr == null && profile != null && weight != null
                && profile.getHeight() != null && profile.getBirthDate() != null
                && profile.getGender() != null) {
            int age = Period.between(profile.getBirthDate(), LocalDate.now()).getYears();
            bmr = (int) Math.round(FormatUtils.calculateBmr(weight, profile.getHeight(), age, profile.getGender()));        }
        if (bmr != null) { composition.setBmr(bmr); }

        if (profile != null && weight != null && profile.getHeight() != null) {
            composition.setBmi(FormatUtils.calculateBmi(weight, profile.getHeight()));
        }

        if (bmr != null && profile != null && profile.getBirthDate() != null) {
            int age = Period.between(profile.getBirthDate(), LocalDate.now()).getYears();
            composition.setMetabolicAge(FormatUtils.calculateMetabolicAge(bmr, age, profile.getGender()));
        }

        BodyComposition saved = compositionRepository.save(composition);
        return SaveCompositionUseCase.toResponse(saved);
    }
}