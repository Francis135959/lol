import 'package:flutter/material.dart';

class ClientSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ClientSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Buscar cliente...',
          hintStyle: TextStyle(color: theme.onSurfaceVariant.withOpacity(0.7), fontSize: 15),
          prefixIcon: Icon(Icons.search, color: theme.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.outline.withOpacity(0.5), 
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.outline.withOpacity(0.5), 
              width: 1,
            ),
          ),
          
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.primary, 
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: isDark ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}