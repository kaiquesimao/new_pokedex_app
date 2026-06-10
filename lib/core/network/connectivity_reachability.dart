export 'connectivity_reachability_stub.dart'
    if (dart.library.io) 'connectivity_reachability_io.dart'
    if (dart.library.html) 'connectivity_reachability_web.dart';
