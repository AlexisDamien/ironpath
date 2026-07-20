package com.ironpath.backend.shared.utils;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class FormatUtilsTest {

    @Test
    void calculateEpley_shouldReturnCorrectValue_whenValidInput() {
        double result = FormatUtils.calculateEpley(100.0, 5);
        assertEquals(116.7, result);
    }

    @Test
    void calculateEpley_shouldReturnWeight_whenOneRep() {
        double result = FormatUtils.calculateEpley(100.0, 1);
        assertEquals(103.3, result);
    }

    @Test
    void calculateBmi_shouldReturnCorrectValue_whenValidInput() {
        double result = FormatUtils.calculateBmi(80.0, 180.0);
        assertEquals(24.7, result);
    }

    @Test
    void formatWeight_shouldReturnFormattedString() {
        String result = FormatUtils.formatWeight(80.5);
        assertEquals("80.5 kg", result);
    }

    @Test
    void formatHeight_shouldReturnFormattedString() {
        String result = FormatUtils.formatHeight(180.0);
        assertEquals("180 cm", result);
    }
}