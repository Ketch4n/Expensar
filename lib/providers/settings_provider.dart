import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Holds app-level settings like currency and user name.
class SettingsState {
  final String currency;
  final String userName;

  const SettingsState({this.currency = '₱', this.userName = 'User'});

  SettingsState copyWith({String? currency, String? userName}) => SettingsState(
    currency: currency ?? this.currency,
    userName: userName ?? this.userName,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final currency = await DatabaseService.getSetting('currency');
    final userName = await DatabaseService.getSetting('userName');
    state = SettingsState(
      currency: currency ?? '₱',
      userName: userName ?? 'User',
    );
  }

  Future<void> setCurrency(String symbol) async {
    await DatabaseService.setSetting('currency', symbol);
    state = state.copyWith(currency: symbol);
  }

  Future<void> setUserName(String name) async {
    await DatabaseService.setSetting('userName', name);
    state = state.copyWith(userName: name);
  }

  /// Force reload from database (e.g. after import).
  Future<void> reload() async => _load();
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
