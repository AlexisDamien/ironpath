package com.ironpath.backend.bodymetrics.api.controller;

import com.ironpath.backend.bodymetrics.api.dto.CompositionResponse;
import com.ironpath.backend.bodymetrics.api.dto.MeasurementResponse;
import com.ironpath.backend.bodymetrics.api.dto.SaveCompositionRequest;
import com.ironpath.backend.bodymetrics.api.dto.SaveMeasurementRequest;
import com.ironpath.backend.bodymetrics.application.GetCompositionsUseCase;
import com.ironpath.backend.bodymetrics.application.GetMeasurementsUseCase;
import com.ironpath.backend.bodymetrics.application.SaveCompositionUseCase;
import com.ironpath.backend.bodymetrics.application.SaveMeasurementUseCase;
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
}