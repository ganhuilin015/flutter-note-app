import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/search_provider.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onClose;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.read<SearchProvider>();

    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
      ),
      style: const TextStyle(fontSize: 18),
      onChanged: searchProvider.setQuery,
    );
  }
}