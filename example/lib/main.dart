import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner_example/utils.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRViewExample(),
              ),
            );
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  List<double> scannedValues = [];

  double get totalSum => scannedValues.fold(0, (sum, item) => sum + item);

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildQrView(context),
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(8),
            child: Text(
              'Total: CHF ${totalSum.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: ElevatedButton(
            onPressed: scannedValues.isNotEmpty
                ? () {
                    setState(() {
                      scannedValues.removeLast();
                      result = null;
                    });
                  }
                : null,
            child: const Text('Undo Last Value'),
          ),
        ),
        Positioned(
          top: 100,
          left: 20,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(8),
            child: Text(
              'Scanned Values:\n${scannedValues.map((s) => "CHF " + s.toString()).join('\n')}',
              style: const TextStyle(color: Colors.grey, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (result?.code != scanData.code) {
        setState(() {
          result = scanData;
          double extracted = extractAmount(scanData.code) ?? 0.0;
          scannedValues.add(extracted);
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
