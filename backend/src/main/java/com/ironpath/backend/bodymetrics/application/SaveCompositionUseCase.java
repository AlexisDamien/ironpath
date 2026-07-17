package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.model.BodyMeasurement;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.bodymetrics.domain.repository.BodyMeasurementRepository;
import com.ironpath.backend.identity.domain.model.User;
import com.ironpath.backend.identity.domain.repository.UserRepository;
import com.ironpath.backend.profile.domain.model.Profile;
import com.ironpath.backend.profile.domain.repository.ProfileRepository;
import com.ironpath.backend.shared.application.EmailVerificationGuard;
import com.ironpath.backend.shared.utils.FormatUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SaveCompositionUseCase {

    private final BodyCompositionRepository compositionRepository;
    private final BodyMeasurementRepository measurementRepository;
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final EmailVerificationGuard emailVerificationGuard;

    @Transactional
    public CompositionResponse execute(UUID userId, SaveCompositionRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur introuvable"));
        emailVerificationGuard.check(user);

        List<BodyComposition> existing = compositionRepository
                .findByUserIdOrderByRecordedAtDesc(userId);
        for (BodyComposition old : existing) {
            old.setArchived(true);
        }
        compositionRepository.saveAll(existing);

        Profile profile = profileRepository.findByUserId(userId).orElse(null);

        Double weight = measurementRepository
                .findByUserIdOrderByRecordedAtDesc(userId)
                .stream()
                .findFirst()
                .map(BodyMeasurement::getWeight)
                .orElse(null);

        Double bmi = null;
        Integer metabolicAge = null;
        Integer bmr = request.bmr();

        if (profile != null && weight != null && profile.getHeight() != null) {
            bmi = FormatUtils.calculateBmi(weight, profile.getHeight());
        }

        if (bmr == null && profile != null && weight != null
                && profile.getHeight() != null && profile.getBirthDate() != null
                && profile.getGender() != null) {
            int age = Period.between(profile.getBirthDate(), LocalDate.now()).getYears();
            bmr = (int) FormatUtils.calculateBmr(weight, profile.getHeight(), age, profile.getGender());
        }

        if (bmr != null && profile != null && profile.getBirthDate() != null) {
            int age = Period.between(profile.getBirthDate(), LocalDate.now()).getYears();
            metabolicAge = FormatUtils.calculateMetabolicAge(bmr, age, profile.getGender());
        }

        BodyComposition composition = BodyComposition.builder()
                .user(user)
                .bodyFat(request.bodyFat())
                .skeletalMuscle(request.skeletalMuscle())
                .fatFreeMass(request.fatFreeMass())
                .subcutaneousFat(request.subcutaneousFat())
                .visceralFat(request.visceralFat())
                .bodyWater(request.bodyWater())
                .muscleMass(request.muscleMass())
                .boneMass(request.boneMass())
                .protein(request.protein())
                .bmr(bmr)
                .bmi(bmi)
                .metabolicAge(metabolicAge)
                .notes(request.notes())
                .recordedAt(request.recordedAt() != null ? request.recordedAt() : LocalDateTime.now())
                .archived(false)
                .source(request.source() != null ? request.source() : "MANUAL")
                .build();

        BodyComposition saved = compositionRepository.save(composition);
        return toResponse(saved);
    }

    public static CompositionResponse toResponse(BodyComposition composition) {
        return new CompositionResponse(
                composition.getId(),
                composition.getBodyFat(),
                composition.getSkeletalMuscle(),
                composition.getFatFreeMass(),
                composition.getSubcutaneousFat(),
                composition.getVisceralFat(),
                composition.getBodyWater(),
                composition.getMuscleMass(),
                composition.getBoneMass(),
                composition.getProtein(),
                composition.getBmr(),
                composition.getBmi(),
                composition.getMetabolicAge(),
                composition.getNotes(),
                composition.getRecordedAt(),
                composition.getSource(),
                composition.getArchived()
        );
    }
}