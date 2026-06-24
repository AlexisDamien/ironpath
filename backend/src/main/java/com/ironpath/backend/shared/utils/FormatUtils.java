package com.ironpath.backend.shared.utils;

public final class FormatUtils {

    private FormatUtils() {}

    public static double calculateEpley(double weightKg, int reps) {
        return Math.round(weightKg * (1 + reps / 30.0) * 10.0) / 10.0;
    }

    public static double calculateBmi(double weightKg, double heightCm) {
        double heightM = heightCm / 100.0;
        return Math.round((weightKg / (heightM * heightM)) * 10.0) / 10.0;
    }

    public static String formatWeight(double weightKg) {
        return String.format("%.1f kg", weightKg);
    }

    public static String formatHeight(double heightCm) {
        return String.format("%.0f cm", heightCm);
    }
}