package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.SessionPlannedExerciseResponse;
import com.ironpath.backend.training.api.dto.SessionPlannedSetResponse;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.SetResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
import com.ironpath.backend.training.domain.model.SessionPlannedExercise;
import com.ironpath.backend.training.domain.model.SessionPlannedSet;
import com.ironpath.backend.training.domain.model.TrainingSession;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class SessionMapper {

    public SessionResponse toResponse(TrainingSession session) {
        List<SetResponse> setResponses = session.getSets()
                .stream()
                .map(this::toSetResponse)
                .toList();

        List<SessionPlannedExerciseResponse> plannedExerciseResponses = session.getPlannedExercises()
                .stream()
                .map(this::toPlannedExerciseResponse)
                .toList();

        return new SessionResponse(
                session.getId(),
                session.getName(),
                session.getStatus(),
                session.getProgram() != null
                        ? session.getProgram().getId()
                        : null,
                setResponses,
                plannedExerciseResponses,
                session.getStartedAt(),
                session.getEndedAt()
        );
    }

    private SetResponse toSetResponse(ExerciseSet set) {
        return new SetResponse(
                set.getId(),
                set.getExerciseId(),
                set.getSetOrder(),
                set.getReps(),
                set.getWeightKg(),
                set.getRestSeconds(),
                set.getIsWarmup()
        );
    }

    private SessionPlannedExerciseResponse toPlannedExerciseResponse(SessionPlannedExercise exercise) {
        List<SessionPlannedSetResponse> setResponses = exercise.getSets()
                .stream()
                .map(this::toPlannedSetResponse)
                .toList();

        return new SessionPlannedExerciseResponse(
                exercise.getId(),
                exercise.getExerciseId(),
                exercise.getExerciseOrder(),
                setResponses
        );
    }

    private SessionPlannedSetResponse toPlannedSetResponse(SessionPlannedSet set) {
        return new SessionPlannedSetResponse(
                set.getId(),
                set.getSetOrder(),
                set.getTargetReps(),
                set.getTargetWeightKg(),
                set.getRestSeconds(),
                set.getIsWarmup()
        );
    }
}