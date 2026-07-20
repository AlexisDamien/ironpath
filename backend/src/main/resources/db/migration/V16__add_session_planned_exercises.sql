CREATE TABLE IF NOT EXISTS session_planned_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    exercise_id VARCHAR(50) NOT NULL,
    exercise_order INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS session_planned_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_planned_exercise_id UUID NOT NULL REFERENCES session_planned_exercises(id) ON DELETE CASCADE,
    set_order INTEGER NOT NULL,
    target_reps INTEGER,
    target_weight_kg DOUBLE PRECISION,
    rest_seconds INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);