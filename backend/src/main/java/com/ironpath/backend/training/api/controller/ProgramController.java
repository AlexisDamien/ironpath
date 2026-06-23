package com.ironpath.backend.training.api.controller;

import com.ironpath.backend.training.api.dto.CreateProgramRequest;
import com.ironpath.backend.training.api.dto.ProgramResponse;
import com.ironpath.backend.training.application.CreateProgramUseCase;
import com.ironpath.backend.training.application.DeleteProgramUseCase;
import com.ironpath.backend.training.application.GetProgramsUseCase;
import com.ironpath.backend.training.application.UpdateProgramUseCase;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/training/programs")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class ProgramController {

    private final CreateProgramUseCase createProgramUseCase;
    private final GetProgramsUseCase getProgramsUseCase;
    private final UpdateProgramUseCase updateProgramUseCase;
    private final DeleteProgramUseCase deleteProgramUseCase;

    @PostMapping
    public ResponseEntity<ProgramResponse> createProgram(
            @Valid @RequestBody CreateProgramRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        ProgramResponse response = createProgramUseCase.execute(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<ProgramResponse>> getPrograms(Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(getProgramsUseCase.execute(userId));
    }

    @PutMapping("/{programId}")
    public ResponseEntity<ProgramResponse> updateProgram(
            @PathVariable UUID programId,
            @Valid @RequestBody CreateProgramRequest request,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        return ResponseEntity.ok(updateProgramUseCase.execute(userId, programId, request));
    }

    @DeleteMapping("/{programId}")
    public ResponseEntity<Void> deleteProgram(
            @PathVariable UUID programId,
            Authentication authentication) {
        UUID userId = UUID.fromString(authentication.getName());
        deleteProgramUseCase.execute(userId, programId);
        return ResponseEntity.noContent().build();
    }
}