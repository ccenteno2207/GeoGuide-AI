import 'package:flutter/material.dart';

import 'poi_presentation.dart';

class DiscoveryFilterSheet extends StatefulWidget {
  const DiscoveryFilterSheet({super.key, required this.appliedCategories});

  final Set<String> appliedCategories;

  @override
  State<DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends State<DiscoveryFilterSheet> {
  late Set<String> _draft;

  @override
  void initState() {
    super.initState();
    _draft = {...widget.appliedCategories};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtrar lugares', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SizedBox(
              height: 360,
              child: ListView(
                children: [
                  for (final code in discoveryCategoryCodes)
                    CheckboxListTile(
                      value: _draft.contains(code),
                      title: Text(friendlyPoiCategory(code)),
                      onChanged: (selected) => setState(() {
                        if (selected == true) {
                          _draft.add(code);
                        } else {
                          _draft.remove(code);
                        }
                      }),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                )),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton(
                  onPressed: () => setState(() => _draft = {...discoveryCategoryCodes}),
                  child: const Text('Restablecer'),
                )),
                const SizedBox(width: 8),
                Expanded(child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(Set<String>.unmodifiable(_draft)),
                  child: const Text('Aplicar'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
