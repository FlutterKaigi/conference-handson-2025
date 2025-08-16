import 'package:flutter/foundation.dart';

import '../../fundamental/model/base_objects_model.dart';
import '../../fundamental/model/equatable_utils.dart';
import 'reading_book_value_object.dart';

/// 読書中書籍一覧の状態値(VO)を表す Value Object 不変クラス。
@immutable
class ReadingBooksValueObject extends ValueObject {
  const ReadingBooksValueObject({
    required super.stateType,
    required this.readingBooks,
  });

  factory ReadingBooksValueObject.fromJson(Map<String, dynamic> json) {
    return ReadingBooksValueObject(
      stateType: json['stateType'] as Type,
      readingBooks: json['readingBooks'] as List<ReadingBookValueObject>,
    );
  }

  /// 読書中書籍一覧
  final List<ReadingBookValueObject> readingBooks;

  // 今後の拡張のために copyWith や fromJson/toJson の追加、
  // および hashCode や == オペレーターのオーバーライドをしています。

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stateType': stateType,
      'readingBooks': readingBooks,
    };
  }

  // `hashCode` や `operator ==(Object other)` のオーバライドのため、
  // 実装ロジックの勉強のため equatable パッケージのユーティリティ関数のコピーを利用してます。
  //
  // 手軽に実装したい場合は、equatable パッケージを利用すると良いでしょう。
  // - equatable
  //   https://pub.dev/packages/equatable

  ReadingBooksValueObject copyWith({
    Type? stateType,
    List<ReadingBookValueObject>? readingBooks,
  }) {
    return ReadingBooksValueObject(
      stateType: stateType ?? this.stateType,
      readingBooks: readingBooks ?? this.readingBooks,
    );
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode(props);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReadingBooksValueObject &&
            runtimeType == other.runtimeType &&
            equals(props, other.props);
  }

  @override
  List<Object> get props => <Object>[stateType, readingBooks];
}
