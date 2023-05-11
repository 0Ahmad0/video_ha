import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum Videos_Type { importatnt, regular_rec }

class data {
  final String id;
  final List<String> categories;
  final String title;
  final AssetImage imageUrl;
  final List<String> important_records;
  final Videos_Type important;

  const data(
      {required this.id,
      required this.categories,
      required this.title,
      required this.imageUrl,
      required this.important_records,
      required this.important});
}
