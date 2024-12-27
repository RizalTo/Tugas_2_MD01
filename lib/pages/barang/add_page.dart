import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_system/components/styles.dart';
import 'package:inventory_system/config/product_database.dart';
import 'package:inventory_system/model/barang.dart';
import 'package:inventory_system/model/supplier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPage extends StatefulWidget {
  final Product? product; // Optional product for update mode
  
  const AddPage({super.key, this.product});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  // Product database
  final productDatabase = ProductDatabase();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  String? _currentImageUrl;

  final ImagePicker _picker = ImagePicker();
  List<Supplier> _supplierList = [];
  int? _selectedSupplierId;

  bool get isUpdateMode => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isUpdateMode) {
      _initializeData();
    }
    _fetchSuppliers();
  }

  void _initializeData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _stockController.text = product.stock.toString();
    _kategoriController.text = product.kategories;
    _descriptionController.text = product.description;
    _currentImageUrl = product.image;
    _selectedSupplierId = product.idSupplier;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _kategoriController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    try {
      final response = await Supabase.instance.client
          .from('supplier')
          .select();
      setState(() {
        _supplierList = (response as List<dynamic>)
            .map((supplier) => Supplier.fromJson(supplier))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data supplier: $e')),
      );
    }
  }

  Future<void> _pickGalleryImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCameraImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    final nama = _nameController.text;
    final deskripsi = _descriptionController.text;
    final harga = int.tryParse(_priceController.text) ?? 0;
    final stok = int.tryParse(_stockController.text) ?? 0;
    final kategori = _kategoriController.text;

    if (nama.isEmpty ||
        deskripsi.isEmpty ||
        kategori.isEmpty ||
        (!isUpdateMode && _selectedImage == null) ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data harus diisi!')),
      );
      return;
    }

    try {
      String imageUrl = _currentImageUrl ?? '';

      // Handle image upload
      if (_selectedImage != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('image')
            .upload(fileName, _selectedImage!);

        imageUrl = Supabase.instance.client.storage
            .from('image')
            .getPublicUrl(fileName);

        // Delete old image if updating
        if (isUpdateMode && _currentImageUrl != null) {
          final oldFileName = _currentImageUrl!.split('/').last;
          await Supabase.instance.client.storage
              .from('image')
              .remove([oldFileName]);
        }
      }

      final productData = Product(
        id: isUpdateMode ? widget.product!.id : 0,
        name: nama,
        price: harga,
        stock: stok,
        kategories: kategori,
        description: deskripsi,
        image: imageUrl,
        idSupplier: _selectedSupplierId
      );

      if (isUpdateMode) {
        await productDatabase.updateProduct(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui!')),
        );
      } else {
        await productDatabase.createProduct(productData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!')),
        );
      }

      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ${isUpdateMode ? "memperbarui" : "menyimpan"} data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdateMode ? 'Update Barang' : 'Add Barang'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                isUpdateMode 
                  ? 'Update Data Barang'
                  : 'Silahkan Isi Data Barang Baru',
                style: headerStyle(level: 2)
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : _currentImageUrl != null
                        ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, size: 50, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pickCameraImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.camera, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Kamera',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickGalleryImage,
                    style: buttonStyle,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Galeri',
                            style: headerStyle(level: 4, dark: false)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: boxInputDecoration("Nama"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: boxInputDecoration("Deskripsi"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: boxInputDecoration("Harga"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: boxInputDecoration("Stok"),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _kategoriController,
                decoration: boxInputDecoration("Kategori"),
              ),
              SizedBox(height: 20),
              DropdownButton<int>(
                isExpanded: true,
                value: _selectedSupplierId,
                hint: Text('Pilih Supplier'),
                items: _supplierList.map((supplier) {
                  return DropdownMenuItem<int>(
                    value: supplier.id,
                    child: Text(supplier.nama),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSupplierId = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _saveData,
                    style: buttonStyle,
                    child: Text(
                      isUpdateMode ? 'Update' : 'Simpan',
                      style: headerStyle(level: 4, dark: false),
                    )),
              ),
              SizedBox(height: 50)
            ],
          ),
        ),
      ),
    );
  }
}