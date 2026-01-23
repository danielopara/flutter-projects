import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_data.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

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

  void _removeItem(GroceryItem item) {
    final groceryItemIndex = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item delete'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _groceryItems.insert(groceryItemIndex, item);
            });
          },
        ),
      ),
    );
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
