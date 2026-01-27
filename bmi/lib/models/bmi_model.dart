import 'package:bmi/data/enums/gender.dart';

class BmiModel {
  final String id;
  final String name;
  final double weight;
  final double height;
  final Genders gender;
  final int age;
  final double bmi;
  final String status;

  const BmiModel({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.gender,
    required this.age,
    required this.bmi,
    required this.status,
  });
}
