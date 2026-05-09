import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/priest_model.dart';
import '../services/api_client.dart';

enum AdoptPriestStatus { initial, loading, success, error }

class AdoptPriestProvider extends ChangeNotifier {
  AdoptPriestStatus _status = AdoptPriestStatus.initial;
  AdoptPriestsResponse? _response;
  String _errorMessage = '';
  
  // For saved priests
  List<AdoptedPriest> _savedPriests = [];
  int _remainingSlots = 3;
  bool _isLoadingSavedPriests = false;

  // Getters
  AdoptPriestStatus get status => _status;
  AdoptPriestsResponse? get response => _response;
  String get errorMessage => _errorMessage;
  
  List<AdoptedPriest> get savedPriests => _savedPriests;
  int get remainingSlots => _remainingSlots;
  bool get isLoadingSavedPriests => _isLoadingSavedPriests;

  bool get isLoading => _status == AdoptPriestStatus.loading;
  bool get isSuccess => _status == AdoptPriestStatus.success;
  bool get isError => _status == AdoptPriestStatus.error;

  /// Fetch saved/adopted priests
  Future<void> fetchSavedPriests() async {
    _isLoadingSavedPriests = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(
        AppConfig.myPriestsPath,
      );

      final savedResponse = SavedPriestsResponse.fromJson(response.data);

      if (savedResponse.success) {
        _savedPriests = savedResponse.priests;
        _remainingSlots = savedResponse.remainingSlots;
      } else {
        _savedPriests = [];
        _remainingSlots = 3;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _savedPriests = [];
      _remainingSlots = 3;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _savedPriests = [];
      _remainingSlots = 3;
    }

    _isLoadingSavedPriests = false;
    notifyListeners();
  }

  /// Unadopt a priest by ID
  Future<bool> unadoptPriest(int priestId) async {
    try {
      final response = await ApiClient.instance.delete(
        '${AppConfig.priestsPath}/$priestId/unadopt',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove from saved priests list
        _savedPriests.removeWhere((p) => p.id == priestId);
        
        // Update remaining slots from response if available
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        _remainingSlots = data['remaining_slots'] as int? ?? _remainingSlots;
        
        notifyListeners();
        return true;
      }
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Adopt priests by sending their IDs to the backend
  Future<void> adoptPriests(List<int> priestIds) async {
    if (priestIds.isEmpty) {
      _status = AdoptPriestStatus.error;
      _errorMessage = 'Please select at least one priest';
      notifyListeners();
      return;
    }

    _status = AdoptPriestStatus.loading;
    _errorMessage = '';
    _response = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(
        AppConfig.priestsAdoptPath,
        body: {'priest_ids': priestIds},
      );

      final adoptResponse = AdoptPriestsResponse.fromJson(response.data);

      if (adoptResponse.success) {
        _status = AdoptPriestStatus.success;
        _response = adoptResponse;
        _errorMessage = '';
        
        // Update saved priests and remaining slots
        _savedPriests = adoptResponse.adoptedPriests;
        _remainingSlots = adoptResponse.remainingSlots;
      } else {
        _status = AdoptPriestStatus.error;
        _errorMessage = adoptResponse.message;
        _response = null;
      }
    } on ApiException catch (e) {
      _status = AdoptPriestStatus.error;
      _errorMessage = e.message;
      _response = null;
    } catch (e) {
      _status = AdoptPriestStatus.error;
      _errorMessage = 'Unexpected error: $e';
      _response = null;
    }

    notifyListeners();
  }

  /// Reset the provider to initial state
  void reset() {
    _status = AdoptPriestStatus.initial;
    _response = null;
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
