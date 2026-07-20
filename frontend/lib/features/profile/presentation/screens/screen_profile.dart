import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bodymetrics/presentation/providers/provider_bodymetrics.dart';
import '../../domain/state_profile.dart';
import '../providers/provider_profile.dart';
import '../widgets/card_profile.dart';
import '../widgets/card_stats.dart';
import 'screen_edit_profile.dart';
import 'screen_settings.dart';

class ScreenProfile extends ConsumerStatefulWidget {
  const ScreenProfile({super.key});

  @override
  ConsumerState<ScreenProfile> createState() => _ScreenProfileState();
}

class _ScreenProfileState extends ConsumerState<ScreenProfile> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(providerProfile.notifier).loadProfile();
      ref.read(providerBodyMetrics.notifier).loadMeasurements();
      ref.read(providerBodyMetrics.notifier).loadCompositions();
    });
  }

  Future<void> _openProfileForm() async {
    final profile = ref.read(providerProfile).profile;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ScreenEditProfile(profile: profile),
      ),
    );

    if (saved == true && mounted) {
      await ref.read(providerProfile.notifier).loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProfile = ref.watch(providerProfile);
    final bodyMetricsState = ref.watch(providerBodyMetrics);
    final lastComposition = bodyMetricsState.compositions.isEmpty
        ? null
        : bodyMetricsState.compositions.first;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Paramètres',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const ScreenSettings(),
              ),
            ),
          ),
        ],
      ),
      body: switch (stateProfile.status) {
        StatusProfile.loading when stateProfile.profile == null => const Center(
          child: CircularProgressIndicator(),
        ),
        StatusProfile.error when stateProfile.profile == null => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stateProfile.errorMessage ?? 'Une erreur est survenue',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(providerProfile.notifier).loadProfile(),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CardProfile(
              profile: stateProfile.profile,
              onEdit: _openProfileForm,
            ),
            const SizedBox(height: 16),
            if (lastComposition != null)
              CardStats(composition: lastComposition),
          ],
        ),
      },
    );
  }
}
