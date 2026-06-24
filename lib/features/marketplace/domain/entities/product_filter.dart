import 'package:equatable/equatable.dart';

import 'product.dart';

enum ProductSort {
  newest('جدیدترین'),
  priceAsc('ارزان‌ترین'),
  priceDesc('گران‌ترین'),
  topRated('پرامتیازترین');

  const ProductSort(this.label);
  final String label;
}

/// Immutable query/filter state for a product listing.
class ProductFilter extends Equatable {
  const ProductFilter({
    required this.category,
    this.subcategory,
    this.search = '',
    this.sort = ProductSort.newest,
    this.inStockOnly = false,
  });

  final ProductCategory category;
  final String? subcategory;
  final String search;
  final ProductSort sort;
  final bool inStockOnly;

  ProductFilter copyWith({
    ProductCategory? category,
    String? subcategory,
    bool clearSubcategory = false,
    String? search,
    ProductSort? sort,
    bool? inStockOnly,
  }) {
    return ProductFilter(
      category: category ?? this.category,
      subcategory: clearSubcategory ? null : (subcategory ?? this.subcategory),
      search: search ?? this.search,
      sort: sort ?? this.sort,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  @override
  List<Object?> get props => [category, subcategory, search, sort, inStockOnly];
}

/// Curated subcategories per vertical (drive the category chips).
class MarketplaceCategories {
  const MarketplaceCategories._();

  static const Map<ProductCategory, List<({String key, String label})>> map = {
    ProductCategory.parts: [
      (key: 'oil', label: 'روغن'),
      (key: 'filters', label: 'فیلتر'),
      (key: 'ignition', label: 'برق و شمع'),
      (key: 'engine', label: 'موتور'),
      (key: 'brakes', label: 'ترمز'),
      (key: 'tires', label: 'لاستیک'),
    ],
    ProductCategory.accessories: [
      (key: 'helmet', label: 'کلاه'),
      (key: 'gloves', label: 'دستکش'),
      (key: 'luggage', label: 'کیف و باکس'),
      (key: 'mounts', label: 'هولدر'),
      (key: 'lighting', label: 'روشنایی'),
      (key: 'security', label: 'ضد سرقت'),
    ],
  };
}
