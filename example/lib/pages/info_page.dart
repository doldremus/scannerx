import 'package:flutter/material.dart';
import 'package:scannerx/scannerx.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final barcode = ModalRoute.of(context)?.settings.arguments as RawBarcode;

    return Scaffold(
      body: Center(
        child: Text(barcode.rawValue ?? ''),
      ),
    );
  }
}
