package com.ironpath.backend.training.application;

import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.SetResponse;
import com.ironpath.backend.training.domain.model.ExerciseSet;
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

        return new SessionResponse(
                session.getId(),
                session.getName(),
                session.getStatus(),
                session.getProgram() != null ? session.getProgram().getId() : null,
                setResponses,
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
}