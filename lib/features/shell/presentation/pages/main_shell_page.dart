import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/features/home_tutorial/domain/home_tutorial_step.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/providers/home_tutorial_provider.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/widgets/home_tutorial_host.dart';
import 'package:pokedex_app/features/home_tutorial/presentation/widgets/home_tutorial_target.dart';
import 'package:pokedex_app/features/shell/presentation/widgets/shell_tab_scope.dart';
import 'package:pokedex_app/features/whats_new/presentation/widgets/whats_new_host.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';
import 'package:pokedex_app/shared/widgets/wide_viewport_backdrop_provider.dart';

class const MainShellPage({
  required final StatefulNavigationShell navigationShell,
  super.key,
}) extends ConsumerStatefulWidget {
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

    // Keep Pokédex targets mounted while the coach marks run.
    final tutorialActive = ref.watch(
      homeTutorialProvider.select((s) => s.isActive),
    );
    if (tutorialActive && tabIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.navigationShell.goBranch(0);
      });
    }

    return WhatsNewHost(
      child: HomeTutorialHost(
        child: ShellTabScope(
          currentIndex: tabIndex,
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: ResponsiveContentFrame(
              expandHeight: true,
              child: widget.navigationShell,
            ),
            bottomNavigationBar: ResponsiveContentFrame(
              child: HomeTutorialTarget(
                step: HomeTutorialStepId.bottomNav,
                child: AppBottomNavBar(
                  currentIndex: tabIndex,
                  onTap: (index) => widget.navigationShell.goBranch(
                    index,
                    initialLocation: index == tabIndex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
