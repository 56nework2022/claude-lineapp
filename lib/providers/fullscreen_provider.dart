import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullscreenProgressNotifier extends StateNotifier<int> {
  FullscreenProgressNotifier() : super(0);

  void reset() => state = 0;

  void advance(int maxIndex) {
    if (state < maxIndex) state++;
  }
}

final fullscreenProgressProvider =
    StateNotifierProvider<FullscreenProgressNotifier, int>(
  (ref) => FullscreenProgressNotifier(),
);
