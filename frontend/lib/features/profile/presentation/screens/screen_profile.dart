import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_profile.dart';
import '../../domain/state_profile.dart';
import '../screens/screen_edit_profile.dart';
import '../screens/screen_settings.dart';
import '../widgets/card_profile.dart';
import '../widgets/card_stats.dart';
import '../../../bodymetrics/presentation/providers/provider_bodymetrics.dart';

class ScreenProfile extends ConsumerStatefulWidget {
  const ScreenProfile({super.key});

  @override
  ConsumerState<ScreenProfile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ScreenProfile> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(providerProfile.notifier).loadProfile();
      ref.read(providerBodyMetrics.notifier).loadMeasurements();
      ref.read(providerBodyMetrics.notifier).loadCompositions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateProfile = ref.watch(providerProfile);
    final bodyMetricsState = ref.watch(providerBodyMetrics);
    final profile = stateProfile.profile;

    final lastComposition = bodyMetricsState.compositions.isNotEmpty
        ? bodyMetricsState.compositions.first
        : null;

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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const ScreenSettings(),
              ),
            ),
          ),
        ],
      ),
      body: stateProfile.status == StatusProfile.loading
          ? const Center(child: CircularProgressIndicator())
          : stateProfile.status == StatusProfile.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stateProfile.errorMessage ?? 'Une erreur est survenue',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(providerProfile.notifier).loadProfile(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CardProfile(
                      profile: profile,
                      onEdit: () async {
                        final saved = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => ScreenEditProfile(
                              profile: profile,
                            ),
                          ),
                        );

                        if (saved == true && context.mounted) {
                          await ref
                              .read(providerProfile.notifier)
                              .loadProfile();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (lastComposition != null)
                      CardStats(composition: lastComposition),
                  ],
                ),
    );
  }
}
