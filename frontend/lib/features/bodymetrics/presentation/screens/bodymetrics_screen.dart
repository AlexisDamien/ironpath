import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bodymetrics_provider.dart';
import '../../domain/bodymetrics_state.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/body_composition.dart';

class BodyMetricsScreen extends ConsumerStatefulWidget {
  const BodyMetricsScreen({super.key});

  @override
  ConsumerState<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends ConsumerState<BodyMetricsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(bodyMetricsProvider.notifier).loadMeasurements();
      ref.read(bodyMetricsProvider.notifier).loadCompositions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyMetricsState = ref.watch(bodyMetricsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Mesures corporelles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mensurations'),
            Tab(text: 'Composition'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: bodyMetricsState.status == BodyMetricsStatus.loading &&
              !bodyMetricsState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementsList(context, bodyMetricsState.measurements),
                _buildCompositionsList(context, bodyMetricsState.compositions),
              ],
            ),
    );
  }

  Widget _buildMeasurementsList(
      BuildContext context, List<BodyMeasurement> measurements) {
    if (measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune mensuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute ta première mesure',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bodyMetricsProvider.notifier).loadMeasurements(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: measurements.length,
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return _buildMeasurementCard(
            context,
            measurement,
            isEditable: measurement.isEditable,
            key: ValueKey(measurement.id),
          );
        },
      ),
    );
  }

  Widget _buildMeasurementCard(
      BuildContext context, BodyMeasurement measurement,
      {bool isEditable = false, Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(measurement.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (measurement.weight != null)
                      Text(
                        '${measurement.weight} kg',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () =>
                            _showEditMeasurementSheet(context, measurement),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () =>
                            _confirmDeleteMeasurement(context, measurement),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (measurement.chest != null)
                  _buildMetricChip(
                      context, 'Poitrine', '${measurement.chest} cm'),
                if (measurement.waist != null)
                  _buildMetricChip(
                      context, 'Taille', '${measurement.waist} cm'),
                if (measurement.hips != null)
                  _buildMetricChip(
                      context, 'Hanches', '${measurement.hips} cm'),
                if (measurement.leftArm != null)
                  _buildMetricChip(
                      context, 'Bras G', '${measurement.leftArm} cm'),
                if (measurement.rightArm != null)
                  _buildMetricChip(
                      context, 'Bras D', '${measurement.rightArm} cm'),
                if (measurement.leftThigh != null)
                  _buildMetricChip(
                      context, 'Cuisse G', '${measurement.leftThigh} cm'),
                if (measurement.rightThigh != null)
                  _buildMetricChip(
                      context, 'Cuisse D', '${measurement.rightThigh} cm'),
                if (measurement.leftCalf != null)
                  _buildMetricChip(
                      context, 'Mollet G', '${measurement.leftCalf} cm'),
                if (measurement.rightCalf != null)
                  _buildMetricChip(
                      context, 'Mollet D', '${measurement.rightCalf} cm'),
              ],
            ),
            if (measurement.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                measurement.notes!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompositionsList(
      BuildContext context, List<BodyComposition> compositions) {
    if (compositions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune composition',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoute ta première composition corporelle',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bodyMetricsProvider.notifier).loadCompositions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: compositions.length,
        itemBuilder: (context, index) {
          final composition = compositions[index];
          return _buildCompositionCard(
            context,
            composition,
            isEditable: composition.isEditable,
            key: ValueKey(composition.id),
          );
        },
      ),
    );
  }

  Widget _buildCompositionCard(
      BuildContext context, BodyComposition composition,
      {bool isEditable = false, Key? key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(composition.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (composition.bmi != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'BMI ${composition.bmi!.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      if (composition.isManual)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () =>
                              _showEditCompositionSheet(context, composition),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () =>
                              _showConnectedDeviceDialog(context, composition),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: () =>
                            _confirmDeleteComposition(context, composition),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (composition.bodyFat != null)
                  _buildMetricChip(
                      context, 'Masse grasse', '${composition.bodyFat}%'),
                if (composition.skeletalMuscle != null)
                  _buildMetricChip(context, 'Muscle squelettique',
                      '${composition.skeletalMuscle}%'),
                if (composition.bodyWater != null)
                  _buildMetricChip(context, 'Eau', '${composition.bodyWater}%'),
                if (composition.muscleMass != null)
                  _buildMetricChip(context, 'Masse musculaire',
                      '${composition.muscleMass} kg'),
                if (composition.boneMass != null)
                  _buildMetricChip(
                      context, 'Masse osseuse', '${composition.boneMass} kg'),
                if (composition.visceralFat != null)
                  _buildMetricChip(context, 'Graisse viscérale',
                      '${composition.visceralFat}'),
                if (composition.bmr != null)
                  _buildMetricChip(context, 'BMR', '${composition.bmr} kcal'),
                if (composition.metabolicAge != null)
                  _buildMetricChip(context, 'Âge métabolique',
                      '${composition.metabolicAge} ans'),
              ],
            ),
            if (composition.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                composition.notes!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMetricsSheet(
        selectedTab: _tabController.index,
      ),
    );
  }

  void _showEditMeasurementSheet(
      BuildContext context, BodyMeasurement measurement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMetricsSheet(
        selectedTab: 0,
        measurementToEdit: measurement,
      ),
    );
  }

  void _showEditCompositionSheet(
      BuildContext context, BodyComposition composition) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMetricsSheet(
        selectedTab: 1,
        compositionToEdit: composition,
      ),
    );
  }

  void _confirmDeleteMeasurement(
      BuildContext context, BodyMeasurement measurement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la mesure'),
        content: Text(
            'Supprimer la mesure du ${_formatDate(measurement.recordedAt)} ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(bodyMetricsProvider.notifier)
                  .deleteMeasurement(measurement.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComposition(
      BuildContext context, BodyComposition composition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la composition'),
        content: Text(
            'Supprimer la composition du ${_formatDate(composition.recordedAt)} ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(bodyMetricsProvider.notifier)
                  .deleteComposition(composition.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showConnectedDeviceDialog(
      BuildContext context, BodyComposition composition) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Données balance connectée'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ces données proviennent d\'une balance connectée et ne peuvent pas être modifiées directement.',
            ),
            SizedBox(height: 16),
            Text(
              'Voulez-vous créer une nouvelle entrée manuelle basée sur ces données ?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditCompositionSheet(context, composition);
            },
            child: const Text('Créer une entrée manuelle'),
          ),
        ],
      ),
    );
  }
}

class _AddMetricsSheet extends ConsumerStatefulWidget {
  final int selectedTab;
  final BodyMeasurement? measurementToEdit;
  final BodyComposition? compositionToEdit;

  const _AddMetricsSheet({
    required this.selectedTab,
    this.measurementToEdit,
    this.compositionToEdit,
  });

  @override
  ConsumerState<_AddMetricsSheet> createState() => _AddMetricsSheetState();
}

class _AddMetricsSheetState extends ConsumerState<_AddMetricsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _leftArmController = TextEditingController();
  final _rightArmController = TextEditingController();
  final _leftThighController = TextEditingController();
  final _rightThighController = TextEditingController();
  final _leftCalfController = TextEditingController();
  final _rightCalfController = TextEditingController();
  final _measurementNotesController = TextEditingController();

  final _bodyFatController = TextEditingController();
  final _skeletalMuscleController = TextEditingController();
  final _fatFreeMassController = TextEditingController();
  final _subcutaneousFatController = TextEditingController();
  final _visceralFatController = TextEditingController();
  final _bodyWaterController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _boneMassController = TextEditingController();
  final _proteinController = TextEditingController();
  final _bmrController = TextEditingController();
  final _compositionNotesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.selectedTab,
    );

    if (widget.measurementToEdit != null) {
      final measurement = widget.measurementToEdit!;
      _weightController.text = measurement.weight?.toString() ?? '';
      _chestController.text = measurement.chest?.toString() ?? '';
      _waistController.text = measurement.waist?.toString() ?? '';
      _hipsController.text = measurement.hips?.toString() ?? '';
      _leftArmController.text = measurement.leftArm?.toString() ?? '';
      _rightArmController.text = measurement.rightArm?.toString() ?? '';
      _leftThighController.text = measurement.leftThigh?.toString() ?? '';
      _rightThighController.text = measurement.rightThigh?.toString() ?? '';
      _leftCalfController.text = measurement.leftCalf?.toString() ?? '';
      _rightCalfController.text = measurement.rightCalf?.toString() ?? '';
      _measurementNotesController.text = measurement.notes ?? '';
    }

    if (widget.compositionToEdit != null) {
      final composition = widget.compositionToEdit!;
      _bodyFatController.text = composition.bodyFat?.toString() ?? '';
      _skeletalMuscleController.text =
          composition.skeletalMuscle?.toString() ?? '';
      _fatFreeMassController.text = composition.fatFreeMass?.toString() ?? '';
      _subcutaneousFatController.text =
          composition.subcutaneousFat?.toString() ?? '';
      _visceralFatController.text = composition.visceralFat?.toString() ?? '';
      _bodyWaterController.text = composition.bodyWater?.toString() ?? '';
      _muscleMassController.text = composition.muscleMass?.toString() ?? '';
      _boneMassController.text = composition.boneMass?.toString() ?? '';
      _proteinController.text = composition.protein?.toString() ?? '';
      _bmrController.text = composition.bmr?.toString() ?? '';
      _compositionNotesController.text = composition.notes ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _leftArmController.dispose();
    _rightArmController.dispose();
    _leftThighController.dispose();
    _rightThighController.dispose();
    _leftCalfController.dispose();
    _rightCalfController.dispose();
    _measurementNotesController.dispose();
    _bodyFatController.dispose();
    _skeletalMuscleController.dispose();
    _fatFreeMassController.dispose();
    _subcutaneousFatController.dispose();
    _visceralFatController.dispose();
    _bodyWaterController.dispose();
    _muscleMassController.dispose();
    _boneMassController.dispose();
    _proteinController.dispose();
    _bmrController.dispose();
    _compositionNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitMeasurement() async {
    setState(() => _isLoading = true);
    try {
      if (widget.measurementToEdit != null) {
        await ref.read(bodyMetricsProvider.notifier).updateMeasurement(
              measurementId: widget.measurementToEdit!.id,
              weight: double.tryParse(_weightController.text),
              chest: double.tryParse(_chestController.text),
              waist: double.tryParse(_waistController.text),
              hips: double.tryParse(_hipsController.text),
              leftArm: double.tryParse(_leftArmController.text),
              rightArm: double.tryParse(_rightArmController.text),
              leftThigh: double.tryParse(_leftThighController.text),
              rightThigh: double.tryParse(_rightThighController.text),
              leftCalf: double.tryParse(_leftCalfController.text),
              rightCalf: double.tryParse(_rightCalfController.text),
              notes: _measurementNotesController.text.isEmpty
                  ? null
                  : _measurementNotesController.text,
            );
      } else {
        await ref.read(bodyMetricsProvider.notifier).saveMeasurement(
              weight: double.tryParse(_weightController.text),
              chest: double.tryParse(_chestController.text),
              waist: double.tryParse(_waistController.text),
              hips: double.tryParse(_hipsController.text),
              leftArm: double.tryParse(_leftArmController.text),
              rightArm: double.tryParse(_rightArmController.text),
              leftThigh: double.tryParse(_leftThighController.text),
              rightThigh: double.tryParse(_rightThighController.text),
              leftCalf: double.tryParse(_leftCalfController.text),
              rightCalf: double.tryParse(_rightCalfController.text),
              notes: _measurementNotesController.text.isEmpty
                  ? null
                  : _measurementNotesController.text,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComposition() async {
    setState(() => _isLoading = true);
    try {
      if (widget.compositionToEdit != null) {
        await ref.read(bodyMetricsProvider.notifier).updateComposition(
              compositionId: widget.compositionToEdit!.id,
              bodyFat: double.tryParse(_bodyFatController.text),
              skeletalMuscle: double.tryParse(_skeletalMuscleController.text),
              fatFreeMass: double.tryParse(_fatFreeMassController.text),
              subcutaneousFat: double.tryParse(_subcutaneousFatController.text),
              visceralFat: int.tryParse(_visceralFatController.text),
              bodyWater: double.tryParse(_bodyWaterController.text),
              muscleMass: double.tryParse(_muscleMassController.text),
              boneMass: double.tryParse(_boneMassController.text),
              protein: double.tryParse(_proteinController.text),
              bmr: int.tryParse(_bmrController.text),
              notes: _compositionNotesController.text.isEmpty
                  ? null
                  : _compositionNotesController.text,
            );
      } else {
        await ref.read(bodyMetricsProvider.notifier).saveComposition(
              bodyFat: double.tryParse(_bodyFatController.text),
              skeletalMuscle: double.tryParse(_skeletalMuscleController.text),
              fatFreeMass: double.tryParse(_fatFreeMassController.text),
              subcutaneousFat: double.tryParse(_subcutaneousFatController.text),
              visceralFat: int.tryParse(_visceralFatController.text),
              bodyWater: double.tryParse(_bodyWaterController.text),
              muscleMass: double.tryParse(_muscleMassController.text),
              boneMass: double.tryParse(_boneMassController.text),
              protein: double.tryParse(_proteinController.text),
              bmr: int.tryParse(_bmrController.text),
              notes: _compositionNotesController.text.isEmpty
                  ? null
                  : _compositionNotesController.text,
            );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing =
        widget.measurementToEdit != null || widget.compositionToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Modifier la mesure' : 'Ajouter une mesure',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Mensurations'),
              Tab(text: 'Composition'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementForm(bottomInset),
                _buildCompositionForm(bottomInset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementForm(double bottomInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(_weightController, 'Poids (kg)', decimal: true),
          const SizedBox(height: 16),
          const Text(
            'Mensurations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_chestController, 'Poitrine',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _buildTextField(_waistController, 'Taille', decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child:
                    _buildTextField(_hipsController, 'Hanches', decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftArmController, 'Bras G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightArmController, 'Bras D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftThighController, 'Cuisse G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightThighController, 'Cuisse D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_leftCalfController, 'Mollet G',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_rightCalfController, 'Mollet D',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_measurementNotesController, 'Notes (optionnel)',
              maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitMeasurement,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionForm(double bottomInset) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(_bodyFatController, 'Masse grasse (%)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _skeletalMuscleController, 'Muscle squelettique (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _fatFreeMassController, 'Masse maigre (kg)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _subcutaneousFatController, 'Graisse sous-cutanée (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _visceralFatController, 'Graisse viscérale'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _bodyWaterController, 'Eau corporelle (%)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _muscleMassController, 'Masse musculaire (kg)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                    _boneMassController, 'Masse osseuse (kg)',
                    decimal: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_proteinController, 'Protéines (%)',
                    decimal: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_bmrController, 'BMR (kcal)'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(_compositionNotesController, 'Notes (optionnel)',
              maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitComposition,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool decimal = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : maxLines > 1
              ? TextInputType.multiline
              : TextInputType.number,
      maxLines: maxLines,
    );
  }
}
