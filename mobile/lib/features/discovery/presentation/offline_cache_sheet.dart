import 'package:flutter/material.dart';

import '../application/offline_discovery.dart';

class OfflineCacheSheet extends StatelessWidget {
  const OfflineCacheSheet({super.key, required this.controller});
  final OfflineDiscovery controller;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Copia offline',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            'Permite conservar una consulta reemplazable durante 24 horas, hasta 5 MiB. Puede revelar tu intención de viaje. No se incluye en backups ni transferencias y puedes borrarla. No incluye mapas offline. Al cerrar la app, nuevas capturas requieren permiso otra vez.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: controller.saving
                ? null
                : () async {
                    Navigator.of(context).pop();
                    await controller.enableCapture();
                  },
            child: const Text('Permitir copia offline durante esta sesión'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.delete();
            },
            child: const Text('Eliminar copia offline y desactivar captura'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Volver'),
          ),
        ],
      ),
    ),
  );
}
