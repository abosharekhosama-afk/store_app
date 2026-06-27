import 'package:untitled2_ecom/features/shop/models/banner_model.dart';
import 'package:untitled2_ecom/features/shop/models/brand_category_model.dart';
import 'package:untitled2_ecom/features/shop/models/brand_model.dart';
import 'package:untitled2_ecom/features/shop/models/category_model.dart';
import 'package:untitled2_ecom/features/shop/models/product_category_model.dart';
import 'package:untitled2_ecom/utils/constants/image_strings.dart';
import 'package:untitled2_ecom/utils/constants/text_strings.dart';

class TDummyData {
  /// -- User
  /*static final UserModel user = UserModel(
    fullName: 'Coding with T',
    email: 'support@codingwithT.com',
    phoneNumber: '+14155552671',
    profilePicture: TImages.user,
    addresses: [
      AddressModel(
        id: '1',
        name: 'Coding with T',
        phoneNumber: '+923178059528',
        street: '82356 Timmy Coves',
        city: 'South Liana',
        state: 'Maine',
        postalCode: '87665',
        country: 'USA',
      ),
      AddressModel(
        id: '6',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        street: '123 Main Street',
        city: 'New York',
        state: 'New York',
        postalCode: '10001',
        country: 'United States',
      ),

      AddressModel(
        id: '2',
        name: 'Alice Smith',
        phoneNumber: '+9876543210',
        street: '456 Elm Avenue',
        city: 'Los Angeles',
        state: 'California',
        postalCode: '90001',
        country: 'United States',
      ),

      AddressModel(
        id: '3',
        name: 'Taimoor Sikander',
        phoneNumber: '+923178059528',
        street: 'Street 35',
        city: 'Islamabad',
        state: 'Federal',
        postalCode: '48000',
        country: 'Pakistan',
      ),

      AddressModel(
        id: '4',
        name: 'Maria Garcia',
        phoneNumber: '+5412345678',
        street: '789 Oak Road',
        city: 'Buenos Aires',
        state: 'Buenos Aires',
        postalCode: '1001',
        country: 'Argentina',
      ),

      AddressModel(
        id: '5',
        name: 'Liam Johnson',
        phoneNumber: '+447890123456',
        street: '10 Park Lane',
        city: 'London',
        state: 'England',
        postalCode: 'SW1A 1AA',
        country: 'United Kingdom',
      )
    ],
    id: '',
    isEmailVerified: true, isProfileActive: true,
  );
*/
  /// -- Cart
  /*static final CartModel cart = CartModel(
    cartId: '001',
    items: [
      CartItemModel(
        productId: '001',
        variationId: '1',
        quantity: 1,
        title: products[0].title,
        image: products[0].thumbnail,
        brandName: products[0].brand!.name,
        price: products[0].productVariations![0].price,
        selectedVariation: products[0].productVariations![0].attributeValues,
      ),
      CartItemModel(
        productId: '002',
        variationId: '',
        quantity: 1,
        title: products[1].title,
        image: products[1].thumbnail,
        brandName: products[1].brand!.name,
        price: products[1].price,
        selectedVariation: products[1].productVariations != null ? products[1].productVariations![1].attributeValues : {},
      ),
    ],
  );
*/
  /// -- List of all Categories
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      image: TImages.sportIcon,
      name: 'Sports',
      isFeatured: true,
    ),
    CategoryModel(
      id: '5',
      image: TImages.furnitureIcon,
      name: 'Furniture',
      isFeatured: true,
    ),
    CategoryModel(
      id: '2',
      image: TImages.electronicsIcon,
      name: 'Electronics',
      isFeatured: true,
    ),
    CategoryModel(
      id: '3',
      image: TImages.clothIcon,
      name: 'Clothes',
      isFeatured: true,
    ),
    CategoryModel(
      id: '4',
      image: TImages.animalIcon,
      name: 'Animals',
      isFeatured: true,
    ),
    CategoryModel(
      id: '6',
      image: TImages.shoeIcon,
      name: 'Shoes',
      isFeatured: true,
    ),
    CategoryModel(
      id: '7',
      image: TImages.cosmeticsIcon,
      name: 'Cosmetics',
      isFeatured: true,
    ),
    CategoryModel(
      id: '14',
      image: TImages.jeweleryIcon,
      name: 'Jewelery',
      isFeatured: true,
    ),

    ///subcategories
    CategoryModel(
      id: '8',
      image: TImages.sportIcon,
      name: 'Sport Shoes',
      parentId: '1',
      isFeatured: false,
    ),
    CategoryModel(
      id: '9',
      image: TImages.sportIcon,
      name: 'Track suits',
      parentId: '1',
      isFeatured: false,
    ),
    CategoryModel(
      id: '10',
      image: TImages.sportIcon,
      name: 'Sports Equipments',
      parentId: '1',
      isFeatured: false,
    ),
    //furniture
    CategoryModel(
      id: '11',
      image: TImages.furnitureIcon,
      name: 'Bedroom furniture',
      parentId: '5',
      isFeatured: false,
    ),
    CategoryModel(
      id: '12',
      image: TImages.furnitureIcon,
      name: 'Kitchen furniture',
      parentId: '5',
      isFeatured: false,
    ),
    CategoryModel(
      id: '13',
      image: TImages.furnitureIcon,
      name: 'Office furniture',
      parentId: '5',
      isFeatured: false,
    ),
    //electronics
    CategoryModel(
      id: '14',
      image: TImages.electronicsIcon,
      name: 'Laptop',
      parentId: '2',
      isFeatured: false,
    ),
    CategoryModel(
      id: '15',
      image: TImages.electronicsIcon,
      name: 'Mobile',
      parentId: '2',
      isFeatured: false,
    ),

    CategoryModel(
      id: '16',
      image: TImages.clothIcon,
      name: 'Shirts',
      parentId: '3',
      isFeatured: false,
    ),
  ];

  /// -- List of all Products
  /*
  static final List<ProductModel> products = [
    ProductModel(
      id: '001',
      title: 'Green Nike sports shoe',
      stock: 15,
      price: 135,
      isFeatured: true,
      thumbnail: TImages.productImage1,
      description: 'Green Nike sports shoe',
      brande: BrandModel(
        id: '1',
        image: TImages.nikeLogo,
        name: 'Nike',
        productsCount: 265,
        isFeatured: true,
      ),
      images: [
        TImages.productImage1,
        TImages.productImage23,
        TImages.productImage21,
        TImages.productImage9,
      ],
      salePrice: 30,
      sku: 'ABR4568',
      categoryId: '1',
      productAttribute: [
        ProductAttributeModel(name: 'Color', values: ['Green', 'Black', 'Red']),
        ProductAttributeModel(
          name: 'Size',
          values: ['EU 30', 'EU 32', 'EU 34'],
        ),
      ],
      productVariation: [
        ProductVariationModel(
          id: '1',
          stock: 34,
          price: 134,
          salePrice: 122.6,
          image: TImages.productImage1,
          description:
              'This is a Product description for Green Nike sports shoe.',
          attributeValues: {'Color': 'Green', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '2',
          stock: 15,
          price: 132,
          image: TImages.productImage23,
          attributeValues: {'Color': 'Black', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '3',
          stock: 0,
          price: 234,
          image: TImages.productImage23,
          attributeValues: {'Color': 'Black', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '4',
          stock: 222,
          price: 232,
          image: TImages.productImage1,
          attributeValues: {'Color': 'Green', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '5',
          stock: 0,
          price: 334,
          image: TImages.productImage21,
          attributeValues: {'Color': 'Red', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '6',
          stock: 11,
          price: 332,
          image: TImages.productImage21,
          attributeValues: {'Color': 'Red', 'Size': 'EU 32'},
        ),
      ],
      productType: 'ProductType.variable',
    ),
    ProductModel(
      id: '002',
      title: 'Blue T-shirt for all ages',
      stock: 15,
      price: 35,
      isFeatured: true,
      thumbnail: TImages.productImage69,
      description:
          'This is a Product description for Blue Nike Sleeve less vest. There are more things that can be added but i am just practicing and nothing else.',
      brande: BrandModel(id: '6', image: TImages.zaraLogo, name: 'ZARA'),
      images: [
        TImages.productImage68,
        TImages.productImage69,
        TImages.productImage5,
      ],
      salePrice: 30,
      sku: 'ABR4568',
      categoryId: '16',
      productAttribute: [
        ProductAttributeModel(name: 'Size', values: ['EU34', 'EU32']),
        ProductAttributeModel(name: 'Color', values: ['Green', 'Red', 'Blue']),
      ],
      productType: 'ProductType.single',
    ),
    ProductModel(
      id: '003',
      title: 'Leather brown Jacket',
      stock: 15,
      price: 38000,
      isFeatured: false,
      thumbnail: TImages.productImage64,
      description:
          'This is a Product description for Leather brown Jacket. There are more things that can be added but i am just practicing and nothing else.',
      brande: BrandModel(id: '6', image: TImages.zaraLogo, name: 'ZARA'),
      images: [
        TImages.productImage64,
        TImages.productImage65,
        TImages.productImage66,
        TImages.productImage67,
      ],
      salePrice: 30,
      sku: 'ABR4568',
      categoryId: '16',
      productAttribute: [
        ProductAttributeModel(name: 'Size', values: ['EU34', 'EU32']),
        ProductAttributeModel(name: 'Color', values: ['Green', 'Red', 'Blue']),
      ],
      productType: 'ProductType.single',
    ),
    ProductModel(
      id: '004',
      title: '4 Color collar t-shirt dry fit',
      stock: 15,
      price: 135,
      isFeatured: false,
      thumbnail: TImages.productImage60,
      description:
          'This is a Product description for 4 Color collar t-shirt dry fit. There are more things that can be added but its just a demo and nothing else.',
      brande: BrandModel(id: '6', image: TImages.zaraLogo, name: 'ZARA'),
      images: [
        TImages.productImage60,
        TImages.productImage61,
        TImages.productImage62,
        TImages.productImage63,
      ],
      salePrice: 30,
      sku: 'ABR4568',
      categoryId: '16',
      productAttribute: [
        ProductAttributeModel(
          name: 'Color',
          values: ['Red', 'Yellow', 'Green', 'Blue'],
        ),
        ProductAttributeModel(
          name: 'Size',
          values: ['EU 30', 'EU 32', 'EU 34'],
        ),
      ],
      productVariation: [
        ProductVariationModel(
          id: '1',
          stock: 34,
          price: 134,
          salePrice: 122.6,
          image: TImages.productImage60,
          description:
              'This is a Product description for 4 Color collar t-shirt dry fit',
          attributeValues: {'Color': 'Red', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '2',
          stock: 15,
          price: 132,
          image: TImages.productImage60,
          attributeValues: {'Color': 'Red', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '3',
          stock: 0,
          price: 234,
          image: TImages.productImage61,
          attributeValues: {'Color': 'Yellow', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '4',
          stock: 222,
          price: 232,
          image: TImages.productImage61,
          attributeValues: {'Color': 'Yellow', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '5',
          stock: 0,
          price: 334,
          image: TImages.productImage62,
          attributeValues: {'Color': 'Green', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '6',
          stock: 11,
          price: 332,
          image: TImages.productImage62,
          attributeValues: {'Color': 'Green', 'Size': 'EU 30'},
        ),
        ProductVariationModel(
          id: '7',
          stock: 0,
          price: 334,
          image: TImages.productImage63,
          attributeValues: {'Color': 'Blue', 'Size': 'EU 30'},
        ),
        ProductVariationModel(
          id: '8',
          stock: 11,
          price: 332,
          image: TImages.productImage63,
          attributeValues: {'Color': 'Blue', 'Size': 'EU 34'},
        ),
      ],
      productType: 'ProductType.variable',
    ),

    ///Products after banner
    ProductModel(
      id: '005',
      title: 'Nike Air Jordon Shoes',
      stock: 15,
      price: 35,
      isFeatured: false,
      thumbnail: TImages.productImage10,
      description:
          'Nike Air Jordon Shoes for running. Quality product, Long Lasting',
      brande: BrandModel(
        id: '1',
        image: TImages.nikeLogo,
        name: 'Nike',
        productsCount: 265,
        isFeatured: true,
      ),
      images: [
        TImages.productImage7,
        TImages.productImage8,
        TImages.productImage9,
        TImages.productImage10,
      ],
      salePrice: 30,
      sku: 'ABR4568',
      categoryId: '8',
      productAttribute: [
        ProductAttributeModel(
          name: 'Color',
          values: ['Orange', 'Black', 'Brown'],
        ),
        ProductAttributeModel(
          name: 'Size',
          values: ['EU 30', 'EU 32', 'EU 34'],
        ),
      ],
      productVariation: [
        ProductVariationModel(
          id: '1',
          stock: 16,
          price: 36,
          salePrice: 12.6,
          image: TImages.productImage8,
          description:
              'Flutter is Google’s mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase.',
          attributeValues: {'Color': 'Orange', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '2',
          stock: 15,
          price: 35,
          image: TImages.productImage7,
          attributeValues: {'Color': 'Black', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '3',
          stock: 14,
          price: 34,
          image: TImages.productImage9,
          attributeValues: {'Color': 'Brown', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '4',
          stock: 13,
          price: 33,
          image: TImages.productImage7,
          attributeValues: {'Color': 'Black', 'Size': 'EU 34'},
        ),
        ProductVariationModel(
          id: '5',
          stock: 12,
          price: 32,
          image: TImages.productImage9,
          attributeValues: {'Color': 'Brown', 'Size': 'EU 32'},
        ),
        ProductVariationModel(
          id: '6',
          stock: 11,
          price: 31,
          image: TImages.productImage8,
          attributeValues: {'Color': 'Orange', 'Size': 'EU 32'},
        ),
      ],
      productType: 'ProductType.variable',
    ),
    ProductModel(
      id: '006',
      title: 'SAMSUNG Galaxy S9',
      stock: 15,
      price: 750,
      isFeatured: false,
      thumbnail: TImages.productImage11,
      description:
          'SAMSUNG Galaxy S9 (Pink, 64 GB)  (4 GB RAM), Long Battery timing',
      brande: BrandModel(id: '7', image: TImages.appleLogo, name: 'Samsung'),
      images: [
        TImages.productImage11,
        TImages.productImage12,
        TImages.productImage13,
        TImages.productImage12,
      ],
      salePrice: 650,
      sku: 'ABR4568',
      categoryId: '2',
      productAttribute: [
        ProductAttributeModel(name: 'Size', values: ['EU34', 'EU32']),
        ProductAttributeModel(name: 'Color', values: ['Green', 'Red', 'Blue']),
      ],
      productType: 'ProductType.single',
    ),
    ProductModel(
      id: '007',
      title: 'TOMI Dog food',
      stock: 15,
      price: 20,
      isFeatured: false,
      thumbnail: TImages.productImage18,
      description:
          'This is a Product description for TOMI Dog food. There are more things that can be added but i am just practicing and nothing else.',
      brande: BrandModel(id: '7', image: TImages.appleLogo, name: 'Tomi'),
      salePrice: 10,
      sku: 'ABR4568',
      categoryId: '4',
      productAttribute: [
        ProductAttributeModel(name: 'Size', values: ['EU34', 'EU32']),
        ProductAttributeModel(name: 'Color', values: ['Green', 'Red', 'Blue']),
      ],
      productType: 'ProductType.single',
    ),
    //008 after 040
    ProductModel(
      id: '009',
      title: 'Nike Air Jordon 19 Blue',
      stock: 15,
      price: 400,
      isFeatured: false,
      thumbnail: TImages.productImage19,
      description:
          'This is a Product description for Nike Air Jordon. There are more things that can be added but i am just practicing and nothing else.',
      brande: BrandModel(id: '1', image: TImages.nikeLogo, name: 'Nike'),
      images: [
        TImages.productImage19,
        TImages.productImage20,
        TImages.productImage21,
        TImages.productImage22,
      ],
      salePrice: 200,
      sku: 'ABR4568',
      categoryId: '8',
      productAttribute: [
        ProductAttributeModel(name: 'Size', values: ['EU34', 'EU32']),
        ProductAttributeModel(name: 'Color', values: ['Green', 'Red', 'Blue']),
      ],
      productType: 'ProductType.single',
    ),
  ];
*/
  static final List<BrandModel> brands = [
    BrandModel(
      id: '1',
      image: TImages.nikeLogo,
      name: 'Nike',
      productsCount: 265,
      isFeatured: true,
    ),
    BrandModel(
      id: '7',
      image: TImages.appleLogo,
      name: 'Tomi',
      isFeatured: false,
      productsCount: 173,
    ),
    BrandModel(
      id: '6',
      image: TImages.zaraLogo,
      name: 'ZARA',
      isFeatured: false,
      productsCount: 269,
    ),
    BrandModel(
      id: '2',
      image: TImages.ikeaLogo,
      name: 'Ikea',
      isFeatured: true,
      productsCount: 22,
    ),
    BrandModel(
      id: '3',
      image: TImages.acerLogo,
      name: 'Acer',
      isFeatured: true,
      productsCount: 65,
    ),
    BrandModel(
      id: '4',
      image: TImages.adidasLogo,
      name: 'Adidas',
      isFeatured: true,
      productsCount: 91,
    ),
    BrandModel(
      id: '8',
      image: TImages.hermanLogo,
      name: 'Herman',
      isFeatured: true,
      productsCount: 130,
    ),
    BrandModel(id: '9', image: TImages.pumaLogo, name: 'Pumal'),
    BrandModel(
      id: '10',
      image: TImages.jordanLogo,
      name: 'Jordan',
      isFeatured: false,
      productsCount: 620,
    ),
    BrandModel(
      id: '5',
      image: TImages.kenwoodLogo,
      name: 'Kenwood',
      isFeatured: false,
      productsCount: 410,
    ),
  ];

  /// -- Sorting Filters for search
  static final sortingFilters = [
    SortFilterModel(id: '1', name: TTexts.sortByName),
    SortFilterModel(id: '2', name: TTexts.sortByLowestPrice),
    SortFilterModel(id: '3', name: TTexts.sortByMostPopular),
    SortFilterModel(id: '4', name: TTexts.sortByHighestPrice),
    SortFilterModel(id: '5', name: TTexts.sortByNewest),
    SortFilterModel(id: '6', name: TTexts.sortByMostSuitable),
  ];

  static final List<BannerModel> banners = [
    BannerModel(
      imageUrl: TImages.promoBanner1,
      targetScreen: "",
      acttive: true,
    ),
    BannerModel(
      imageUrl: TImages.promoBanner2,
      targetScreen: "",
      acttive: true,
    ),
    BannerModel(
      imageUrl: TImages.promoBanner3,
      targetScreen: "",
      acttive: true,
    ),
    BannerModel(imageUrl: TImages.banner2, targetScreen: "", acttive: true),
    BannerModel(imageUrl: TImages.banner4, targetScreen: "", acttive: true),
    BannerModel(imageUrl: TImages.banner3, targetScreen: "", acttive: true),
  ];

  static final List<BrandCategoryModel> brandCategory = [
    BrandCategoryModel(brandId: "1", categoryId: "1"),
    BrandCategoryModel(brandId: "4", categoryId: "1"),
    BrandCategoryModel(brandId: "10", categoryId: "1"),
    BrandCategoryModel(brandId: "3", categoryId: "2"),
    BrandCategoryModel(brandId: "8", categoryId: "3"),
    BrandCategoryModel(brandId: "6", categoryId: "3"),
    BrandCategoryModel(brandId: "3", categoryId: "16"),
    BrandCategoryModel(brandId: "6", categoryId: "8"),
    BrandCategoryModel(brandId: "2", categoryId: "8"),
  ];

  static final List<ProductCategoryModel> productCategory = [
    ProductCategoryModel(productId: "001", categoryId: "1"),
    ProductCategoryModel(productId: "002", categoryId: "1"),
    ProductCategoryModel(productId: "003", categoryId: "16"),
    ProductCategoryModel(productId: "004", categoryId: "16"),
    ProductCategoryModel(productId: "005", categoryId: "8"),
    ProductCategoryModel(productId: "009", categoryId: "8"),
    ProductCategoryModel(productId: "007", categoryId: "4"),
  ];
}

class SortFilterModel {
  String id;
  String name;

  SortFilterModel({required this.id, required this.name});
}
