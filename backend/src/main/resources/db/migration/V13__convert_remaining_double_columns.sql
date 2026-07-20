DO $$
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = 'one_rep_maxes'
              AND column_name = 'weight_kg'
        ) THEN
            ALTER TABLE one_rep_maxes
                ALTER COLUMN weight_kg TYPE DOUBLE PRECISION
                    USING weight_kg::DOUBLE PRECISION;
        END IF;

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = 'program_exercises'
              AND column_name = 'target_weight_kg'
        ) THEN
            ALTER TABLE program_exercises
                ALTER COLUMN target_weight_kg TYPE DOUBLE PRECISION
                    USING target_weight_kg::DOUBLE PRECISION;
        END IF;

        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = 'profiles'
              AND column_name = 'height'
        ) THEN
            ALTER TABLE profiles
                ALTER COLUMN height TYPE DOUBLE PRECISION
                    USING height::DOUBLE PRECISION;
        END IF;
    END
$$;