DO $$
    DECLARE
        target_column TEXT;
    BEGIN
        IF to_regclass('body_measurements') IS NOT NULL THEN
            FOREACH target_column IN ARRAY ARRAY[
                'weight',
                'chest',
                'waist',
                'hips',
                'left_arm',
                'right_arm',
                'left_thigh',
                'right_thigh',
                'left_calf',
                'right_calf'
                ]
                LOOP
                    IF EXISTS (
                        SELECT 1
                        FROM information_schema.columns
                        WHERE table_schema = current_schema()
                          AND table_name = 'body_measurements'
                          AND column_name = target_column
                    ) THEN
                        EXECUTE format(
                                'ALTER TABLE body_measurements ALTER COLUMN %I TYPE TEXT USING NULL',
                                target_column
                                );
                    END IF;
                END LOOP;
        END IF;

        IF to_regclass('body_compositions') IS NOT NULL THEN
            FOREACH target_column IN ARRAY ARRAY[
                'body_fat',
                'skeletal_muscle',
                'fat_free_mass',
                'subcutaneous_fat',
                'visceral_fat',
                'body_water',
                'muscle_mass',
                'bone_mass',
                'protein',
                'bmr',
                'bmi',
                'metabolic_age'
                ]
                LOOP
                    IF EXISTS (
                        SELECT 1
                        FROM information_schema.columns
                        WHERE table_schema = current_schema()
                          AND table_name = 'body_compositions'
                          AND column_name = target_column
                    ) THEN
                        EXECUTE format(
                                'ALTER TABLE body_compositions ALTER COLUMN %I TYPE TEXT USING NULL',
                                target_column
                                );
                    END IF;
                END LOOP;
        END IF;
    END
$$;
