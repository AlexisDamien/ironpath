package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class GetCompositionsUseCase {

    private final BodyCompositionRepository compositionRepository;

    public List<CompositionResponse> execute(UUID userId) {
        return compositionRepository.findByUserIdOrderByRecordedAtDesc(userId)
                .stream()
                .map(SaveCompositionUseCase::toResponse)
                .toList();
    }
}