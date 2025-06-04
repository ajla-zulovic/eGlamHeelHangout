import 'package:json_annotation/json_annotation.dart';

part 'paymentcreate.g.dart';

@JsonSerializable()
class PaymentCreate {
  final int? orderId;
  final int? reservationId;
  final int totalAmount;
  final String paymentMethodId;
  final String username;

  PaymentCreate({
    this.orderId,
    this.reservationId,
    required this.totalAmount,
    required this.paymentMethodId,
    required this.username,
  });

  factory PaymentCreate.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreateFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreateToJson(this);
}
