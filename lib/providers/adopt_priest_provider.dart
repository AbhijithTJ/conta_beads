import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/priest_model.dart';
import '../services/api_client.dart';

enum AdoptPriestStatus { initial, loading, success, error }

class AdoptPriestProvider extends ChangeNotifier {
  AdoptPriestStatus _status = AdoptPriestStatus.initial;
  AdoptPriestsResponse? _response;
  String _errorMessage = '';

  // Getters
  AdoptPriestStatus get status => _status;
  AdoptPriestsResponse? get response => _response;
  String get errorMessage => _errorMessage;

  bool get isLoading => _status == AdoptPriestStatus.loading;
  bool get isSuccess => _status == AdoptPriestStatus.success;
  bool get isError => _status == AdoptPriestStatus.error;

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
