CREATE TABLE IF NOT EXISTS exercises (
                                         id VARCHAR(10) PRIMARY KEY,
                                         name VARCHAR(255) NOT NULL,
                                         muscle_group VARCHAR(100),
                                         equipment VARCHAR(100),
                                         description TEXT
);

INSERT INTO exercises (id, name, muscle_group, equipment, description) VALUES
                                                                           ('EX001', 'Squat', 'Quadriceps', 'Barre', 'Exercice fondamental pour les jambes et les fessiers'),
                                                                           ('EX002', 'Bench Press', 'Pectoraux', 'Barre', 'Développé couché pour les pectoraux'),
                                                                           ('EX003', 'Deadlift', 'Ischio-jambiers', 'Barre', 'Soulevé de terre pour le dos et les jambes'),
                                                                           ('EX004', 'Pull-up', 'Dorsaux', 'Barre de traction', 'Traction pour le dos et les biceps'),
                                                                           ('EX005', 'Overhead Press', 'Épaules', 'Barre', 'Développé militaire pour les épaules'),
                                                                           ('EX006', 'Barbell Row', 'Dorsaux', 'Barre', 'Rowing barre pour le dos'),
                                                                           ('EX007', 'Dips', 'Triceps', 'Barres parallèles', 'Dips pour les triceps et pectoraux'),
                                                                           ('EX008', 'Leg Press', 'Quadriceps', 'Machine', 'Presse à cuisses pour les jambes'),
                                                                           ('EX009', 'Bicep Curl', 'Biceps', 'Haltères', 'Curl biceps aux haltères'),
                                                                           ('EX010', 'Tricep Extension', 'Triceps', 'Haltères', 'Extension triceps aux haltères'),
                                                                           ('EX011', 'Lateral Raise', 'Épaules', 'Haltères', 'Élévations latérales pour les épaules'),
                                                                           ('EX012', 'Romanian Deadlift', 'Ischio-jambiers', 'Barre', 'Soulevé de terre roumain pour les ischio-jambiers'),
                                                                           ('EX013', 'Leg Curl', 'Ischio-jambiers', 'Machine', 'Curl ischio-jambiers à la machine'),
                                                                           ('EX014', 'Calf Raise', 'Mollets', 'Machine', 'Élévation des mollets'),
                                                                           ('EX015', 'Plank', 'Abdominaux', 'Aucun', 'Gainage abdominal');