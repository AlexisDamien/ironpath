CREATE TABLE workout_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE program_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID NOT NULL REFERENCES workout_programs(id) ON DELETE CASCADE,
    exercise_id VARCHAR(50) NOT NULL,
    exercise_order INTEGER NOT NULL,
    target_sets INTEGER,
    target_reps INTEGER,
    target_weight_kg DECIMAL(5, 2),
    rest_seconds INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE training_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    program_id UUID REFERENCES workout_programs(id) ON DELETE SET NULL,
    name VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'IN_PROGRESS',
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE exercise_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    exercise_id VARCHAR(50) NOT NULL,
    set_order INTEGER NOT NULL,
    reps INTEGER,
    weight_kg DECIMAL(5, 2),
    rest_seconds INTEGER,
    is_warmup BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE one_rep_maxes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    exercise_id VARCHAR(50) NOT NULL,
    weight_kg DECIMAL(5, 2) NOT NULL,
    calculated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    formula VARCHAR(20) NOT NULL DEFAULT 'epley'
);