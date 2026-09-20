import 'package:wardrobe/models/garment.dart';

class GarmentStore {
  final List<Garment> _items = [];

  List<Garment> get items => List.unmodifiable(_items);
  // Future<File> _file() async{
  //   // final dir
  // }
}
