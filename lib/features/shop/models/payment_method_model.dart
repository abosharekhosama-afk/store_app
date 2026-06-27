class PaymentMethodModel {
  String name;
  String image;

  PaymentMethodModel({required this.image, required this.name});

  static PaymentMethodModel emoty() => PaymentMethodModel(image: "", name: "");
}
