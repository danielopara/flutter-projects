import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrobe/models/garment.dart';
import 'package:wardrobe/screens/garment_form_screen.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';
import 'package:wardrobe/widgets/garment_photo.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Category? _filter;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Garment> _visible(List<Garment> all) {
    final q = _query.trim().toLowerCase();
    final list = all.where((g) {
      if (_filter != null && g.category != _filter) return false;
      if (q.isEmpty) return true;
      return g.name.toLowerCase().contains(q) ||
          g.category.label.toLowerCase().contains(q) ||
          g.colors.any((c) => c.toLowerCase().contains(q));
    }).toList();
    list.sort((a, b) {
      final byCategory = a.category.index.compareTo(b.category.index);
      return byCategory != 0
          ? byCategory
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  Future<void> _openForm([Garment? garment]) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await Navigator.of(context).push<GarmentDeleted>(
      MaterialPageRoute(
        builder: (_) =>
            GarmentFormScreen(initial: garment, initialCategory: _filter),
      ),
    );
    if (result != null) _showUndo(messenger, result.garment, result.index);
  }

  Future<void> _deleteFromList(Garment garment) async {
    final messenger = ScaffoldMessenger.of(context);
    final removed = await ref
        .read(wardrobeProvider.notifier)
        .delete(garment.id);
    if (removed != null) _showUndo(messenger, removed.$1, removed.$2);
  }

  void _showUndo(ScaffoldMessengerState messenger, Garment g, int index) {
    final notifier = ref.read(wardrobeProvider.notifier);
    messenger.clearSnackBars();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text('Deleted "${g.name}"'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => notifier.restore(g, index),
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            notifier.discardImage(g.imagePath);
          }
        });
  }

  Future<void> _toggleLock(bool enable) async {
    final messenger = ScaffoldMessenger.of(context);
    final auth = ref.read(authenticatorProvider);
    final notifier = ref.read(wardrobeProvider.notifier);
    if (enable && !await auth.isAvailable()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Set up a passcode, fingerprint or face unlock on this device '
            'to use app lock.',
          ),
        ),
      );
      return;
    }
    final ok = await auth.authenticate(
      enable ? 'Confirm to turn on app lock' : 'Confirm to turn off app lock',
    );
    if (!ok) return;
    await notifier.setAppLock(enable);
    messenger.showSnackBar(
      SnackBar(content: Text(enable ? 'App lock on' : 'App lock off')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(wardrobeProvider).requireValue;
    final garments = data.garments;
    final visible = _visible(garments);
    final pieces = garments.fold<int>(0, (sum, g) => sum + g.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wardrobe'),
        actions: [
          // Browsers have no Face ID or fingerprint unlock, so no app lock.
          if (!kIsWeb)
            PopupMenuButton<void>(
              tooltip: 'Settings',
              itemBuilder: (_) => [
                CheckedPopupMenuItem(
                  checked: data.appLock,
                  onTap: () => _toggleLock(!data.appLock),
                  child: const Text('App lock'),
                ),
              ],
            ),
        ],
      ),
      body: garments.isEmpty
          ? const _EmptyWardrobe()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    garments: garments,
                    pieces: pieces,
                    filter: _filter,
                    search: _search,
                    onFilter: (c) => setState(() => _filter = c),
                    onQuery: (q) => setState(() => _query = q),
                  ),
                ),
                if (visible.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Nothing matches.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 96),
                    sliver: SliverList.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final g = visible[i];
                        return Dismissible(
                          key: ValueKey(g.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: Icon(
                              Icons.delete_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                          onDismissed: (_) => _deleteFromList(g),
                          child: _GarmentTile(
                            garment: g,
                            onTap: () => _openForm(g),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add garment'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.garments,
    required this.pieces,
    required this.filter,
    required this.search,
    required this.onFilter,
    required this.onQuery,
  });

  final List<Garment> garments;
  final int pieces;
  final Category? filter;
  final TextEditingController search;
  final ValueChanged<Category?> onFilter;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counts = <Category, int>{};
    for (final g in garments) {
      counts[g.category] = (counts[g.category] ?? 0) + 1;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '${_plural(garments.length, 'item')} · ${_plural(pieces, 'piece')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: search,
            onChanged: onQuery,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name or color',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ListenableBuilder(
                listenable: search,
                builder: (_, _) => search.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          search.clear();
                          onQuery('');
                        },
                      ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              isDense: true,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text('All (${garments.length})'),
                selected: filter == null,
                onSelected: (_) => onFilter(null),
              ),
              for (final c in Category.values)
                if (counts.containsKey(c))
                  ChoiceChip(
                    label: Text('${c.label} (${counts[c]})'),
                    selected: filter == c,
                    onSelected: (on) => onFilter(on ? c : null),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GarmentTile extends ConsumerWidget {
  const _GarmentTile({required this.garment, required this.onTap});

  final Garment garment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(wardrobeProvider.notifier);
    final outOfStock = garment.quantity == 0;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: GarmentPhoto(
        imagePath: garment.imagePath,
        category: garment.category,
      ),
      title: Text(
        garment.name,
        style: outOfStock
            ? TextStyle(color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            outOfStock
                ? '${garment.category.label} · none left'
                : garment.category.label,
          ),
          if (garment.colors.isNotEmpty) ...[
            const SizedBox(height: 4),
            ColorDots(colors: garment.colors),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'One fewer ${garment.name}',
            onPressed: garment.quantity > 0
                ? () => notifier.changeQuantity(garment.id, -1)
                : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Semantics(
            label: 'Quantity ${garment.quantity}',
            excludeSemantics: true,
            child: SizedBox(
              width: 28,
              child: Text(
                '${garment.quantity}',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: 'One more ${garment.name}',
            onPressed: garment.quantity < 999
                ? () => notifier.changeQuantity(garment.id, 1)
                : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}

class _EmptyWardrobe extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Your wardrobe is empty', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Add your clothes, shoes and accessories to keep track of '
              'what you own.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
