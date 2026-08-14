import 'package:material_ui/material_ui.dart';

/// Loads a deferred Dart library before building the page.
///
/// On web this splits the payload; on VM the load completes immediately.
class const DeferredPage({
  required final Future<void> library,
  required final WidgetBuilder builder,
  super.key,
}) extends StatefulWidget {
  @override
  State<DeferredPage> createState() => _DeferredPageState();
}

class _DeferredPageState extends State<DeferredPage> {
  late final Future<void> _load = widget.library;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Icon(Icons.error_outline)),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.builder(context);
      },
    );
  }
}
