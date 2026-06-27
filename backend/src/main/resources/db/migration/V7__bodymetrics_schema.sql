CREATE TABLE body_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2),
    chest DECIMAL(5,2),
    waist DECIMAL(5,2),
    hips DECIMAL(5,2),
    left_arm DECIMAL(5,2),
    right_arm DECIMAL(5,2),
    left_thigh DECIMAL(5,2),
    right_thigh DECIMAL(5,2),
    left_calf DECIMAL(5,2),
    right_calf DECIMAL(5,2),
    notes TEXT,
    recorded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE body_compositions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body_fat DECIMAL(5,2),
    skeletal_muscle DECIMAL(5,2),
    fat_free_mass DECIMAL(5,2),
    subcutaneous_fat DECIMAL(5,2),
    visceral_fat INTEGER,
    body_water DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    bone_mass DECIMAL(5,2),
    protein DECIMAL(5,2),
    bmr INTEGER,
    bmi DECIMAL(4,2),
    metabolic_age INTEGER,
    notes TEXT,
    recorded_at TIMESTAMP NOT NULL DEFAULT NOW()
);