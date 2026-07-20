import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ironpath/core/network/api_client.dart';
import 'package:ironpath/core/storage/token_storage.dart';
import 'package:ironpath/features/bodymetrics/data/repository_bodymetrics.dart';
import 'package:ironpath/features/identity/data/repository_identity.dart';
import 'package:ironpath/features/profile/data/repository_profile.dart';
import 'package:ironpath/features/training/data/repository_training.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockRepositoryIdentity extends Mock implements RepositoryIdentity {}

class MockRepositoryProfile extends Mock implements RepositoryProfile {}

class MockRepositoryBodyMetrics extends Mock implements RepositoryBodyMetrics {}

class MockRepositoryTraining extends Mock implements RepositoryTraining {}
