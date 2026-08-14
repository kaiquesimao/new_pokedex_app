import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/shared/widgets/pokemon_list_row_skeleton.dart';

class const PokemonListSkeleton({super.key, final int itemCount = 6})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const PokemonListRowSkeleton(),
    );
  }
}
