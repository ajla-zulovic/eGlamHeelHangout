import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

@JsonSerializable()
class Discount {
  final int productId;
  final int  discountPercentage;
  final DateTime startDate;
  final DateTime endDate;

  Discount({
    required this.productId,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);
  Map<String, dynamic> toJson() => _$DiscountToJson(this);
}
