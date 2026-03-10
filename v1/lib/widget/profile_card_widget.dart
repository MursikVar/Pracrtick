import 'package:flutter/material.dart';

Card profileCardWidget(String value, String type, VoidCallback onEdit) {
  return Card(
    child: ListTile(
      title: Text(type),
      subtitle: Text(value),
      trailing: IconButton(
        onPressed: onEdit,
        icon: Icon(Icons.border_color_outlined),
      ),
    ),
  );
}
