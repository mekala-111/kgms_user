class ProductservicesModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ProductservicesModel({this.statusCode, this.success, this.messages, this.data});

  factory ProductservicesModel.initial() {
    return ProductservicesModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  ProductservicesModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ProductservicesModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  ProductservicesModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
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
  String? productId;
  String? productName;
  String? productDescription;
  String? categoryId;
  String? categoryName;
  int? price;
  int? quantity;
  String? adminApproval;
  bool? activated;
  List<String>? productImages;
  List<LinkedSpareParts>? linkedSpareParts;

  Data({
    this.productId,
    this.productName,
    this.productDescription,
    this.categoryId,
    this.categoryName,
    this.price,
    this.quantity,
    this.adminApproval,
    this.activated,
    this.productImages,
    this.linkedSpareParts,
  });

  factory Data.initial() {
    return Data(
      productId: '',
      productName: '',
      productDescription: '',
      categoryId: '',
      categoryName: '',
      price: 0,
      quantity: 0,
      adminApproval: '',
      activated: false,
      productImages: [],
      linkedSpareParts: [],
    );
  }

  Data copyWith({
    String? productId,
    String? productName,
    String? productDescription,
    String? categoryId,
    String? categoryName,
    int? price,
    int? quantity,
    String? adminApproval,
    bool? activated,
    List<String>? productImages,
    List<LinkedSpareParts>? linkedSpareParts,
  }) {
    return Data(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      adminApproval: adminApproval ?? this.adminApproval,
      activated: activated ?? this.activated,
      productImages: productImages ?? this.productImages,
      linkedSpareParts: linkedSpareParts ?? this.linkedSpareParts,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    price = json['price'];
    quantity = json['quantity'];
    adminApproval = json['adminApproval'];
    activated = json['activated'];
    productImages = json['productImages'].cast<String>();
    if (json['linkedSpareParts'] != null) {
      linkedSpareParts = <LinkedSpareParts>[];
      json['linkedSpareParts'].forEach((v) {
        linkedSpareParts!.add(LinkedSpareParts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productId'] = productId;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['price'] = price;
    data['quantity'] = quantity;
    data['adminApproval'] = adminApproval;
    data['activated'] = activated;
    data['productImages'] = productImages;
    if (linkedSpareParts != null) {
      data['linkedSpareParts'] = linkedSpareParts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LinkedSpareParts {
  String? productId;
  String? parentId;
  String? productName;
  String? productDescription;
  int? price;
  int? quantity;
  String? adminApproval;
  bool? activated;
  List<String>? productImages;

  LinkedSpareParts({
    this.productId,
    this.parentId,
    this.productName,
    this.productDescription,
    this.price,
    this.quantity,
    this.adminApproval,
    this.activated,
    this.productImages,
  });

  factory LinkedSpareParts.initial() {
    return LinkedSpareParts(
      productId: '',
      parentId: '',
      productName: '',
      productDescription: '',
      price: 0,
      quantity: 0,
      adminApproval: '',
      activated: false,
      productImages: [],
    );
  }

  LinkedSpareParts copyWith({
    String? productId,
    String? parentId,
    String? productName,
    String? productDescription,
    int? price,
    int? quantity,
    String? adminApproval,
    bool? activated,
    List<String>? productImages,
  }) {
    return LinkedSpareParts(
      productId: productId ?? this.productId,
      parentId: parentId ?? this.parentId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      adminApproval: adminApproval ?? this.adminApproval,
      activated: activated ?? this.activated,
      productImages: productImages ?? this.productImages,
    );
  }

  LinkedSpareParts.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    parentId = json['parentId'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    price = json['price'];
    quantity = json['quantity'];
    adminApproval = json['adminApproval'];
    activated = json['activated'];
    productImages = json['productImages'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productId'] = productId;
    data['parentId'] = parentId;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['price'] = price;
    data['quantity'] = quantity;
    data['adminApproval'] = adminApproval;
    data['activated'] = activated;
    data['productImages'] = productImages;
    return data;
  }
}
