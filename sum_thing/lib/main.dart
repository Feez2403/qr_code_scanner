import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sum_thing/utils.dart';

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SumThing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("SumThing",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Image.asset('assets/logo.png'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QRSumView(),
                  ),
                );
              },
              child: const Text('Open QR Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}

class QRSumView extends StatefulWidget {
  const QRSumView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRSumViewState();
}

class _QRSumViewState extends State<QRSumView> {
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
          top: 40,
          left: 0,
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
          top: 90,
          left: 0,
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
          top: 130,
          left: 0,
          bottom: 0,
          width: 150,
          child: Container(
            color: Colors.black.withOpacity(0.3),
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Text(
                'Scanned Values:\n${scannedValues.map((s) => "CHF " + s.toString()).join('\n')}',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
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
          if (result?.format == BarcodeFormat.qrcode) {
            double? extracted = extractAmount(scanData.code);
            if (extracted != null) {
              scannedValues.add(extracted);
            } else {
              // INVALID QR CODE (not a QR facture or wrong format)
            }
          } else {
            // NOT A QR CODE
          }
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
