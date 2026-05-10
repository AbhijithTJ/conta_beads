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

  /// Refresh only text content (quotes, titles) without showing loader.
  /// Used for language changes to update text without reloading images.
  Future<void> refreshTextOnly() async {
    try {
      final response = await ApiClient.instance.get(AppConfig.homePath);
      final newData = HomeData.fromJson(response.data);
      
      // Update section titles but preserve image URLs to avoid reload
      if (_data != null && newData.sections.isNotEmpty) {
        final updatedSections = <HomeSection>[];
        
        for (int i = 0; i < _data!.sections.length && i < newData.sections.length; i++) {
          final oldSection = _data!.sections[i];
          final newSection = newData.sections[i];
          
          // Create new section with updated title but old image URL
          updatedSections.add(HomeSection(
            id: newSection.id,
            title: newSection.title,  // ✅ New title (Malayalam)
            description: newSection.description,
            image: oldSection.image,  // ✅ Keep old image URL (no reload)
            route: newSection.route,
            icon: newSection.icon,
            type: newSection.type,
            order: newSection.order,
          ));
        }
        
        _data = HomeData(
          quotes: newData.quotes,
          sections: updatedSections,
          user: newData.user,
        );
      } else {
        _data = newData;
      }
      
      _status = HomeStatus.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to refresh text content.';
    }

    notifyListeners();
  }
}

