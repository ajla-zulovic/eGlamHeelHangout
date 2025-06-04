// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productsize.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductSize _$ProductSizeFromJson(Map<String, dynamic> json) => ProductSize(
  productSizeId: (json['productSizeId'] as num?)?.toInt(),
  size: (json['size'] as num).toInt(),
  stockQuantity: (json['stockQuantity'] as num).toInt(),
);

Map<String, dynamic> _$ProductSizeToJson(ProductSize instance) =>
    <String, dynamic>{
      'productSizeId': instance.productSizeId,
      'size': instance.size,
      'stockQuantity': instance.stockQuantity,
    };
