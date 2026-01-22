import 'package:flutter/material.dart';

class SiteInfoRow extends StatelessWidget {
  const SiteInfoRow({
    super.key,
    required this.label, 
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}