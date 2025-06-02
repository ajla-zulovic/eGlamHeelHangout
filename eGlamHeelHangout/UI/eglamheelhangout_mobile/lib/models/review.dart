import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart'; 
@JsonSerializable()
class Review {
  final int reviewId;
  final int rating;
  final String? comment;
  final String? username;
  final DateTime? reviewDate;

  Review({
    required this.reviewId,
    required this.rating,
    this.comment,
    this.username,
    this.reviewDate,
  });

   factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}