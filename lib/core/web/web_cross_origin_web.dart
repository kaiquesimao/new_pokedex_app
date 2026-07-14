import 'package:web/web.dart' as web;

/// True when COOP/COEP make SharedArrayBuffer available (Wasm multi-thread).
bool get isWebCrossOriginIsolated => web.window.crossOriginIsolated;
