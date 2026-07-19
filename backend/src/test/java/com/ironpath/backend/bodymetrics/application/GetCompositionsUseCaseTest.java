package com.ironpath.backend.bodymetrics.application;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.domain.model.BodyComposition;
import com.ironpath.backend.bodymetrics.domain.repository.BodyCompositionRepository;
import com.ironpath.backend.identity.domain.model.User;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GetCompositionsUseCaseTest {

    @Mock
    private BodyCompositionRepository compositionRepository;

    @InjectMocks
    private GetCompositionsUseCase getCompositionsUseCase;

    @Test
    void execute_shouldReturnCompositions_orderedAsReturnedByRepository() {
        UUID userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();

        BodyComposition recent = BodyComposition.builder()
                .id(UUID.randomUUID()).user(user).bodyFat(15.0)
                .recordedAt(LocalDateTime.now()).build();
        BodyComposition older = BodyComposition.builder()
                .id(UUID.randomUUID()).user(user).bodyFat(16.0)
                .recordedAt(LocalDateTime.now().minusDays(10)).build();

        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of(recent, older));

        List<CompositionResponse> responses = getCompositionsUseCase.execute(userId);

        assertEquals(2, responses.size());
        assertEquals(recent.getId(), responses.get(0).id());
        assertEquals(older.getId(), responses.get(1).id());
    }

    @Test
    void execute_shouldReturnEmptyList_whenNoCompositions() {
        UUID userId = UUID.randomUUID();

        when(compositionRepository.findByUserIdOrderByRecordedAtDesc(userId))
                .thenReturn(List.of());

        List<CompositionResponse> responses = getCompositionsUseCase.execute(userId);

        assertTrue(responses.isEmpty());
    }
}
