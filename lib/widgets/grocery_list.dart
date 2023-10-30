// ignore_for_file: unused_element

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocelist/data/categories.dart';
// import 'package:grocelist/data/dummy_items.dart';
import 'package:grocelist/models/grocery_item.dart';
import 'package:grocelist/widgets/add_new_item.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({
    super.key,
  });

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> newGroceryItems = [];

  @override
  void initState() {
    super.initState();
    fetchGroceryItems();
  }

  void fetchGroceryItems() async {
    final url = Uri.https(
        "grocelist-31cb2-default-rtdb.firebaseio.com", "shopping-list.json");

    final response = await http.get(url);
    final Map<String, dynamic> groceryListData = json.decode(response.body);
    // This is created temporarily here so that it can replace newGroceryItems later.
    final List<GroceryItem> groceryListItem = [];
    for (final item in groceryListData.entries) {
      // This is done to search for the category that matches the grocery item
      // firstWhere method works almost like where method, only that it returns the first element that pass the test
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;

      groceryListItem.add(GroceryItem(
        id: item.key,
        name: item.value["name"],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    setState(() {
      newGroceryItems = groceryListItem;
    });
    print(groceryListItem);
  }

  void addItem() async {
    // final newItem = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (ctx) => const NewItem(),
    //   ),
    // );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    fetchGroceryItems();

    // if (newItem == null) {
    //   return;
    // }
    // setState(() {
    //   newGroceryItems.add(newItem);
    // });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No items aded yet"),
    );

    if (newGroceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: newGroceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(newGroceryItems[index].id),
                onDismissed: (direction) {
                  setState(() {
                    newGroceryItems.remove(newGroceryItems[index]);
                  });
                },
                child: ListTile(
                  title: Text(newGroceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: newGroceryItems[index].category.color,
                  ),
                  trailing: Text(newGroceryItems[index].quantity.toString()),
                ),
              ));
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Grocery list"),
          actions: [
            IconButton(onPressed: addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
