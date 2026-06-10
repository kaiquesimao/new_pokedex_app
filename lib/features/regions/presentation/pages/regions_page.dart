import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pokedex_app/core/analytics/app_analytics.dart';
import 'package:pokedex_app/core/constants/region_card_assets.dart';
import 'package:pokedex_app/features/regions/presentation/providers/regions_provider.dart';
import 'package:pokedex_app/shared/widgets/region_generation_card.dart';

class RegionsPage extends ConsumerStatefulWidget {
  const RegionsPage({super.key});

  @override
  ConsumerState<RegionsPage> createState() => _RegionsPageState();
}

class _RegionsPageState extends ConsumerState<RegionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(regionsProvider.notifier).loadIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(regionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Regiões')),
      body: regionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text('Erro: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(regionsProvider.notifier).reload(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
        data: (_) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: RegionCardAssets.curated.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = RegionCardAssets.curated[index];
              return RegionGenerationCard(
                data: card,
                onTap: () {
                  ref.read(appAnalyticsProvider).regionOpened(
                        regionName: card.displayName,
                      );
                  context.push('/regions/${card.apiName}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
