// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  reviewId: (json['reviewId'] as num).toInt(),
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String?,
  username: json['username'] as String?,
  reviewDate:
      json['reviewDate'] == null
          ? null
          : DateTime.parse(json['reviewDate'] as String),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'reviewId': instance.reviewId,
  'rating': instance.rating,
  'comment': instance.comment,
  'username': instance.username,
  'reviewDate': instance.reviewDate?.toIso8601String(),
};
