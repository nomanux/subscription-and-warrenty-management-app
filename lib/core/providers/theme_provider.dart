import 'package:flutter_riverpod/flutter_riverpod.dart';

class _ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final themeModeProvider = NotifierProvider<_ThemeModeNotifier, bool>(_ThemeModeNotifier.new);