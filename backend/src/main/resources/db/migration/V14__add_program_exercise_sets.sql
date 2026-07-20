ALTER TABLE program_exercises ADD COLUMN same_config_for_all_sets BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE program_exercises DROP COLUMN IF EXISTS target_sets;
ALTER TABLE program_exercises DROP COLUMN IF EXISTS target_reps;
ALTER TABLE program_exercises DROP COLUMN IF EXISTS target_weight_kg;
ALTER TABLE program_exercises DROP COLUMN IF EXISTS rest_seconds;

CREATE TABLE program_exercise_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_exercise_id UUID NOT NULL REFERENCES program_exercises(id) ON DELETE CASCADE,
    set_order INTEGER NOT NULL,
    target_reps INTEGER,
    target_weight_kg DECIMAL(5, 2),
    rest_seconds INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);