import 'package:flutter/material.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/model/transaksi.dart';
import 'package:inventory_system/pages/barang/riwayat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../model/barang.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<Transaksi>> _transaksi;
  late Product _product;
  String? _supplierName;

  @override
  void initState() {
    _product = widget.product;
    _transaksi = _getHistoriesFromSupabase();
    _fetchSupplierName();
    super.initState();
  }

  Future<void> _fetchSupplierName() async {
    try {
      final response = await Supabase.instance.client
          .from('supplier')
          .select('nama')
          .eq('id', _product.idSupplier as int)
          .single();
      setState(() {
        _supplierName = response['nama'] as String?;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch supplier name: $e')),
      );
    }
  }

  Future<List<Transaksi>> _getHistoriesFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('transaksi')
          .select()
          .eq('idProduct', _product.id);
      return (response as List)
          .map((json) => Transaksi.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch histories: $e');
    }
  }

  Future<void> _refreshProduct() async {
    try {
      final results = await Future.wait([
        _getHistoriesFromSupabase(),
        _fetchSupplierName(),
      ]);
      setState(() {
        _transaksi = Future.value(results[0] as List<Transaksi>);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh product: $e')),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final relativePath = _product.image.split('/').last;
        if (relativePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('image')
              .remove([relativePath]);
        }
        await Future.wait([
          Supabase.instance.client
              .from('product')
              .delete()
              .eq('id', _product.id),
          Supabase.instance.client
              .from('transaksi')
              .delete()
              .eq('idProduct', _product.id),
        ]);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product and history deleted successfully')));
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (Route<dynamic> route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _product.image != null && _product.image.isNotEmpty
                    ? Image.network(
                        _product.image,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image,
                              size: 200, color: Colors.grey);
                        },
                      )
                    : Icon(Icons.image, size: 200, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                _product.name,
                style: headerStyle(level: 2),
              ),
              SizedBox(height: 8),
              Text(
                'Supplier: ${_supplierName ?? 'Loading...'}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Category: ${_product.kategories}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Price: Rp${_product.price}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Stock: ${_product.stock}',
                style: textStyle(level: 3),
              ),
              SizedBox(height: 8),
              Text(
                'Description:',
                style: textStyle(level: 2),
              ),
              SizedBox(height: 4),
              Text(
                _product.description,
                style: textStyle(level: 4),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _deleteProduct(context),
                    style: buttonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(dangerColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Delete', style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RiwayatPage(product: _product),
                        ),
                      );
                      if (result == true) {
                        await _refreshProduct();
                      }
                    },
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.update, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Update Stock', style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<Transaksi>>(
                future: _transaksi,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No transaction history.'));
                  }

                  final histories = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Card(
                        key: Key(history.id.toString()),
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${DateFormat('dd-MM-yyyy').format(history.tanggal)}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Transaction Type: ${history.jenisTransaksi}',
                                style: headerStyle(level: 4),
                              ),
                              Text(
                                'Quantity: ${history.jumlah}',
                                style: headerStyle(level: 4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
