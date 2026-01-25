import 'package:bmi/data/enums/gender.dart';

class BmiModel {
  final double weight;
  final double height;
  final Genders gender;
  final int age;
  final double bmi;

  const BmiModel({
    required this.weight,
    required this.height,
    required this.gender,
    required this.age,
    required this.bmi,
  });
}
