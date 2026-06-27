import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  String imageUrl;
  final String targetScreen;
  final bool acttive;

  BannerModel({
    required this.imageUrl,
    required this.targetScreen,
    required this.acttive,
  });

  Map<String, dynamic> toJson() {
    return {
      "ImageUrl": imageUrl,
      "TargetScreen": targetScreen,
      "Acttive": acttive,
    };
  }

  factory BannerModel.fromsnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BannerModel(
      imageUrl: data["ImageUrl"] ?? "",
      targetScreen: data["TargetScreen"] ?? "",
      acttive: data["Acttive"] ?? false,
    );
  }
}
