import 'package:untitled2_ecom/enums.dart';

class CartItemModel {
  String productId;
  String storeId; // حقل معرف المتجر لتمكين تقسيم الطلب
  String title;
  double price;
  String? image;
  int quantity;
  ItemStatus itemStatus; // حالة العنصر (معلق، مقبول، مرفوض، إلخ)
  String variationId;
  Map<String, String>? selectedVariation;
  Map<String, dynamic>?
  productSnapshot; // نسخة كاملة من بيانات المنتج وقت الطلب

  CartItemModel({
    required this.productId,
    required this.storeId,
    required this.quantity,
    this.itemStatus = ItemStatus.pending,
    this.variationId = "",
    this.image,
    this.price = 0.0,
    this.title = "",
    this.selectedVariation,
    this.productSnapshot,
  });

  /// مسميات الحقول الثابتة
  static String get getOrderListCollectionName => "StoreOrders";
  static String get getCartItemForLocalStorage => "CartItem";
  static String get getProductId => "productId";
  static String get getStoreId => "storeId";
  static String get getQuantity => "Quantity";
  static String get getItemStatus => "itemStatus";
  static String get getVariationId => "VariationId";
  static String get getImage => "Image";
  static String get getPrice => "price";
  static String get getTitle => "Title";
  static String get getSelectedVariation => "selectedVariation";
  static String get getProductSnapshot => "productSnapshot";

  /// كائن فارغ
  static CartItemModel empty() =>
      CartItemModel(productId: "", storeId: "", quantity: 0);

  /// تحويل الكائن إلى JSON لتخزينه في Firebase
  Map<String, dynamic> toJson() {
    return {
      getProductId: productId,
      getStoreId: storeId,
      getQuantity: quantity,
      getItemStatus: itemStatus.name, // تخزين اسم الحالة (pending, accepted...)
      getVariationId: variationId,
      getImage: image,
      getPrice: price,
      getTitle: title,
      getSelectedVariation: selectedVariation,
      getProductSnapshot: productSnapshot,
    };
  }

  /// إنشاء كائن من JSON القادم من Firebase
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json[getProductId] ?? '',
      storeId: json[getStoreId] ?? '',
      quantity: int.parse((json[getQuantity] ?? 0).toString()),
      itemStatus: ItemStatus.values.firstWhere(
        (e) => e.name == (json[getItemStatus] ?? 'pending'),
        orElse: () => ItemStatus.pending,
      ),
      image: json[getImage],
      price: double.parse((json[getPrice] ?? 0.0).toString()),
      title: json[getTitle] ?? '',
      variationId: json[getVariationId] ?? '',
      selectedVariation: json[getSelectedVariation] != null
          ? Map<String, String>.from(json[getSelectedVariation])
          : null,
      productSnapshot: json[getProductSnapshot] != null
          ? Map<String, dynamic>.from(json[getProductSnapshot])
          : null,
    );
  }

  CartItemModel copyWith({
    String? productId,
    String? storeId,
    String? title,
    double? price,
    String? image,
    int? quantity,
    ItemStatus? itemStatus,
    String? variationId,
    Map<String, String>? selectedVariation,
    Map<String, dynamic>? productSnapshot,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      itemStatus: itemStatus ?? this.itemStatus,
      variationId: variationId ?? this.variationId,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      productSnapshot: productSnapshot ?? this.productSnapshot,
    );
  }
}
