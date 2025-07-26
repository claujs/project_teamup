import 'package:freezed_annotation/freezed_annotation.dart';

part 'advanced_filter.freezed.dart';
part 'advanced_filter.g.dart';

@freezed
class AdvancedFilter with _$AdvancedFilter {
  const factory AdvancedFilter({
    String? name,
    String? email,
    String? department,
    String? position,
  }) = _AdvancedFilter;

  factory AdvancedFilter.fromJson(Map<String, dynamic> json) =>
      _$AdvancedFilterFromJson(json);
}

extension AdvancedFilterX on AdvancedFilter {
  bool get isEmpty =>
      (name?.trim().isEmpty ?? true) &&
      (email?.trim().isEmpty ?? true) &&
      (department?.trim().isEmpty ?? true) &&
      (position?.trim().isEmpty ?? true);

  bool get isSimpleNameFilter =>
      (name?.trim().isNotEmpty ?? false) &&
      (email?.trim().isEmpty ?? true) &&
      (department?.trim().isEmpty ?? true) &&
      (position?.trim().isEmpty ?? true);
}
