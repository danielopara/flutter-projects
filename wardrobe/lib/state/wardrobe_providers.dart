import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wardrobe/data/garment_store.dart';
import 'package:wardrobe/models/garment.dart';

/// Overridden in main() (and in tests) with a store rooted at a real directory.
final garmentStoreProvider = Provider<GarmentStore>(
  (ref) => throw UnimplementedError('garmentStoreProvider must be overridden'),
);

final wardrobeProvider = AsyncNotifierProvider<WardrobeNotifier, WardrobeData>(
  WardrobeNotifier.new,
);

class WardrobeNotifier extends AsyncNotifier<WardrobeData> {
  GarmentStore get _store => ref.read(garmentStoreProvider);

  @override
  Future<WardrobeData> build() async {
    final data = await _store.load();
    await _store.pruneImages(
      keep: {for (final g in data.garments) ?g.imagePath},
    );
    return data;
  }

  Future<void> _commit(WardrobeData next) async {
    state = AsyncData(next);
    await _store.save(next);
  }

  Future<void> upsert(Garment garment) async {
    final data = state.requireValue;
    final list = [...data.garments];
    final index = list.indexWhere((g) => g.id == garment.id);
    if (index == -1) {
      list.add(garment);
    } else {
      final old = list[index];
      if (old.imagePath != garment.imagePath) {
        await _store.deleteImage(old.imagePath);
      }
      list[index] = garment;
    }
    await _commit(data.copyWith(garments: list));
  }

  /// Removes a garment but keeps its photo on disk so [restore] can bring it
  /// back intact. Call [discardImage] once undo is no longer possible.
  Future<(Garment, int)?> delete(String id) async {
    final data = state.requireValue;
    final index = data.garments.indexWhere((g) => g.id == id);
    if (index == -1) return null;
    final garment = data.garments[index];
    await _commit(data.copyWith(garments: [...data.garments]..removeAt(index)));
    return (garment, index);
  }

  Future<void> restore(Garment garment, int index) async {
    final data = state.requireValue;
    final list = [...data.garments]
      ..insert(index.clamp(0, data.garments.length), garment);
    await _commit(data.copyWith(garments: list));
  }

  Future<void> discardImage(String? name) async {
    final stillUsed = state.requireValue.garments.any(
      (g) => g.imagePath == name,
    );
    if (!stillUsed) await _store.deleteImage(name);
  }

  Future<void> changeQuantity(String id, int delta) async {
    final data = state.requireValue;
    await _commit(
      data.copyWith(
        garments: [
          for (final g in data.garments)
            if (g.id == id)
              g.copyWith(quantity: (g.quantity + delta).clamp(0, 999))
            else
              g,
        ],
      ),
    );
  }

  Future<void> setAppLock(bool enabled) =>
      _commit(state.requireValue.copyWith(appLock: enabled));
}

/// Thin seam over local_auth so the lock can be faked in tests.
class Authenticator {
  const Authenticator();

  Future<bool> isAvailable() async {
    try {
      return await LocalAuthentication().isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await LocalAuthentication().authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }
}

final authenticatorProvider = Provider<Authenticator>(
  (ref) => const Authenticator(),
);
