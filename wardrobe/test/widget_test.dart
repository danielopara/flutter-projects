import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe/app.dart';
import 'package:wardrobe/data/garment_store.dart';
import 'package:wardrobe/models/garment.dart';
import 'package:wardrobe/screens/garment_form_screen.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';

class FakeAuthenticator extends Authenticator {
  FakeAuthenticator({this.succeed = true});
  bool succeed;
  int calls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate(String reason) async {
    calls++;
    return succeed;
  }
}

void main() {
  late Directory dir;
  late GarmentStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('wardrobe_test');
    store = GarmentStore(dir);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  const shirt = Garment(
    id: '1',
    name: 'Linen shirt',
    category: Category.tops,
    colors: ['White', 'Blue'],
    quantity: 2,
    imagePath: 'a.jpg',
  );

  group('Garment', () {
    test('round-trips through JSON', () {
      final back = Garment.fromJson(shirt.toJson());
      expect(back.toJson(), shirt.toJson());
    });

    test('copyWith can clear the image', () {
      expect(shirt.copyWith(name: 'x').imagePath, 'a.jpg');
      expect(shirt.copyWith(clearImage: true).imagePath, isNull);
    });
  });

  group('GarmentStore', () {
    test('loads empty when nothing saved', () async {
      final data = await store.load();
      expect(data.garments, isEmpty);
      expect(data.appLock, isFalse);
    });

    test('saves and loads', () async {
      await store.save(const WardrobeData(garments: [shirt], appLock: true));
      final data = await GarmentStore(dir).load();
      expect(data.garments.single.name, 'Linen shirt');
      expect(data.appLock, isTrue);
    });

    test('imports and prunes images', () async {
      final src = File('${dir.path}/src.JPG')..writeAsStringSync('img');
      final name = await store.importImage(src.path);
      expect(name, endsWith('.jpg'));
      expect(store.imageFile(name).existsSync(), isTrue);

      await store.pruneImages(keep: {name});
      expect(store.imageFile(name).existsSync(), isTrue);
      await store.pruneImages(keep: {});
      expect(store.imageFile(name).existsSync(), isFalse);
    });
  });

  group('WardrobeNotifier', () {
    late ProviderContainer container;
    setUp(() {
      container = ProviderContainer(
        overrides: [garmentStoreProvider.overrideWithValue(store)],
      );
    });
    tearDown(() => container.dispose());

    test('add, change quantity, delete and undo persist', () async {
      final notifier = container.read(wardrobeProvider.notifier);
      await container.read(wardrobeProvider.future);

      await notifier.upsert(shirt.copyWith(clearImage: true));
      await notifier.changeQuantity('1', -5);
      expect((await store.load()).garments.single.quantity, 0);

      final removed = await notifier.delete('1');
      expect((await store.load()).garments, isEmpty);

      await notifier.restore(removed!.$1, removed.$2);
      expect((await store.load()).garments.single.id, '1');
    });
  });

  group('UI', () {
    Future<FakeAuthenticator> pumpApp(
      WidgetTester tester, {
      WardrobeData? initial,
      bool authSucceeds = true,
    }) async {
      final auth = FakeAuthenticator(succeed: authSucceeds);
      if (initial != null) {
        await tester.runAsync(() => store.save(initial));
      }
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            garmentStoreProvider.overrideWithValue(store),
            authenticatorProvider.overrideWithValue(auth),
          ],
          child: const WardrobeApp(),
        ),
      );
      // File IO is real, so let it complete outside the fake clock.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      return auth;
    }

    testWidgets('shows empty state, then adds a garment', (tester) async {
      await pumpApp(tester);
      expect(find.text('Your wardrobe is empty'), findsOneWidget);

      await tester.tap(find.text('Add garment'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Black jeans');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Trousers'));
      await tester.tap(find.widgetWithText(FilterChip, 'Black'));
      await tester.pump();

      await tester.tap(find.text('Add to wardrobe'));
      for (
        var i = 0;
        i < 20 && find.byType(GarmentFormScreen).evaluate().isNotEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('Black jeans'), findsOneWidget);
      expect(find.text('1 item · 1 piece'), findsOneWidget);
      final saved = await tester.runAsync(store.load);
      expect(saved!.garments.single.category, Category.trousers);
      expect(saved.garments.single.colors, ['Black']);
    });

    testWidgets('filters by category and search', (tester) async {
      await pumpApp(
        tester,
        initial: WardrobeData(
          garments: [
            shirt.copyWith(clearImage: true),
            const Garment(
              id: '2',
              name: 'Sneakers',
              category: Category.shoes,
              colors: ['Red'],
              quantity: 1,
            ),
          ],
        ),
      );
      expect(find.text('Linen shirt'), findsOneWidget);
      expect(find.text('Sneakers'), findsOneWidget);

      await tester.tap(find.text('Shoes (1)'));
      await tester.pump();
      expect(find.text('Linen shirt'), findsNothing);
      expect(find.text('Sneakers'), findsOneWidget);

      await tester.tap(find.text('All (2)'));
      await tester.enterText(find.byType(TextField), 'blue');
      await tester.pump();
      expect(find.text('Linen shirt'), findsOneWidget);
      expect(find.text('Sneakers'), findsNothing);
    });

    testWidgets('app lock blocks until authenticated', (tester) async {
      final auth = await pumpApp(
        tester,
        initial: const WardrobeData(appLock: true),
        authSucceeds: false,
      );
      expect(find.text('Wardrobe is locked'), findsOneWidget);
      expect(auth.calls, 1);

      auth.succeed = true;
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text('Your wardrobe is empty'), findsOneWidget);
    });
  });
}
