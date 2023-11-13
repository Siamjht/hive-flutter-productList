

import 'package:hive/hive.dart';
import 'package:hive_flutter_products/models/product.dart';

class Boxes{
  static Box<Product> getProducts() =>
      Hive.box<Product>('products');
}