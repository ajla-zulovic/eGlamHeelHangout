import 'package:json_annotation/json_annotation.dart';

part 'intentresponse.g.dart';

@JsonSerializable()
class IntentResponse {
  final String paymentIntentId;
  final String clientSecret;

  IntentResponse({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  factory IntentResponse.fromJson(Map<String, dynamic> json) =>
      _$IntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IntentResponseToJson(this);
}
