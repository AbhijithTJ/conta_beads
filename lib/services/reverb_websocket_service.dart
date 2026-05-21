import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

/// Event types from Reverb WebSocket
enum ReverbEventType {
  connected,
  disconnected,
  subscribed,
  countUpdated,
  leaderboardUpdated,
  error,
}

/// Reverb WebSocket event
class ReverbEvent {
  final ReverbEventType type;
  final dynamic data;
  final String? error;

  ReverbEvent({
    required this.type,
    this.data,
    this.error,
  });
}

/// Direct WebSocket connection to Laravel Reverb
/// This bypasses Pusher SDK limitations and connects directly to your Reverb server
class ReverbWebSocketService {
  late WebSocketChannel _channel;
  bool _isConnected = false;
  bool _isSubscribed = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 25);

  final _eventController = StreamController<ReverbEvent>.broadcast();

  Stream<ReverbEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;
  bool get isSubscribed => _isSubscribed;

  /// Connect to Reverb WebSocket server
  Future<void> connect({
    required String host,
    required int port,
    required String appKey,
    required bool useTLS,
  }) async {
    try {
      final scheme = useTLS ? 'wss' : 'ws';
      final url = '$scheme://$host:$port/app/$appKey';

      debugPrint('[Reverb] 🔌 Connecting to $url');

      final uri = Uri.parse(url);
      
      // Create WebSocket with custom headers
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Origin': '$scheme://$host:$port',
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;

      debugPrint('[Reverb] ✅ Connected to $host:$port');
      _eventController.add(ReverbEvent(type: ReverbEventType.connected));

      // Start ping timer to keep connection alive
      _startPingTimer();

      // Listen to incoming messages
      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDone(),
      );
    } catch (e) {
      debugPrint('[Reverb] ❌ Connection error: $e');
      _isConnected = false;
      _eventController.add(ReverbEvent(
        type: ReverbEventType.error,
        error: 'Failed to connect: $e',
      ));
      _scheduleReconnect();
    }
  }

  /// Subscribe to a channel
  Future<void> subscribe(String channel) async {
    if (!_isConnected) {
      debugPrint('[Reverb] ⚠️ Not connected, cannot subscribe');
      return;
    }

    try {
      final message = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channel,
        },
      });

      _channel.sink.add(message);
      debugPrint('[Reverb] 📤 Subscribed to channel: $channel');
    } catch (e) {
      debugPrint('[Reverb] ❌ Subscribe error: $e');
    }
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(String channel) async {
    if (!_isConnected) return;

    try {
      final message = jsonEncode({
        'event': 'pusher:unsubscribe',
        'data': {
          'channel': channel,
        },
      });

      _channel.sink.add(message);
      debugPrint('[Reverb] 📤 Unsubscribed from channel: $channel');
    } catch (e) {
      debugPrint('[Reverb] ❌ Unsubscribe error: $e');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _reconnectAttempts = 0;

    try {
      await _channel.sink.close();
      _isConnected = false;
      _isSubscribed = false;
      debugPrint('[Reverb] 🔌 Disconnected');
      _eventController.add(ReverbEvent(type: ReverbEventType.disconnected));
    } catch (e) {
      debugPrint('[Reverb] ❌ Disconnect error: $e');
    }
  }

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final event = data['event'] as String?;

      debugPrint('[Reverb] 📨 Event: $event');
      debugPrint('[Reverb] 📄 Full Raw Message: $message');
      debugPrint('[Reverb] 📄 Parsed Data: $data');
      debugPrint('[Reverb] 📄 Data Keys: ${data.keys.toList()}');

      switch (event) {
        case 'pusher:connection_established':
          debugPrint('[Reverb] ✅ Connection established');
          _eventController.add(ReverbEvent(type: ReverbEventType.connected));
          break;

        case 'pusher:pong':
          debugPrint('[Reverb] 💓 Pong received');
          break;

        case 'pusher_internal:subscription_succeeded':
          _isSubscribed = true;
          debugPrint('[Reverb] ✅ Subscription succeeded');
          _eventController.add(ReverbEvent(type: ReverbEventType.subscribed));
          break;

        case 'count.updated':
          try {
            final eventData = data['data'];
            debugPrint('[Reverb] 📊 Raw event data type: ${eventData.runtimeType}');
            debugPrint('[Reverb] 📊 Raw event data: $eventData');
            debugPrint('[Reverb] 📊 Event data length: ${eventData.toString().length} chars');
            
            // Handle both string and map formats
            Map<String, dynamic>? parsedData;
            
            if (eventData is String) {
              // If data is a JSON string, parse it
              debugPrint('[Reverb] 📝 Data is String, parsing JSON...');
              debugPrint('[Reverb] 📝 String length: ${eventData.length} chars');
              parsedData = jsonDecode(eventData) as Map<String, dynamic>;
              debugPrint('[Reverb] 📝 Parsed successfully. Keys: ${parsedData.keys.toList()}');
            } else if (eventData is Map<String, dynamic>) {
              // If data is already a map, use it directly
              debugPrint('[Reverb] 📦 Data is already Map');
              debugPrint('[Reverb] 📦 Map keys: ${eventData.keys.toList()}');
              parsedData = eventData;
            }
            
            if (parsedData != null) {
              debugPrint('[Reverb] 🔍 Full parsed data: $parsedData');
              
              // Backend sends nested structure: { rosary: {...}, chaplet: {...}, triggering_user_id: X }
              // Or sometimes: { data: { rosary: {...}, chaplet: {...}, triggering_user_id: X } }
              
              // Check if data is wrapped in another 'data' key
              final innerData = parsedData['data'] is Map<String, dynamic>
                  ? parsedData['data'] as Map<String, dynamic>
                  : parsedData;
              
              debugPrint('[Reverb] 🔍 Inner data keys: ${innerData.keys.toList()}');
              
              // Extract triggering_user_id if present
              final triggeringUserId = innerData['triggering_user_id'] as int?;
              debugPrint('[Reverb] 🔍 Triggering user ID: $triggeringUserId');
              
              final rosaryData = innerData['rosary'] as Map<String, dynamic>?;
              final chapletData = innerData['chaplet'] as Map<String, dynamic>?;
              
              debugPrint('[Reverb] 🔍 Rosary data found: ${rosaryData != null}');
              debugPrint('[Reverb] 🔍 Chaplet data found: ${chapletData != null}');
              
              if (rosaryData != null) {
                debugPrint('[Reverb] 🔔 Count updated (Rosary): $rosaryData');
                debugPrint('[Reverb] 🔔 Rosary keys: ${rosaryData.keys.toList()}');
                _eventController.add(ReverbEvent(
                  type: ReverbEventType.countUpdated,
                  data: {
                    'prayer_type_id': 1,
                    'triggering_user_id': triggeringUserId,
                    ...rosaryData,
                  },
                ));
              }
              
              if (chapletData != null) {
                debugPrint('[Reverb] 🔔 Count updated (Chaplet): $chapletData');
                debugPrint('[Reverb] 🔔 Chaplet keys: ${chapletData.keys.toList()}');
                _eventController.add(ReverbEvent(
                  type: ReverbEventType.countUpdated,
                  data: {
                    'prayer_type_id': 2,
                    'triggering_user_id': triggeringUserId,
                    ...chapletData,
                  },
                ));
              }
            }
          } catch (e) {
            debugPrint('[Reverb] ❌ Error parsing count.updated: $e');
            debugPrint('[Reverb] ❌ Stack trace: ${StackTrace.current}');
          }
          break;

        case 'leaderboard.updated':
          final eventData = data['data'] as Map<String, dynamic>?;
          if (eventData != null) {
            debugPrint('[Reverb] 🔔 Leaderboard updated: $eventData');
            debugPrint('[Reverb] 🔔 Leaderboard data keys: ${eventData.keys.toList()}');
            debugPrint('[Reverb] 🔔 Full leaderboard: $eventData');
            _eventController.add(ReverbEvent(
              type: ReverbEventType.leaderboardUpdated,
              data: eventData,
            ));
          } else {
            debugPrint('[Reverb] ⚠️ Leaderboard event data is null');
          }
          break;

        default:
          debugPrint('[Reverb] ℹ️ Unknown event: $event');
          // Log all unknown events for debugging
          if (event != null && !event.startsWith('pusher')) {
            debugPrint('[Reverb] 🔍 UNHANDLED EVENT - Details: $data');
          }
      }
    } catch (e) {
      debugPrint('[Reverb] ❌ Error parsing message: $e');
    }
  }

  /// Handle WebSocket error
  void _handleError(dynamic error) {
    debugPrint('[Reverb] ❌ WebSocket error: $error');
    _isConnected = false;
    _eventController.add(ReverbEvent(
      type: ReverbEventType.error,
      error: error.toString(),
    ));
    _scheduleReconnect();
  }

  /// Handle WebSocket closed
  void _handleDone() {
    debugPrint('[Reverb] 🔌 WebSocket closed');
    _isConnected = false;
    _isSubscribed = false;
    _eventController.add(ReverbEvent(type: ReverbEventType.disconnected));
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[Reverb] ⚠️ Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delay = _reconnectDelay * _reconnectAttempts;
    debugPrint('[Reverb] ⏱️ Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected) {
        debugPrint('[Reverb] 🔄 Attempting to reconnect...');
      }
    });
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      if (_isConnected) {
        try {
          final message = jsonEncode({
            'event': 'pusher:ping',
            'data': {},
          });
          _channel.sink.add(message);
          debugPrint('[Reverb] 💓 Ping sent');
        } catch (e) {
          debugPrint('[Reverb] ❌ Ping error: $e');
        }
      }
    });
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    _eventController.close();
    try {
      _channel.sink.close();
    } catch (e) {
      debugPrint('[Reverb] Error closing channel: $e');
    }
  }
}
