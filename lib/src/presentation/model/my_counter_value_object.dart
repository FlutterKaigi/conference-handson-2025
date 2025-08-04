import 'package:flutter/foundation.dart';

import '../../fundamental/model/base_objects_model.dart';
import '../../fundamental/model/equatable_utils.dart';

/// プレゼンテーションスコープで UIと ViewModelとで共有される、カウンターの状態値(VO)となるクラス。
@immutable
class CountValueObject extends ValueObject {
  const CountValueObject({
    required super.stateType,
    required this.count,
    bool? isResetting,
  }) : _isResetting = isResetting ?? false;

  factory CountValueObject.fromJson(Map<String, dynamic> json) {
    return CountValueObject(
      stateType: json['stateType'] as Type,
      count: json['count'] as int,
      isResetting: json['isResetting'] as bool,
    );
  }

  final int count;
  final bool _isResetting;

  bool get isResetting => _isResetting;

  // 今後の拡張のために copyWith や fromJson/toJson の追加、
  // および hashCode や == オペレーターのオーバーライドをしています。

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stateType': stateType,
      'count': count,
      'isResetting': isResetting,
    };
  }

  // `hashCode` や `operator ==(Object other)` のオーバライドのため、
  // 実装ロジックの勉強のため equatable パッケージのユーティリティ関数のコピーを利用してます。
  //
  // 手軽に実装したい場合は、equatable パッケージを利用すると良いでしょう。
  // - equatable
  //   https://pub.dev/packages/equatable

  CountValueObject copyWith({Type? stateType, int? count, bool? isLoading}) {
    return CountValueObject(
      stateType: stateType ?? this.stateType,
      count: count ?? this.count,
      isResetting: isLoading ?? isResetting,
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
  List<Object> get props => <Object>[stateType, count, isResetting];
}
