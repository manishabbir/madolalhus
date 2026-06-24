import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/plan.dart';
import '../domain/constants/feature_registry.dart';
import '../services/api_response.dart';
import '../di/super_admin_module.dart';
import '../widgets/feature_toggle_chip.dart';

class PlanEditorPage extends StatefulWidget {
  final Plan? plan;

  const PlanEditorPage({super.key, this.plan});

  @override
  State<PlanEditorPage> createState() => _PlanEditorPageState();
}

class _PlanEditorPageState extends State<PlanEditorPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  BillingInterval _billingInterval = BillingInterval.monthly;
  List<String> _selectedFeatures = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.plan?.description ?? '');
    _priceController = TextEditingController(
        text: widget.plan?.priceCents != null
            ? (widget.plan!.priceCents / 100).toStringAsFixed(2)
            : '');
    _billingInterval = widget.plan?.billingInterval ?? BillingInterval.monthly;
    _selectedFeatures = List.from(widget.plan?.featureFlags ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _savePlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final priceCents = (double.tryParse(_priceController.text) ?? 0) * 100;

    late final ApiResponse<Plan> response;
    final service = ProviderScope.containerOf(context).read(planServiceProvider);
    if (widget.plan == null) {
      response = await service.createPlan(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        priceCents: priceCents.toInt(),
        billingInterval: _billingInterval,
        featureFlags: _selectedFeatures,
      );
    } else {
      response = await service.updatePlan(
        id: widget.plan!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        priceCents: priceCents.toInt(),
        billingInterval: _billingInterval,
        featureFlags: _selectedFeatures,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.error?.message}')),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              widget.plan == null ? 'Plan created' : 'Plan updated')),
    );
  }

  Widget _buildBillingOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: isSelected ? theme.primaryColor : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.plan != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Plan' : 'New Plan'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plan name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Billing Interval',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  _buildBillingOption(
                    context,
                    label: 'Monthly',
                    isSelected: _billingInterval == BillingInterval.monthly,
                    onTap: () => setState(() => _billingInterval = BillingInterval.monthly),
                  ),
                  const SizedBox(width: 20),
                  _buildBillingOption(
                    context,
                    label: 'Yearly',
                    isSelected: _billingInterval == BillingInterval.yearly,
                    onTap: () => setState(() => _billingInterval = BillingInterval.yearly),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Features',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final feature in availableFeatures)
                    FeatureToggleChip(
                      featureId: feature,
                      isSelected: _selectedFeatures.contains(feature),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedFeatures.add(feature);
                          } else {
                            _selectedFeatures.remove(feature);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _savePlan,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Update Plan' : 'Create Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
