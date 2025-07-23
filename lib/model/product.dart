class ProductModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ProductModel({this.statusCode, this.success, this.messages, this.data});

  factory ProductModel.initial() {
    return ProductModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  ProductModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ProductModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  ProductModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages']?.cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? distributorId;
  String? productId;
  String? parentId;
  String? productName;
  String? productDescription;
  String? categoryId;
  String? categoryName;
  int? price;
  int? quantity;
  List<String>? productImages;
  String? adminApproval;
  bool? activated;

  Data({
    this.distributorId,
    this.productId,
    this.parentId,
    this.productName,
    this.productDescription,
    this.categoryId,
    this.categoryName,
    this.price,
    this.quantity,
    this.productImages,
    this.adminApproval,
    this.activated,
  });

  factory Data.initial() {
    return Data(
      distributorId: '',
      productId: '',
      parentId: '',
      productName: '',
      productDescription: '',
      categoryId: '',
      categoryName: '',
      price: 0,
      quantity: 0,
      productImages: [],
      adminApproval: '',
      activated: false,
    );
  }

  Data copyWith({
    String? distributorId,
    String? productId,
    String? parentId,
    String? productName,
    String? productDescription,
    String? categoryId,
    String? categoryName,
    int? price,
    int? quantity,
    List<String>? productImages,
    String? adminApproval,
    bool? activated,
  }) {
    return Data(
      distributorId: distributorId ?? this.distributorId,
      productId: productId ?? this.productId,
      parentId: parentId ?? this.parentId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productImages: productImages ?? this.productImages,
      adminApproval: adminApproval ?? this.adminApproval,
      activated: activated ?? this.activated,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    distributorId = json['distributorId'];
    productId = json['productId'];
    parentId = json['parentId'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    price = json['price'];
    quantity = json['quantity'];
    productImages = json['productImages'].cast<String>();
    adminApproval = json['adminApproval'];
    activated = json['activated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['distributorId'] = productId;
    data['productId'] = productId;
    data['parentId'] = parentId;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['price'] = price;
    data['quantity'] = quantity;
    data['productImages'] = productImages;
    data['adminApproval'] = adminApproval;
    data['activated'] = activated;
    return data;
  }
}
