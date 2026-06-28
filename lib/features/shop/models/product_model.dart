import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled2_ecom/enums.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_attribute_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_variation_model.dart';
import 'package:untitled2_ecom/utils/constants/enums.dart';
import 'package:hive/hive.dart';
// هذا السطر مهم جداً لتوليد الكود لاحقاً
part 'product_model.g.dart';

/// كلاس يحتوي على جميع أسماء الحقول كمتغيرات ثابتة لسهولة الاستدعاء ومنع أخطاء الكتابة
class TProductFields {
  static const String productsCollectionName = 'Products';
  static const String id = 'Id';
  static const String storId = 'StorId';
  static const String stock = 'Stock';
  static const String sku = 'SKU';
  static const String price = 'Price';
  static const String title = 'Title';
  static const String date = 'Date';
  static const String salePrice = 'SalePrice';
  static const String thumbnail = 'Thumbnail';
  static const String isFeatured = 'IsFeatured';
  static const String brande = 'Brande';
  static const String description = 'Description';
  static const String categoryId = 'CategoryId';
  static const String images = 'Images';
  static const String productType = 'ProductType';
  static const String productVisibility = 'ProductVisibility';
  static const String productAttribute = 'ProductAttribute';
  static const String productVariation = 'ProductVariation';
  static const String sortId = 'SortId';
  static const String tags = 'Tags'; // الحقل الجديد
  static const String searchKeywords = 'SearchKeywords';
  static const String titleLowercase = 'TitleLowercase';
}

@HiveType(typeId: 0) // الرقم 0 محجوز لـ ProductModel
class ProductModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String storId;

  @HiveField(2)
  int stock;

  @HiveField(3)
  String? sku;

  @HiveField(4)
  double price;

  @HiveField(5)
  String title;

  @HiveField(6)
  DateTime? date;

  @HiveField(7)
  double salePrice;

  @HiveField(8)
  String thumbnail;

  @HiveField(9)
  bool? isFeatured;

  @HiveField(10)
  BrandModel? brande;

  @HiveField(11)
  String? description;

  @HiveField(12)
  String? categoryId;

  @HiveField(13)
  List<String>? images;

  @HiveField(14)
  List<String>? tags;

  @HiveField(15)
  String productType;

  @HiveField(16)
  ProductVisibility productVisibility; // يفضل تخزينها كـ String إذا كانت Enum

  @HiveField(17)
  List<ProductAttributeModel>? productAttribute;

  @HiveField(18)
  List<ProductVariationModel>? productVariation;

  @HiveField(19)
  int sortId;

  @HiveField(20)
  List<String>? searchKeywords;

  @HiveField(21)
  String? titleLowercase;
  ProductModel({
    required this.id,
    required this.storId,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sortId = 0,
    this.sku,
    this.brande,
    this.date,
    this.images,
    this.tags,
    this.salePrice = 0.0,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.searchKeywords,
    this.titleLowercase,
    this.productAttribute,
    this.productVariation,
    this.productVisibility = ProductVisibility.published,
  });

  /// إنشاء منتج فارغ
  static ProductModel empty() => ProductModel(
    id: "",
    storId: "",
    title: "",
    stock: 0,
    price: 0,
    thumbnail: "",
    productType: "",
  );

  /// Helper Methods للتحقق من نوع المنتج
  bool get isSingleProduct => productType == ProductType.single.name;
  bool get isVariableProduct => productType == ProductType.variable.name;

  String get normalizedProductType {
    if (isSingleProduct) return ProductType.single.name;
    if (isVariableProduct) return ProductType.variable.name;
    return productType;
  }

  static String _normalizeProductType(dynamic type) {
    final normalized = type?.toString() ?? "";
    if (normalized == ProductType.single.toString() ||
        normalized == ProductType.single.name) {
      return ProductType.single.name;
    }
    if (normalized == ProductType.variable.toString() ||
        normalized == ProductType.variable.name) {
      return ProductType.variable.name;
    }
    return normalized;
  }

  /// تحويل الموديل إلى Json للإرسال إلى Firebase
  Map<String, dynamic> toJson() {
    return {
      TProductFields.storId: storId,
      TProductFields.sku: sku,
      TProductFields.title: title,
      TProductFields.stock: stock,
      TProductFields.price: price,
      TProductFields.images: images ?? [],
      TProductFields.thumbnail: thumbnail,
      TProductFields.salePrice: salePrice,
      TProductFields.isFeatured: isFeatured,
      TProductFields.categoryId: categoryId,
      TProductFields.brande: brande?.toJson(),
      TProductFields.description: description,
      TProductFields.tags: tags ?? [],
      TProductFields.productType: productType,
      TProductFields.productVisibility: productVisibility.name,
      TProductFields.productAttribute:
          productAttribute?.map((e) => e.toJson()).toList() ?? [],
      TProductFields.productVariation:
          productVariation?.map((e) => e.toJson()).toList() ?? [],
      TProductFields.sortId: sortId,
      TProductFields.searchKeywords: generateKeywords(title, description, tags),
      TProductFields.titleLowercase: title.toLowerCase(),
      TProductFields.date: date ?? DateTime.now(),
    };
  }

  /// من Snapshot (للمستند الواحد)
  factory ProductModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    if (document.data() == null) return ProductModel.empty();
    final data = document.data()!;
    return ProductModel(
      id: document.id,
      storId: data[TProductFields.storId] ?? "",
      title: data[TProductFields.title] ?? "",
      stock: data[TProductFields.stock] ?? 0,
      price: double.parse((data[TProductFields.price] ?? 0.0).toString()),
      thumbnail: data[TProductFields.thumbnail] ?? "",
      sku: data[TProductFields.sku],
      salePrice: double.parse(
        (data[TProductFields.salePrice] ?? 0.0).toString(),
      ),
      categoryId: data[TProductFields.categoryId] ?? "",
      description: data[TProductFields.description] ?? "",
      isFeatured: data[TProductFields.isFeatured] ?? false,
      sortId: data[TProductFields.sortId] ?? 0,
      productType: data[TProductFields.productType] ?? ProductType.single.name,
      titleLowercase: data[TProductFields.titleLowercase] ?? "",
      date: data[TProductFields.date] != null
          ? (data[TProductFields.date] as Timestamp).toDate()
          : null,
      tags: data[TProductFields.tags] != null
          ? List<String>.from(data[TProductFields.tags])
          : [],
      images: data[TProductFields.images] != null
          ? List<String>.from(data[TProductFields.images])
          : [],
      searchKeywords: data[TProductFields.searchKeywords] != null
          ? List<String>.from(data[TProductFields.searchKeywords])
          : [],
      brande: data[TProductFields.brande] != null
          ? BrandModel.fromJson(data[TProductFields.brande])
          : BrandModel.empty(),
      productVisibility: ProductVisibility.values.firstWhere(
        (v) => v.name == data[TProductFields.productVisibility],
        orElse: () => ProductVisibility.published,
      ),
      productAttribute:
          (data[TProductFields.productAttribute] as List<dynamic>?)
              ?.map((e) => ProductAttributeModel.fromJson(e))
              .toList() ??
          [],
      productVariation:
          (data[TProductFields.productVariation] as List<dynamic>?)
              ?.map((e) => ProductVariationModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// من QuerySnapshot (للبحث أو جلب المجموعات)
  factory ProductModel.fromQuerySnapshot(
    QueryDocumentSnapshot<Object?> document,
  ) {
    final data = document.data() as Map<String, dynamic>;
    return ProductModel(
      id: document.id,
      storId: data[TProductFields.storId] ?? "",
      title: data[TProductFields.title] ?? "",
      stock: data[TProductFields.stock] ?? 0,
      price: double.parse((data[TProductFields.price] ?? 0.0).toString()),
      thumbnail: data[TProductFields.thumbnail] ?? "",
      sku: data[TProductFields.sku],
      salePrice: double.parse(
        (data[TProductFields.salePrice] ?? 0.0).toString(),
      ),
      categoryId: data[TProductFields.categoryId] ?? "",
      description: data[TProductFields.description] ?? "",
      isFeatured: data[TProductFields.isFeatured] ?? false,
      sortId: data[TProductFields.sortId] ?? 0,
      productType: data[TProductFields.productType] ?? ProductType.single.name,
      tags: data[TProductFields.tags] != null
          ? List<String>.from(data[TProductFields.tags])
          : [],
      images: data[TProductFields.images] != null
          ? List<String>.from(data[TProductFields.images])
          : [],
      brande: data[TProductFields.brande] != null
          ? BrandModel.fromJson(data[TProductFields.brande])
          : BrandModel.empty(),
      productVisibility: ProductVisibility.values.firstWhere(
        (v) => v.name == data[TProductFields.productVisibility],
        orElse: () => ProductVisibility.published,
      ),
      productAttribute:
          (data[TProductFields.productAttribute] as List<dynamic>?)
              ?.map((e) => ProductAttributeModel.fromJson(e))
              .toList() ??
          [],
      productVariation:
          (data[TProductFields.productVariation] as List<dynamic>?)
              ?.map((e) => ProductVariationModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// توليد الكلمات المفتاحية للبحث
  static List<String> generateKeywords(
    String title,
    String? desc,
    List<String>? tags,
  ) {
    String combined =
        "${title.toLowerCase()} ${desc?.toLowerCase() ?? ""} ${tags?.join(" ").toLowerCase() ?? ""}";
    return combined
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1)
        .toSet()
        .toList();
  }
}
