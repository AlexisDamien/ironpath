DO $$
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = current_schema()
              AND table_name = 'exercise_sets'
              AND column_name = 'weight_kg'
        ) THEN
            ALTER TABLE exercise_sets
                ALTER COLUMN weight_kg TYPE DOUBLE PRECISION
                    USING weight_kg::DOUBLE PRECISION;
        END IF;
    END
$$;