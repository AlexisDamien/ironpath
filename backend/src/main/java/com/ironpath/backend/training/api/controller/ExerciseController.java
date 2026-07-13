package com.ironpath.backend.training.api.controller;

import com.ironpath.backend.training.api.dto.ExerciseResponse;
import com.ironpath.backend.training.application.GetExercisesUseCase;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/exercises")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class ExerciseController {

    private final GetExercisesUseCase getExercisesUseCase;

    @GetMapping
    public ResponseEntity<List<ExerciseResponse>> getExercises(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String muscleGroup) {
        return ResponseEntity.ok(getExercisesUseCase.execute(search, muscleGroup));
    }
}