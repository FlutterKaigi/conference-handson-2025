import 'package:flutter/foundation.dart';

import '../../fundamental/model/base_objects_model.dart';
import '../../fundamental/model/equatable_utils.dart';

/// 読書状態
enum ReadingState {
  /// 積読
  unstarted,

  /// 読書中
  reading,

  /// 読書完了
  complete,
}

/// 読書中書籍・読書状況の状態値(VO)を表す Value Object 不変クラス。
@immutable
class ReadingBookValueObject extends ValueObject {
  const ReadingBookValueObject({
    required super.stateType,
    required this.name,
    required this.totalPages,
    this.readingPageNum = 0,
    this.bookReview = '',
  });

  factory ReadingBookValueObject.fromJson(Map<String, dynamic> json) {
    return ReadingBookValueObject(
      // TODO 現状では、読書中書籍のCRUDを担当する編集オブジェクトがないので仮設定する。
      // stateType: json['stateType'] as Type,
      stateType: ReadingBookValueObject,
      name: json['name'] as String,
      totalPages: json['totalPages'] as int,
      readingPageNum: json['readingPageNum'] as int,
      bookReview: json['bookReview'] as String,
    );
  }

  /// 読書中の書籍名
  final String name;

  /// 書籍の総ページ数
  final int totalPages;

  /// 読書中のページ番号（読書完了ページ数）
  final int readingPageNum;

  /// 書籍感想
  final String bookReview;

  /// 読書完了フラグ
  bool get isComplete => readingPageNum == totalPages;

  /// 読書状態
  ReadingState get readingState => isComplete
      ? ReadingState.complete
      : readingPageNum == 0
      ? ReadingState.unstarted
      : ReadingState.reading;

  // 今後の拡張のために copyWith や fromJson/toJson の追加、
  // および hashCode や == オペレーターのオーバーライドをしています。

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stateType': stateType,
      'name': name,
      'totalPages': totalPages,
      'readingPageNum': readingPageNum,
      'bookReview': bookReview,
    };
  }

  // `hashCode` や `operator ==(Object other)` のオーバライドのため、
  // 実装ロジックの勉強のため equatable パッケージのユーティリティ関数のコピーを利用してます。
  //
  // 手軽に実装したい場合は、equatable パッケージを利用すると良いでしょう。
  // - equatable
  //   https://pub.dev/packages/equatable

  ReadingBookValueObject copyWith({
    Type? stateType,
    String? name,
    int? totalPages,
    int? readingPageNum,
    String? bookReview,
  }) {
    return ReadingBookValueObject(
      stateType: stateType ?? this.stateType,
      name: name ?? this.name,
      totalPages: totalPages ?? this.totalPages,
      readingPageNum: readingPageNum ?? this.readingPageNum,
      bookReview: bookReview ?? this.bookReview,
    );
  }

  @override
  int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode(props);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReadingBookValueObject &&
            runtimeType == other.runtimeType &&
            equals(props, other.props);
  }

  @override
  List<Object> get props => <Object>[
    stateType,
    name,
    totalPages,
    readingPageNum,
    bookReview,
  ];
}
