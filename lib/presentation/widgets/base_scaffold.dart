// lib/widgets/base_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton; // false for homepage, true otherwise

  const BaseScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 1,
        title: Text(title),
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'), // Navigate back to homepage
        )
            : null,
      ),
      body: body,
    );
  }
}
