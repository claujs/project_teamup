import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/advanced_filter.dart';

class AdvancedFilterDialog extends StatefulWidget {
  const AdvancedFilterDialog({
    super.key,
    this.initialFilter,
    required this.onApply,
  });

  final AdvancedFilter? initialFilter;
  final Function(AdvancedFilter) onApply;

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  late TextEditingController _departmentController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _positionController;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final filter = widget.initialFilter ?? const AdvancedFilter();

    _nameController = TextEditingController(text: filter.name ?? '');
    _emailController = TextEditingController(text: filter.email ?? '');
    _departmentController = TextEditingController(
      text: filter.department ?? '',
    );
    _positionController = TextEditingController(text: filter.position ?? '');
  }

  void _applyFilter() {
    final filter = AdvancedFilter(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      department: _departmentController.text.trim().isEmpty
          ? null
          : _departmentController.text.trim(),
      position: _positionController.text.trim().isEmpty
          ? null
          : _positionController.text.trim(),
    );

    widget.onApply(filter);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _departmentController.clear();
      _positionController.clear();
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 12,
          horizontal: 16,
        ),
      ),
      style: TextStyle(fontSize: isTablet ? 16 : 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTablet = context.isTabletOrLarger;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isTablet ? 500 : double.infinity,
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: isTablet ? 28 : 24,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Text(
                  l10n.advancedFilter,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  iconSize: isTablet ? 28 : 24,
                ),
              ],
            ),

            SizedBox(height: isTablet ? 32 : 24),
            _buildTextField(
              controller: _nameController,
              label: l10n.name,
              hint: l10n.searchByName,
              icon: Icons.person_outline,
              isTablet: isTablet,
            ),

            SizedBox(height: isTablet ? 20 : 16),
            _buildTextField(
              controller: _emailController,
              label: l10n.email,
              hint: l10n.searchByEmail,
              icon: Icons.email_outlined,
              isTablet: isTablet,
            ),

            SizedBox(height: isTablet ? 20 : 16),
            _buildTextField(
              controller: _departmentController,
              label: l10n.department,
              hint: l10n.searchByDepartment,
              icon: Icons.business_outlined,
              isTablet: isTablet,
            ),

            SizedBox(height: isTablet ? 20 : 16),

            _buildTextField(
              controller: _positionController,
              label: l10n.position,
              hint: l10n.searchByPosition,
              icon: Icons.work_outline,
              isTablet: isTablet,
            ),

            SizedBox(height: isTablet ? 32 : 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear),
                    label: Text(l10n.clear),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _applyFilter,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.apply),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
