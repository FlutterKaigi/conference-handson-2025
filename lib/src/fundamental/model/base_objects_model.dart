// Domainモデルや 状態値モデルや ValueObjectモデル の基盤クラスを定義します。

enum ModelCycle { init, dispose, get }

/// モデル・プロバイダ基底関数
///
/// 指定した オブジェクトや Notifier ⇒ ViewModel からしかモデルにアクセスできないよう制限します。
///
/// [A] スーパーバイザー型、[T] モデル型
///
/// - [approver]: アクセス・モデルオブジェクト（許可先か否かのチェックに利用されます）
/// - [cycle]: モデルサイクル種別（ドメインモデル取得や初期化のチェックに利用されます）
/// - [overrideModel]: オーバライドするモデル・オブジェクト（init時のみ利用されます）
/// - [initModel]: グローバルプロパティにバインドしたモデルの生成＆初期化関数
/// - [disposeModel]: グローバルプロパティにバインドしたモデルの破棄関数
/// - [getModel]: グローバルプロパティにバインドしたモデルの取得関数
/// - [isApproved]: アクセス許可する approver 型をチェックする関数
///
T modelProvider<A, T>(
  Object approver, {
  ModelCycle cycle = ModelCycle.get,
  T? overrideModel,
  T Function()? initModel,
  T Function()? disposeModel,
  T? Function()? getModel,
  bool Function(Object approver)? isApproved,
}) {
  if (approver is! A) {
    if (!(isApproved?.call(approver) ?? false) || cycle != ModelCycle.get) {
      throw ArgumentError('Unauthorized approver.');
    }
  }
  if (cycle != ModelCycle.init && overrideModel != null) {
    throw ArgumentError('Unexpected parameter paring.');
  }

  switch (cycle) {
    case ModelCycle.init:
      {
        // ignore:lines_longer_than_80_chars, always_put_control_body_on_new_line
        if (getModel!() != null) throw ArgumentError('Already initialized..');
        return initModel!();
      }
    case ModelCycle.get:
      {
        // ignore: always_put_control_body_on_new_line
        if (getModel!() == null) throw ArgumentError('Non initialized.');
        return getModel() as T;
      }
    case ModelCycle.dispose:
      {
        // ignore: always_put_control_body_on_new_line
        if (getModel!() == null) throw ArgumentError('Non initialized.');
        return disposeModel!();
      }
  }
}

/// （アプリケーションスコープ) 可変：Applicationオブジェクトの基底クラス
///
/// Application オブジェクトは、アプリケーションのライフサイクルで、
/// Domainモデルオブジェクト・インスタンスの生成および初期化や保持と破棄を管理します。
///
abstract class ApplicationObject {
  ApplicationObject();

  /// 状態生成＆初期化
  ///
  /// _Domainモデル・オブジェクトの生成＆初期化を実装してください。_
  void initState();

  /// 状態破棄
  ///
  /// _Domainモデル・オブジェクトの破棄を実装してください。_
  ///
  /// _**アプリケーション・レベルのライフサイクルハンドリングは、アプリの強制終了に対応できません。**_
  /// _このため状態破棄のための処理が不要な設計をしてください。_
  void disposeState();
}

/// （アプリケーションスコープ) 可変：Domainオブジェクトの基底クラス
///
/// Domain オブジェクトは、
/// 保持した状態モデルオブジェクトと外部との間を仲介することで、
/// その内部状態を特定の状況に保つ責務を持つ **ドメインモデル** です。
///
/// 内部状態を特定の状況に保てるのであれば、派生クラスで任意の入出力関数を追加することができます。
///
/// [S] 状態値型, [T] 状態モデル型
abstract class DomainObject<S, T extends StateObject<S>> {
  DomainObject();

  /// 状態モデルオブジェクト
  T? get stateModel;

  /// 状態生成＆初期化
  ///
  /// _[stateModel] オブジェクトの生成＆初期化を実装してください。_
  void initState();

  /// 状態破棄
  ///
  /// _[stateModel] オブジェクトの破棄を実装してください。_
  void disposeState();
}

/// （アプリケーションスコープ) 可変：状態値オブジェクトの基底クラス
///
/// 状態値オブジェクトは、永続化するデータの整合性を保つ責務を持つ **状態モデル** です。
///
/// 内部状態の整合性を保つため、入出力インターフェースは、[value] と [update] のみに限定しますが、
/// 内部状態の整合性を保てるのであれば、派生クラスで任意の入出力関数を追加することができます。
///
/// - [value] プロパティ：内部状態状況の状態値を外部へ返します。
/// - [update] メソッド：内部状態を変更します。
///
/// [S] 状態値型
abstract class StateObject<S> {
  StateObject();

  /// 状態値更新シリアルナンバー
  int get serialNumber;

  /// 状態値
  S get value;

  /// 状態値オブジェクト生成＆初期化
  ///
  /// _状態値オブジェクトの生成＆初期化処理を実装してください。_
  /// ```dart
  ///   late int _serialNumber;
  ///   late int? _value;
  ///
  ///   @override
  ///   int get serialNumber;
  ///
  ///   @override
  ///   int get value => _value!;
  ///
  ///   @override
  ///   void init() {
  ///     _serialNumber = 0;
  ///     _value = 0;
  ///   }
  /// ```
  void init();

  /// 状態値オブジェクト破棄
  ///
  /// _状態値オブジェクトの破棄処理を実装してください。_
  /// ```dart
  ///   late int _serialNumber;
  ///   late int? _value;
  ///
  ///   @override
  ///   int get serialNumber;
  ///
  ///   @override
  ///   int get value => _value!;
  ///
  ///   @override
  ///   void dispose() {
  ///     _serialNumber = 0;
  ///     _count = null;
  ///   }
  /// ```
  void dispose();

  /// 状態値更新
  ///
  /// _状態値オブジェクトの更新処理を実装してください。_
  /// ```dart
  ///   late int _serialNumber;
  ///   late int? _value;
  ///
  ///   @override
  ///   int get serialNumber;
  ///
  ///   @override
  ///   int get value => _value!;
  ///
  ///   @override
  ///   void update(int value) {
  ///     _value = value;
  ///     _serialNumber++;
  ///   }
  /// ```
  void update(S value);
}

/// （プレゼンテーションスコープ）不変：値オブジェクトの基底クラス
///
///
/// 値オブジェクトは、ドメインモデルや Widget との間で、
/// 状態値を表現したデータの共有に利用する **不変データモデル(VO)** です。
///
/// 派生クラスのデータモデルは、任意の扱いやすいデータ構造にすることができます。
///
/// ```dart
/// import '../domain/model/equatable_utils.dart';
///
/// @immutable
/// class PersonValueObject extends ValueObject<int> {
///   const PersonValueObject({
///     required super.stateType,
///     required this.name,
///     this.nickName,
///   });
///
///   final String name;
///   final String? nickName;
///
///   factory PersonValueObject.fromJson(Map<String, dynamic> json) {
///     return PersonValueObject(
///       stateType: json['stateType'] as Type,
///       name: json['name'] as String,
///       nickName: json['nickName'] as String?,
///     );
///   }
///
///   Map<String, dynamic> toJson() {
///     return <String, dynamic>{
///       'stateType': stateType,
///       'name': name,
///       'nickName': nickName,
///     };
///   }
///
///   PersonValueObject copyWith({
///     Type? stateType,
///     String? name,
///     String? nickName,
///   }) {
///     return PersonValueObject(
///       stateType: stateType ?? this.stateType,
///       name: name ?? this.name,
///       nickName: nickName ?? this.nickName,
///     );
///   }
///
///   @override
///   int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode(props);
///
///   @override
///   bool operator ==(Object other) {
///     return identical(this, other) ||
///         other is PersonValueObject &&
///             runtimeType == other.runtimeType &&
///             equals(props, other.props);
///   }
///
///   @override
///   List<Object> get props => <Object>［
///     name,
///     ?nickName,
///   ］;
/// }
/// ```
abstract class ValueObject {
  const ValueObject({required this.stateType});

  /// 値オブジェクト・ソースの型
  final Type stateType;

  /// プロパティ一覧
  List<Object> get props;
}
