package com.ironpath.backend.shared.utils;

public final class FormatUtils {

    private FormatUtils() {}

    public static double calculateEpley(double weightKg, int reps) {
        return Math.round(weightKg * (1 + reps / 30.0) * 10.0) / 10.0;
    }

    public static double calculateBmi(double weightKg, double height) {
        double heightM = height / 100.0;
        return Math.round((weightKg / (heightM * heightM)) * 10.0) / 10.0;
    }

    public static String formatWeight(double weightKg) {
        return String.format(java.util.Locale.US, "%.1f kg", weightKg);
    }

    public static String formatHeight(double height) {
        return String.format(java.util.Locale.US, "%.0f cm", height);
    }

    public static double calculateBmr(double weight, double height, int age, String gender) {
        if ("MALE".equalsIgnoreCase(gender)) {
            return (10 * weight) + (6.25 * height) - (5 * age) + 5;
        } else if ("FEMALE".equalsIgnoreCase(gender)) {
            return (10 * weight) + (6.25 * height) - (5 * age) - 161;
        }
        return (10 * weight) + (6.25 * height) - (5 * age) - 78;
    }

    public static int calculateMetabolicAge(int bmr, int age, String gender) {
        // Mifflin-St Jeor method
        double referenceBmr;
        if ("MALE".equalsIgnoreCase(gender)) {
            referenceBmr = 1750 - (5 * age);
        } else {
            referenceBmr = 1589 - (5 * age);
        }
        double ratio = bmr / referenceBmr;
        int adjustment = (int) Math.round((1 - ratio) * 10);
        return Math.max(10, age + adjustment);
    }
}