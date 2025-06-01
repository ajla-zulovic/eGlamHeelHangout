// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  (json['categoryId'] as num?)?.toInt(),
  json['categoryName'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'categoryId': instance.categoryID,
  'categoryName': instance.categoryName,
};
