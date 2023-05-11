import 'package:flutter/material.dart';

class CategoryConstants {
 static final List<Category> category_item = [
    Category(text: 'Reports', icon: Icons.report_problem_sharp,color: Colors.pink, isAvaliable: true),
    Category(text: 'Records', icon: Icons.video_camera_back_outlined,color: Colors.green, isAvaliable: true),
    Category(text: 'Important', icon: Icons.label_important,color: Colors.red, isAvaliable: true),
    Category(text: 'Live View', icon: Icons.live_tv,color: Colors.blue, isAvaliable: false),
    Category(text: 'Live Location',icon: Icons.location_on_outlined, color: Colors.purple, isAvaliable: false),
    Category(text: 'Setting',icon: Icons.settings, color: Colors.yellow, isAvaliable: true),
  ];
}

class Category {
  String text;
  Color color;
  IconData icon;
  bool isAvaliable;

  Category({
    required this.text,
    required this.color,
    required this.isAvaliable,
    required this.icon
  });
}
