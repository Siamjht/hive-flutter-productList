import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import '../boxes.dart';
import '../models/product.dart';
import '../widgets/product_manager.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Product List'),
      centerTitle: true,
    ),
    body: ValueListenableBuilder<Box<Product>>(
      valueListenable: Boxes.getProducts().listenable(),
      builder: (context, box, _) {
        final products = box.values.toList().cast<Product>();

        return buildContent(products);
      },
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => showDialog(
        context: context,
        builder: (context) => ProductManager(
          onClickedDone: addProduct,
        ),
      ),
    ),
  );

  Widget buildContent(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No product listing yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netEncash = products.fold<double>(
        0,
            (previousValue, product) => product.isSold
            ? previousValue + product.productPrice
            : previousValue - product.productPrice,
      );
      final newEncashString = '\$${netEncash.toStringAsFixed(2)}';
      final color = netEncash > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Net Currency: $newEncashString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];

                return buildProduct(context, product);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildProduct(
      BuildContext context,
      Product product,
      ) {
    final color = product.isSold ? Colors.green : Colors.red;
    final date = DateFormat.yMMMd().format(product.createdDate);
    final productPrice = '\$${product.productPrice.toStringAsFixed(2)}';

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          product.productName,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          productPrice,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          buildButtons(context, product),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Product product) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: const Text('Edit'),
          icon: const Icon(Icons.edit),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductManager(
                product: product,
                onClickedDone: (productName, productPrice, isSold) =>
                    editProduct(product, productName, productPrice, isSold),
              ),
            ),
          ),
        ),
      ),
      Expanded(
        child: TextButton.icon(
          label: const Text('Delete'),
          icon: const Icon(Icons.delete),
          onPressed: () => deleteProduct(product),
        ),
      )
    ],
  );

  Future addProduct(String productName, double productPrice, bool isSold) async {
    final product= Product()
      ..productName = productName
      ..createdDate = DateTime.now()
      ..productPrice = productPrice
      ..isSold = isSold;

    final box = Boxes.getProducts();
    box.add(product);
  }

  void editProduct(
      Product product,
      String productName,
      double productPrice,
      bool isSold,
      ) {
    product.productName = productName;
    product.productPrice = productPrice;
    product.isSold = isSold;

    // final box = Boxes.getTransactions();
    // box.put(transaction.key, transaction);

    product.save();
  }

  void deleteProduct(Product product) {
    // final box = Boxes.getTransactions();
    // box.delete(transaction.key);

    product.delete();
    //setState(() => transactions.remove(transaction));
  }

  @override
  void dispose() {
    Hive.close();

    super.dispose();
  }
}
