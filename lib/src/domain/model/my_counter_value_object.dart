import 'package:flutter/foundation.dart';

import '../../fundamental/model/base_objects_model.dart';
import '../../fundamental/model/equatable_utils.dart';

/// カウンタ用の不変のカウント値を表す Value Object クラス。
@immutable
class CountValueObject extends ValueObject {
  const CountValueObject({required super.stateType, required this.count});

  factory CountValueObject.fromJson(Map<String, dynamic> json) {
    return CountValueObject(
      stateType: json['stateType'] as Type,
      count: json['count'] as int,
    );
  }

  final int count;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'stateType': stateType, 'count': count};
  }

  CountValueObject copyWith({Type? stateType, int? count}) {
    return CountValueObject(
      stateType: stateType ?? this.stateType,
      count: count ?? this.count,
    );
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode(props);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CountValueObject &&
            runtimeType == other.runtimeType &&
            equals(props, other.props);
  }

  @override
  List<Object> get props => <Object>[count];
}
