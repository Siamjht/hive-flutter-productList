

import 'package:flutter/material.dart';
import 'package:hive_flutter_products/models/product.dart';

class ProductManager extends StatefulWidget {
  final Product? product;
  final Function(String productName, double productPrice, bool isSold) onClickedDone;
  const ProductManager({super.key, this.product, required this.onClickedDone});

  @override
  State<ProductManager> createState() => _ProductManagerState();
}

class _ProductManagerState extends State<ProductManager> {
  final formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  bool isSold = true;

  @override
  void initState() {
    super.initState();
    if(widget.product != null){
      final product = widget.product;
      nameController.text = product!.productName;
      amountController.text = product.productPrice.toString();
      isSold = product.isSold;
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final title = isEditing? 'Edit Product List' : 'Add Product';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8,),
              buildName(),
              const SizedBox(height: 8,),
              buildAmount(),
              const SizedBox(height: 8,),
              buildRadioButtons(),
            ],
          ),
        ),
      ),
      actions: [
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }
  Widget buildName() => TextFormField(
    controller: nameController,
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Product Name',
    ),
    validator: (productName) => productName != null && productName.isEmpty ? 'Enter a product name': null,
  );

  Widget buildAmount() => TextFormField(
    decoration: const InputDecoration(
      border: OutlineInputBorder(),
      hintText: "Enter Product Price"
    ),
    keyboardType: TextInputType.number,
    validator: (productPrice) => productPrice != null && double.tryParse(productPrice) == null
      ? 'Enter a valid price' : null,
  controller: amountController,
  );

  Widget buildRadioButtons() => Column(
    children: [
      RadioListTile<bool>(
        title: const Text('Encash'),
          value: true,
          groupValue: isSold,
          onChanged: (value) => setState(() {
            isSold = value!;
          }),
      ),
      RadioListTile<bool>(
        title: const Text('Purchase'),
        value: false,
        groupValue: isSold,
        onChanged: (value) => setState(() {
          isSold = value!;
        }),
      )
    ],
  );

  Widget buildCancelButton(BuildContext context) => TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'));
  Widget buildAddButton(BuildContext context, {required bool isEditing}){
    final text = isEditing ? 'Save' : 'Add';
    return TextButton(
        onPressed: ( ) async{
          final isValid = formkey.currentState!.validate();
          if(isValid){
            final productName = nameController.text;
            final productPrice = double.tryParse(amountController.text) ?? 0;
            widget.onClickedDone(productName, productPrice, isSold);

            Navigator.of(context).pop();
          }
        },
        child: Text(text),);
  }
}
