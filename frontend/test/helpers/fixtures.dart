import 'package:ironpath/features/bodymetrics/domain/models/body_composition.dart';
import 'package:ironpath/features/bodymetrics/domain/models/body_measurement.dart';
import 'package:ironpath/features/profile/domain/models/profile.dart';
import 'package:ironpath/features/training/domain/models/exercise.dart';
import 'package:ironpath/features/training/domain/models/training_session.dart';
import 'package:ironpath/features/training/domain/models/workout_program.dart';

Map<String, dynamic> profileJson({
  String id = 'profile-1',
  bool complete = true,
}) =>
    {
      'id': id,
      'firstName': 'Alex',
      'lastName': 'Martin',
      'username': 'alexmartin',
      'birthDate': '1990-02-03',
      'height': 178,
      'gender': 'MALE',
      'objective': 'STRENGTH',
      'profileComplete': complete,
    };

Profile profileFixture({String id = 'profile-1', bool complete = true}) =>
    Profile.fromJson(profileJson(id: id, complete: complete));

Map<String, dynamic> measurementJson({
  String id = 'measurement-1',
  bool archived = false,
}) =>
    {
      'id': id,
      'weight': 82,
      'chest': 101.5,
      'waist': 84,
      'hips': 97,
      'leftArm': 36,
      'rightArm': 36.5,
      'leftThigh': 59,
      'rightThigh': 59.5,
      'leftCalf': 39,
      'rightCalf': 39.5,
      'notes': 'Matin',
      'recordedAt': '2026-07-20T08:30:00.000Z',
      'archived': archived,
    };

BodyMeasurement measurementFixture({
  String id = 'measurement-1',
  bool archived = false,
}) =>
    BodyMeasurement.fromJson(measurementJson(id: id, archived: archived));

Map<String, dynamic> compositionJson({
  String id = 'composition-1',
  String source = 'MANUAL',
  bool archived = false,
}) =>
    {
      'id': id,
      'bodyFat': 15.2,
      'skeletalMuscle': 48.1,
      'fatFreeMass': 69.5,
      'subcutaneousFat': 12.4,
      'visceralFat': 7,
      'bodyWater': 61.3,
      'muscleMass': 65.2,
      'boneMass': 3.4,
      'protein': 19.1,
      'bmr': 1820,
      'bmi': 25.9,
      'metabolicAge': 31,
      'notes': 'Balance',
      'recordedAt': '2026-07-20T08:30:00.000Z',
      'source': source,
      'archived': archived,
    };

BodyComposition compositionFixture({
  String id = 'composition-1',
  String source = 'MANUAL',
  bool archived = false,
}) =>
    BodyComposition.fromJson(
      compositionJson(id: id, source: source, archived: archived),
    );

Map<String, dynamic> exerciseJson({
  String id = 'exercise-1',
  String name = 'Développé couché',
}) =>
    {
      'id': id,
      'name': name,
      'muscleGroup': 'CHEST',
      'equipment': 'BARBELL',
      'description': 'Exercice de poussée',
    };

Exercise exerciseFixture({
  String id = 'exercise-1',
  String name = 'Développé couché',
}) =>
    Exercise.fromJson(exerciseJson(id: id, name: name));

Map<String, dynamic> programJson({String id = 'program-1'}) => {
      'id': id,
      'name': 'Push',
      'description': 'Pectoraux et triceps',
      'isActive': true,
      'exercises': [
        {
          'id': 'program-exercise-1',
          'exerciseId': 'exercise-1',
          'exerciseOrder': 1,
          'sameConfigForAllSets': true,
          'sets': [
            {
              'id': 'target-1',
              'setOrder': 1,
              'targetReps': 10,
              'targetWeightKg': 80,
              'restSeconds': 90,
              'isWarmup': false,
            },
          ],
        },
      ],
    };

WorkoutProgram programFixture({String id = 'program-1'}) =>
    WorkoutProgram.fromJson(programJson(id: id));

Map<String, dynamic> sessionJson({
  String id = 'session-1',
  String status = 'IN_PROGRESS',
}) =>
    {
      'id': id,
      'name': 'Séance Push',
      'status': status,
      'programId': 'program-1',
      'startedAt': '2026-07-20T08:00:00.000Z',
      'endedAt': status == 'COMPLETED' ? '2026-07-20T09:00:00.000Z' : null,
      'sets': [
        {
          'id': 'set-1',
          'exerciseId': 'exercise-1',
          'setOrder': 1,
          'reps': 10,
          'weightKg': 80,
          'restSeconds': 95,
          'isWarmup': false,
        },
      ],
      'plannedExercises': [
        {
          'id': 'planned-exercise-1',
          'exerciseId': 'exercise-1',
          'exerciseOrder': 1,
          'sets': [
            {
              'id': 'planned-set-1',
              'setOrder': 1,
              'targetReps': 10,
              'targetWeightKg': 80,
              'restSeconds': 90,
              'isWarmup': false,
            },
          ],
        },
      ],
    };

TrainingSession sessionFixture({
  String id = 'session-1',
  String status = 'IN_PROGRESS',
}) =>
    TrainingSession.fromJson(sessionJson(id: id, status: status));
