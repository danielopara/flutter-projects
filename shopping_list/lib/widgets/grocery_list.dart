import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/data/dummy_data.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  var _isLoading = true;

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You added ${newItem.name} to the list!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeItem(GroceryItem item) async {
    final groceryItemIndex = _groceryItems.indexOf(item);
    final messenger = ScaffoldMessenger.of(context);

    final url = Uri.https(
      'fluttter-prep-a2292-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    setState(() {
      _groceryItems.remove(item);
    });

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: const Text('Item deleted'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final undoUrl = Uri.https(
              'fluttter-prep-a2292-default-rtdb.firebaseio.com',
              'shopping-list/${item.id}.json',
            );

            await http.put(
              undoUrl,
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': item.name,
                'quantity': item.quantity,
                'category': item.category.title,
              }),
            );

            if (!mounted) return;

            setState(() {
              _groceryItems.insert(groceryItemIndex, item);
            });
          },
        ),
      ),
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(groceryItemIndex, item);
      });
      messenger.hideCurrentSnackBar();
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'fluttter-prep-a2292-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadItems = [];

      for (final entry in listData.entries) {
        final itemData = entry.value;
        final category = categories.entries
            .firstWhere((entry) => entry.value.title == itemData['category'])
            .value;
        loadItems.add(
          GroceryItem(
            id: entry.key,
            name: itemData['name'],
            quantity: itemData['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems.clear();
        _groceryItems.addAll(loadItems);
        _isLoading = false;
      });
    } catch (error) {
      // return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _groceryItems.isEmpty
        ? const Center(
            child: Text('No Item in the list', style: TextStyle(fontSize: 20)),
          )
        : ListView.builder(
            itemCount: _groceryItems.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceryItems[index]);
              },
              key: ValueKey(_groceryItems[index].id),
              child: ListTile(
                title: Text(_groceryItems[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text('${_groceryItems[index].quantity}'),
              ),
            ),
          );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),
      body: content,
    );
  }
}
