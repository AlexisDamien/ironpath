package com.ironpath.backend.bodymetrics.api.controller;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.application.GetCompositionsUseCase;
import com.ironpath.backend.bodymetrics.application.GetMeasurementsUseCase;
import com.ironpath.backend.bodymetrics.application.SaveCompositionUseCase;
import com.ironpath.backend.bodymetrics.application.SaveMeasurementUseCase;
import com.ironpath.backend.bodymetrics.application.UpdateMeasurementUseCase;
import com.ironpath.backend.bodymetrics.application.DeleteMeasurementUseCase;
import com.ironpath.backend.bodymetrics.application.UpdateCompositionUseCase;
import com.ironpath.backend.bodymetrics.application.DeleteCompositionUseCase;
import com.ironpath.backend.shared.infrastructure.JwtService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;

@RestController
@RequestMapping("/api/bodymetrics")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class BodyMetricsController {

    private final UpdateMeasurementUseCase updateMeasurementUseCase;
    private final DeleteMeasurementUseCase deleteMeasurementUseCase;
    private final UpdateCompositionUseCase updateCompositionUseCase;
    private final DeleteCompositionUseCase deleteCompositionUseCase;
    private final SaveMeasurementUseCase saveMeasurementUseCase;
    private final GetMeasurementsUseCase getMeasurementsUseCase;
    private final SaveCompositionUseCase saveCompositionUseCase;
    private final GetCompositionsUseCase getCompositionsUseCase;
    private final JwtService jwtService;

    @PostMapping("/measurements")
    public ResponseEntity<MeasurementResponse> saveMeasurement(
            @RequestBody SaveMeasurementRequest request,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(saveMeasurementUseCase.execute(userId, request));
    }

    @GetMapping("/measurements")
    public ResponseEntity<List<MeasurementResponse>> getMeasurements(HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(getMeasurementsUseCase.execute(userId));
    }

    @PostMapping("/compositions")
    public ResponseEntity<CompositionResponse> saveComposition(
            @RequestBody SaveCompositionRequest request,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(saveCompositionUseCase.execute(userId, request));
    }

    @GetMapping("/compositions")
    public ResponseEntity<List<CompositionResponse>> getCompositions(HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(getCompositionsUseCase.execute(userId));
    }

    private UUID extractUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtService.extractUserId(token);
    }

    @PutMapping("/measurements/{id}")
    public ResponseEntity<MeasurementResponse> updateMeasurement(
            @PathVariable UUID id,
            @RequestBody SaveMeasurementRequest request,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(updateMeasurementUseCase.execute(userId, id, request));
    }

    @DeleteMapping("/measurements/{id}")
    public ResponseEntity<Void> deleteMeasurement(
            @PathVariable UUID id,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        deleteMeasurementUseCase.execute(userId, id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/compositions/{id}")
    public ResponseEntity<CompositionResponse> updateComposition(
            @PathVariable UUID id,
            @RequestBody SaveCompositionRequest request,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        return ResponseEntity.ok(updateCompositionUseCase.execute(userId, id, request));
    }

    @DeleteMapping("/compositions/{id}")
    public ResponseEntity<Void> deleteComposition(
            @PathVariable UUID id,
            HttpServletRequest httpRequest) {
        UUID userId = extractUserId(httpRequest);
        deleteCompositionUseCase.execute(userId, id);
        return ResponseEntity.noContent().build();
    }
}