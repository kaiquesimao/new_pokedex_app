import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';
import 'package:pokedex_app/shared/widgets/app_bottom_nav_bar.dart';
import 'package:pokedex_app/shared/widgets/region_generation_card.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';

class RegionsPage extends ConsumerWidget {
  const RegionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafePageBody(
        bottom: false,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            AppBottomNavBar.overlayHeight(context),
          ),
          itemCount: RegionCardAssets.curated.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final card = RegionCardAssets.curated[index];
            return RegionGenerationCard(
              data: card,
              onTap: () {
                ref
                    .read(appAnalyticsProvider)
                    .regionOpened(regionName: card.displayName);
                unawaited(context.push('/regions/${card.apiName}'));
              },
            );
          },
        ),
      ),
    );
  }
}
