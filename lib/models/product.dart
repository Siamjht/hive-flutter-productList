
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject{

  @HiveType(typeId: 0)
  late String productName;

  @HiveType(typeId: 1)
  late DateTime createdDate;

  @HiveType(typeId: 2)
  late bool isSold;

  @HiveType(typeId:3)
  late double productPrice;
}