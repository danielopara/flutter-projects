import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../state/inventory_store.dart';
import '../widgets/scan_result_sheet.dart';

class ScannerScreen extends StatefulWidget {
  /// Continuous mode: look each code up and show the adjustment sheet.
  const ScannerScreen({super.key}) : pickMode = false;

  /// Pick mode: scan one code and pop it back to the caller.
  const ScannerScreen.pick({super.key}) : pickMode = true;

  final bool pickMode;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.all],
  );

  bool _sheetOpen = false;
  String? _lastCode;
  DateTime _lastScanAt = DateTime.fromMillisecondsSinceEpoch(0);
  int _scannedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_sheetOpen) unawaited(_controller.start());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_sheetOpen) return;

    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    final now = DateTime.now();
    if (code == _lastCode && now.difference(_lastScanAt).inSeconds < 2) return;

    _lastCode = code;
    _lastScanAt = now;

    await _handleCode(code);
  }

  Future<void> _handleCode(String code) async {
    // Pick mode: hand the code straight back and close.
    if (widget.pickMode) {
      Navigator.of(context).pop(code);
      return;
    }

    final store = context.read<InventoryStore>();
    final Item? item = await store.lookUp(code);

    if (!mounted) return;

    setState(() => _sheetOpen = true);
    await _controller.stop();

    final handled = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ScanResultSheet(barcode: code, item: item),
    );

    if (!mounted) return;

    if (handled == true) setState(() => _scannedCount++);
    setState(() => _sheetOpen = false);
    await _controller.start();
  }

  Future<void> _manualEntry() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualEntryDialog(),
    );

    if (code != null && code.isNotEmpty && mounted) {
      await _handleCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.pickMode
              ? 'Scan barcode'
              : (_scannedCount == 0 ? 'Scan' : '$_scannedCount scanned'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_outlined),
            tooltip: 'Manual entry',
            onPressed: _manualEntry,
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_on_outlined),
            tooltip: 'Torch',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: 'Flip camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _CameraError(error: error),
          ),
          const _ScanReticle(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Text(
              widget.pickMode
                  ? 'Point at the barcode to register'
                  : 'Point at a barcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter barcode'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'e.g. 6009510800012',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Look up'),
        ),
      ],
    );
  }
}

class _ScanReticle extends StatelessWidget {
  const _ScanReticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Camera permission denied. Enable it in Settings, then reopen this screen.',
      MobileScannerErrorCode.unsupported =>
        'This device does not support barcode scanning.',
      _ => 'Camera error: ${error.errorCode.name}',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              size: 56,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
