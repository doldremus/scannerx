import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('ScannerX')),
        backgroundColor: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.background,
          Theme.of(context).colorScheme.surfaceTint,
          3,
        ),
      ),
      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('camera'),
              child: const Text('Scan', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
