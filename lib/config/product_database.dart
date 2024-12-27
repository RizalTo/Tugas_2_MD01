import 'package:inventory_system/model/barang.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDatabase {
  final database = Supabase.instance.client.from('product');

  // Create
  Future<void> createProduct(Product newProduct) async {
    try {
      await database.insert(newProduct.toMap());
    } catch (e) {
      print('Error creating product: $e');
      throw e;
    }
  }

  // Read
  final stream = Supabase.instance.client.from('product').stream(
    primaryKey: ['id'],
  ).map(
      (data) => data.map((productMap) => Product.fromMap(productMap)).toList());

  // Update
  Future<void> updateProduct(Product product) async {
    try {
      await database.update({
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'kategories': product.kategories, 
        'description': product.description,
        'image': product.image,
        'idSupplier': product.idSupplier,
      }).eq('id', product.id);
    } catch (e) {
      print('Error updating product: $e');
      throw e;
    }
  }

  // Delete
  Future<void> deleteProduct(Product product) async {
    try {
      await database.delete().eq('id', product.id);
    } catch (e) {
      print('Error deleting product: $e');
      throw e;
    }
  }
}