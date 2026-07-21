package com.ironpath.backend.training.application;

import com.ironpath.backend.shared.utils.FormatUtils;
import com.ironpath.backend.training.api.dto.ExerciseStatsResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.OneRepMax;
import com.ironpath.backend.training.domain.repository.OneRepMaxRepository;
import com.ironpath.backend.training.domain.repository.TrainingSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetExerciseStatsUseCase {

    private final TrainingSessionRepository sessionRepository;
    private final OneRepMaxRepository oneRepMaxRepository;

    @Transactional(readOnly = true)
    public ExerciseStatsResponse execute(UUID userId, String exerciseId) {
        List<ExerciseSet> allSets = sessionRepository
                .findByUserIdOrderByStartedAtDesc(userId)
                .stream()
                .filter(session ->
                        "COMPLETED".equals(session.getStatus())
                )
                .flatMap(session ->
                        session.getSets().stream()
                )
                .filter(set ->
                        exerciseId.equals(set.getExerciseId())
                )
                .filter(set ->
                        Boolean.FALSE.equals(set.getIsWarmup())
                )
                .toList();

        ExerciseSet lastSet = allSets.stream()
                .max(Comparator.comparing(
                        set -> set.getSession().getStartedAt()
                ))
                .orElse(null);

        Optional<OneRepMax> oneRepMax = oneRepMaxRepository
                .findTopByUserIdAndExerciseIdOrderByCalculatedAtDesc(
                        userId,
                        exerciseId
                );

        if (lastSet == null && oneRepMax.isEmpty()) {
            return new ExerciseStatsResponse(
                    exerciseId,
                    null,
                    null,
                    null,
                    null,
                    null
            );
        }

        Double lastWeightKg = lastSet != null
                ? lastSet.getWeightKg()
                : null;

        Integer lastReps = lastSet != null
                ? lastSet.getReps()
                : null;

        LocalDateTime lastPerformedAt = lastSet != null
                ? lastSet.getSession().getStartedAt()
                : null;

        Double estimatedOrm = oneRepMax
                .map(OneRepMax::getWeightKg)
                .orElseGet(() ->
                        calculateEstimatedOrm(lastSet)
                );

        LocalDateTime ormCalculatedAt = oneRepMax
                .map(OneRepMax::getCalculatedAt)
                .orElse(null);

        return new ExerciseStatsResponse(
                exerciseId,
                lastWeightKg,
                lastReps,
                lastPerformedAt,
                estimatedOrm,
                ormCalculatedAt
        );
    }

    private Double calculateEstimatedOrm(ExerciseSet set) {
        if (set == null
                || set.getWeightKg() == null
                || set.getReps() == null) {
            return null;
        }

        return FormatUtils.calculateEpley(
                set.getWeightKg(),
                set.getReps()
        );
    }
}