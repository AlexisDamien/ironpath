package com.ironpath.backend.training.api.controller;

import com.ironpath.backend.training.api.dto.AddSetRequest;
import com.ironpath.backend.training.api.dto.ExerciseStatsResponse;
import com.ironpath.backend.training.api.dto.SessionResponse;
import com.ironpath.backend.training.api.dto.StartSessionRequest;
import com.ironpath.backend.training.application.*;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/training/sessions")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class SessionController {

    private final StartSessionUseCase startSessionUseCase;
    private final AddSetUseCase addSetUseCase;
    private final EndSessionUseCase endSessionUseCase;
    private final GetSessionsUseCase getSessionsUseCase;
    private final GetExerciseStatsUseCase getExerciseStatsUseCase;

    @PostMapping
    public ResponseEntity<SessionResponse> startSession(
            @RequestBody StartSessionRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        SessionResponse response = startSessionUseCase.execute(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/{sessionId}/sets")
    public ResponseEntity<SessionResponse> addSet(
            @PathVariable UUID sessionId,
            @Valid @RequestBody AddSetRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(addSetUseCase.execute(userId, sessionId, request));
    }

    @PostMapping("/{sessionId}/end")
    public ResponseEntity<SessionResponse> endSession(
            @PathVariable UUID sessionId,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(endSessionUseCase.execute(userId, sessionId));
    }

    @GetMapping
    public ResponseEntity<List<SessionResponse>> getSessions(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(getSessionsUseCase.execute(userId));
    }

    @GetMapping("/exercises/{exerciseId}/stats")
    public ResponseEntity<ExerciseStatsResponse> getExerciseStats(
            @PathVariable String exerciseId,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(getExerciseStatsUseCase.execute(userId, exerciseId));
    }
}