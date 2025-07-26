import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class ResponsiveMasterDetail extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    bool isSelected,
    void Function(Widget) onItemSelected,
  )
  masterBuilder;
  final Widget? detailPlaceholder;
  final double masterWidth;
  final bool showDivider;

  const ResponsiveMasterDetail({
    super.key,
    required this.masterBuilder,
    this.detailPlaceholder,
    this.masterWidth = 400,
    this.showDivider = true,
  });

  @override
  State<ResponsiveMasterDetail> createState() => _ResponsiveMasterDetailState();
}

class _ResponsiveMasterDetailState extends State<ResponsiveMasterDetail> {
  Widget? _selectedDetail;

  void _onItemSelected(Widget detailWidget) {
    setState(() {
      _selectedDetail = detailWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTabletLandscape = context.isTabletOrLarger && context.isLandscape;

    if (isTabletLandscape) {
      // Layout para tablets em landscape
      return Row(
        children: [
          SizedBox(
            width: widget.masterWidth,
            child: widget.masterBuilder(
              context,
              _selectedDetail != null,
              _onItemSelected,
            ),
          ),
          if (widget.showDivider) const VerticalDivider(width: 1),
          Expanded(
            child:
                _selectedDetail ??
                widget.detailPlaceholder ??
                _buildDefaultPlaceholder(context),
          ),
        ],
      );
    }

    // Layout para mobile ou tablet portrait
    return widget.masterBuilder(context, false, (detail) {
      // Em mobile, navegar para uma nova página
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(appBar: AppBar(), body: detail),
        ),
      );
    });
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Selecione um item para ver os detalhes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
