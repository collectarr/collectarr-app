import 'package:flutter/material.dart';

class CollectionShelf extends StatelessWidget {
  const CollectionShelf({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 0.68,
      children: children,
    );
  }
}

