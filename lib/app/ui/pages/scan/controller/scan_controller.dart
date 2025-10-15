import 'package:ecuscanqr/app/domain/model/hive/qr_code_model.dart';
import 'package:ecuscanqr/app/domain/repository/qr_repository.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends SimpleNotifier {
  final qrRepository = Get.find<QrRepository>();

  MobileScannerController? scannerController;
  
  bool _isScanning = false;
  bool _hasPermission = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String? _lastScannedCode;
  bool _isInitializing = false;

  bool get isScanning => _isScanning;
  bool get hasPermission => _hasPermission;
  bool get isFlashOn => _isFlashOn;
  bool get isFrontCamera => _isFrontCamera;
  String? get lastScannedCode => _lastScannedCode;
  bool get isInitializing => _isInitializing;

  ScanController() {
    _initScanner();
  }

  Future<void> _initScanner() async {
    _isInitializing = true;
    notify();

    await _checkCameraPermission();
    
    if (_hasPermission) {
      try {
        scannerController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        );
        
        // Pequeño delay para asegurar que el controller esté listo
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Error initializing scanner: $e');
        _hasPermission = false;
      }
    }
    
    _isInitializing = false;
    notify();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        _hasPermission = true;
      } else if (status.isDenied) {
        // No hacer nada aquí, esperar a que el usuario presione el botón
        _hasPermission = false;
      } else if (status.isPermanentlyDenied) {
        _hasPermission = false;
      } else if (status.isRestricted) {
        // iOS specific - cuando los permisos están restringidos por parental controls
        _hasPermission = false;
      }
    } catch (e) {
      print('Error checking camera permission: $e');
      _hasPermission = false;
    }
    
    notify();
  }

  Future<bool> requestPermission() async {
    try {
      _isInitializing = true;
      notify();

      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        _hasPermission = true;
        
        // Inicializar el scanner después de obtener permiso
        if (scannerController == null) {
          scannerController = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
            facing: CameraFacing.back,
            torchEnabled: false,
          );
          
          // Pequeño delay para asegurar que el controller esté listo
          await Future.delayed(const Duration(milliseconds: 300));
        }
        
        _isInitializing = false;
        notify();
        return true;
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        _hasPermission = false;
        _isInitializing = false;
        notify();
        
        // En iOS, abrir settings
        await openAppSettings();
        return false;
      } else {
        _hasPermission = false;
        _isInitializing = false;
        notify();
        return false;
      }
    } catch (e) {
      print('Error requesting permission: $e');
      _hasPermission = false;
      _isInitializing = false;
      notify();
      return false;
    }
  }

  void onDetect(BarcodeCapture barcodeCapture) {
    if (_isScanning) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _isScanning = true;
    _lastScannedCode = barcode!.rawValue;
    
    // Guardar en historial automáticamente
    _saveScannedQr(_lastScannedCode!);
    
    notify();

    // Resetear después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      _isScanning = false;
      notify();
    });
  }

  Future<void> _saveScannedQr(String data) async {
    try {
      final qrCode = QrCodeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _detectQrType(data),
        data: data,
        displayTitle: _generateTitle(data),
        createdAt: DateTime.now(),
        isScanned: true,
      );

      await qrRepository.saveQr(qrCode);
    } catch (e) {
      print('Error saving scanned QR: $e');
    }
  }

  String _detectQrType(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return 'website';
    } else if (data.startsWith('mailto:')) {
      return 'email';
    } else if (data.startsWith('tel:')) {
      return 'phone';
    } else if (data.startsWith('SMSTO:')) {
      return 'sms';
    } else if (data.startsWith('WIFI:')) {
      return 'wifi';
    } else {
      return 'text';
    }
  }

  String _generateTitle(String data) {
    if (data.length > 30) {
      return '${data.substring(0, 30)}...';
    }
    return data;
  }

  void toggleFlash() {
    if (scannerController == null) return;
    _isFlashOn = !_isFlashOn;
    scannerController!.toggleTorch();
    notify();
  }

  void switchCamera() {
    if (scannerController == null) return;
    _isFrontCamera = !_isFrontCamera;
    scannerController!.switchCamera();
    notify();
  }

  void resetScan() {
    _lastScannedCode = null;
    _isScanning = false;
    notify();
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }
}