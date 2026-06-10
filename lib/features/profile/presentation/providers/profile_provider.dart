import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex_app/core/constants/trainer_avatars.dart';
import 'package:shared_preferences/shared_preferences.dart';

const avatarStorageKey = 'trainer_avatar_slug';

String readStoredAvatarSlug(SharedPreferences prefs) {
  return prefs.getString(avatarStorageKey) ?? TrainerAvatars.defaultSlug;
}

class ProfileNotifier extends StateNotifier<String> {
  ProfileNotifier(super.initial);

  Future<void> setAvatar(String slug) async {
    state = slug;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(avatarStorageKey, slug);
  }
}

final profileAvatarProvider = StateNotifierProvider<ProfileNotifier, String>((
  ref,
) {
  return ProfileNotifier(TrainerAvatars.defaultSlug);
});
