import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop_provider.dart';

class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int? _lastTabIndex;

  @override
  Widget build(BuildContext context) {
    final tabIndex = widget.navigationShell.currentIndex;
    if (_lastTabIndex != null && _lastTabIndex != tabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(wideViewportBackdropIndexProvider.notifier).advance();
      });
    }
    _lastTabIndex = tabIndex;

    return ShellTabScope(
      currentIndex: tabIndex,
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: ResponsiveContentFrame(
          expandHeight: true,
          child: widget.navigationShell,
        ),
        bottomNavigationBar: ResponsiveContentFrame(
          child: AppBottomNavBar(
            currentIndex: tabIndex,
            onTap: (index) => widget.navigationShell.goBranch(
              index,
              initialLocation: index == tabIndex,
            ),
          ),
        ),
      ),
    );
  }
}
