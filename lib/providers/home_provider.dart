import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/home_model.dart';
import '../services/api_client.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  HomeStatus _status = HomeStatus.initial;
  HomeData?  _data;
  String?    _errorMessage;

  HomeStatus get status       => _status;
  HomeData?  get data         => _data;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading    => _status == HomeStatus.loading;
  bool       get hasData      => _data != null;

  Future<void> fetch() async {
    // Don't show full-screen loader on refresh — only on first load
    if (_status != HomeStatus.loaded) {
      _status = HomeStatus.loading;
      notifyListeners();
    }

    try {
      final response = await ApiClient.instance.get(AppConfig.homePath);
      _data         = HomeData.fromJson(response.data);
      _status       = HomeStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status       = HomeStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status       = HomeStatus.error;
      _errorMessage = 'Failed to load home data.';
    }

    notifyListeners();
  }
}
