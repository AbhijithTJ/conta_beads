import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/reverb_websocket_service.dart';
import '../config/app_config.dart';

/// Manages Reverb WebSocket connection lifecycle
class ReverbProvider extends ChangeNotifier {
  final ReverbWebSocketService _webSocketService = ReverbWebSocketService();

  bool _isConnected = false;
  bool _isSubscribed = false;
  String? _connectionError;
  bool _isInitialized = false;
  
  // Completer to wait for connection
  Completer<void>? _connectionCompleter;

  bool get isConnected => _isConnected;
  bool get isSubscribed => _isSubscribed;
  String? get connectionError => _connectionError;
  bool get isInitialized => _isInitialized;

  ReverbWebSocketService get service => _webSocketService;

  /// Initialize and connect to Reverb
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _connectionCompleter = Completer<void>();
      
      // Setup event listener BEFORE connecting
      _webSocketService.events.listen((event) {
        switch (event.type) {
          case ReverbEventType.connected:
            _isConnected = true;
            _connectionError = null;
            debugPrint('[ReverbProvider] ✅ Connected');
            
            // Complete the connection completer if waiting
            if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
              _connectionCompleter!.complete();
            }
            
            notifyListeners();
            break;

          case ReverbEventType.disconnected:
            _isConnected = false;
            _isSubscribed = false;
            debugPrint('[ReverbProvider] 🔌 Disconnected');
            notifyListeners();
            break;

          case ReverbEventType.subscribed:
            _isSubscribed = true;
            debugPrint('[ReverbProvider] ✅ Subscribed');
            notifyListeners();
            break;

          case ReverbEventType.error:
            _connectionError = event.error;
            debugPrint('[ReverbProvider] ❌ Error: ${event.error}');
            
            // Complete with error if waiting
            if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
              _connectionCompleter!.completeError(event.error ?? 'Unknown error');
            }
            
            notifyListeners();
            break;

          default:
            break;
        }
      });

      // Connect to Reverb WebSocket
      await _webSocketService.connect(
        host: AppConfig.reverbHost,
        port: AppConfig.reverbPort,
        appKey: AppConfig.reverbAppKey,
        useTLS: AppConfig.reverbUseTLS,
      );

      _isInitialized = true;
      _connectionError = null;

      // Wait for connection to be established (with timeout)
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        await _connectionCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('WebSocket connection timeout');
          },
        );
      }

      debugPrint('[ReverbProvider] ✅ Initialization complete');
      notifyListeners();
    } catch (e) {
      _connectionError = 'Failed to initialize Reverb: $e';
      debugPrint('[ReverbProvider] ❌ Initialization error: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Subscribe to a channel (waits for connection if needed)
  Future<void> subscribe(String channel) async {
    // Wait for connection if not yet connected
    if (!_isConnected) {
      debugPrint('[ReverbProvider] ⏳ Waiting for connection before subscribing...');
      if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
        await _connectionCompleter!.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('WebSocket connection timeout');
          },
        );
      }
    }
    
    if (!_isConnected) {
      throw Exception('Reverb not connected after timeout');
    }
    
    await _webSocketService.subscribe(channel);
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(String channel) async {
    await _webSocketService.unsubscribe(channel);
  }

  /// Disconnect from Reverb
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
    _isConnected = false;
    _isSubscribed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }
}
