import 'package:collectarr_app/features/comics/comics_clz_style.dart';
import 'package:flutter/material.dart';

class ComicsToolbarSearch extends StatelessWidget {
  const ComicsToolbarSearch({
    super.key,
    required this.controller,
    required this.selectedSeries,
    required this.onSearch,
    required this.onClearSeries,
  });

  final TextEditingController controller;
  final String? selectedSeries;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSeries;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 320,
          child: SearchBar(
            controller: controller,
            constraints: const BoxConstraints.tightFor(height: 32),
            hintText: 'Search comics...',
            leading: const Icon(Icons.search),
            trailing: [
              Tooltip(
                message: 'Search',
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onSearch(controller.text),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                ),
              ),
            ],
            onSubmitted: onSearch,
          ),
        ),
        if (selectedSeries != null) ...[
          const SizedBox(width: 6),
          InputChip(
            visualDensity: VisualDensity.compact,
            backgroundColor: kClzSelection,
            label: Text(selectedSeries!),
            onDeleted: onClearSeries,
          ),
        ],
      ],
    );
  }
}
