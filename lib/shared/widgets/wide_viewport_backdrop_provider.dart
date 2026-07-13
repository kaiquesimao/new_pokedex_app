import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/wide_viewport_backdrop_assets.dart';

int randomWideViewportBackdropIndex({int? exclude}) {
  final length = WideViewportBackdropAssets.paths.length;
  if (length <= 1) return 0;

  final random = Random();
  var next = random.nextInt(length);
  if (exclude != null && next == exclude) {
    next = (next + 1) % length;
  }
  return next;
}

/// Current backdrop index for wide web viewports.
final wideViewportBackdropIndexProvider =
    NotifierProvider<WideViewportBackdropIndex, int>(
      WideViewportBackdropIndex.new,
    );

class WideViewportBackdropIndex extends Notifier<int> {
  @override
  int build() {
    return randomWideViewportBackdropIndex();
  }

  void advance() {
    final length = WideViewportBackdropAssets.paths.length;
    if (length <= 1) return;
    state = (state + 1) % length;
  }

  void rotateRandom() {
    state = randomWideViewportBackdropIndex(exclude: state);
  }
}
