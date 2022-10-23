import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import "../shared/dialog_utils.dart";
import '../products/products_manager.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  EditProductScreen(
    Product? product, {
    super.key,
  }) {
    if (product == null) {
      this.product = Product(
        id: null,
        title: '',
        price: 0,
        description: '',
        imageUrl: '',
      );
    } else {
      this.product = product;
    }
  }
  late final Product product;
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;
  var _isLoading = false;

  get children => null;

  bool _isValidImageUrl(String value) {
    return (value.startsWith("http") || value.startsWith("https")) &&
        (value.endsWith('.png') ||
            value.endsWith('.jpg') ||
            value.endsWith('.jpeg'));
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(() {
      if (!_imageUrlFocusNode.hasFocus) {
        if (!_isValidImageUrl(_imageUrlController.text)) {
          return;
        }
        setState(() {});
      }
    });
    _editedProduct = widget.product;
    _imageUrlController.text = _editedProduct.imageUrl;
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _editForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      final productsManager = context.read<ProductsManager>();
      if (_editedProduct.id != null) {
        productsManager.updateProduct(_editedProduct);
      } else {
        productsManager.addProduct(_editedProduct);
      }
    } catch (err) {
      await showErrorDialog(context, 'Co gi do bi sai');
    }
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _editForm,
                child: ListView(
                  children: <Widget>[
                    buildTitleField(),
                    buildPriceField(),
                    buildDescriptionField(),
                    buildProductPreview(),
                  ],
                ),
              ),
            ),
    );
  }

  TextFormField buildTitleField() {
    return TextFormField(
      initialValue: _editedProduct.title,
      decoration: const InputDecoration(labelText: 'Title'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Cung cấp tên';
        }
        return null;
      },
      onSaved: ((newValue) {
        _editedProduct = _editedProduct.copyWith(title: newValue);
      }),
    );
  }

  TextFormField buildPriceField() {
    return TextFormField(
      initialValue: _editedProduct.price.toString(),
      decoration: const InputDecoration(labelText: 'Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Cung cấp gía mới';
        }
        if (double.tryParse(value) == null) {
          return 'Nhập giá chính xác';
        }
        if (double.parse(value) <= 0) {
          return 'Miễn phí hả';
        }
        return null;
      },
      onSaved: (newValue) {
        _editedProduct =
            _editedProduct.copyWith(price: double.parse(newValue!));
      },
    );
  }

  TextFormField buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: const InputDecoration(labelText: 'Mô tả'),
      maxLines: 3,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Mô tả lại';
        }
        if (value.length < 10) {
          return "Mô tả thêm đi";
        }
        return null;
      },
      onSaved: (newValue) {
        _editedProduct = _editedProduct.copyWith(description: newValue);
      },
    );
  }

  TextFormField buildImageURLField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Hình'),
      controller: _imageUrlController,
      focusNode: _imageUrlFocusNode,
      onFieldSubmitted: ((value) => _saveForm()),
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Chọn ảnh trước';
        }
        if (!_isValidImageUrl(value)) {
          return "Hình ảnh không chính xác";
        }
        return null;
      },
      onSaved: (newValue) {
        _editedProduct = _editedProduct.copyWith(imageUrl: newValue);
      },
    );
  }

  Widget buildProductPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.green,
            ),
          ),
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(
            top: 8,
            right: 10,
          ),
          child: _imageUrlController.text.isEmpty
              ? const Text('Chọn ảnh')
              : FittedBox(
                  child: Image.network(
                    _imageUrlController.text,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        Expanded(child: buildImageURLField())
      ],
    );
  }
}
