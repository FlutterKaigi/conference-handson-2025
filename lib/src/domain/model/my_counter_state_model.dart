import '../../fundamental/model/base_objects_model.dart';

/// アプリケーションスコープで共有されるカウンターの状態をカプセル化する状態モデルクラス。
class CountState extends StateObject<int> {
  CountState();

  late int _serialNumber;
  late int? _value;

  @override
  int get serialNumber => _serialNumber;

  @override
  int get value => _value!;

  @override
  void init() {
    _value = 0;
    _serialNumber = 0;
  }

  @override
  void dispose() {
    _value = 0;
    _serialNumber = 0;
  }

  @override
  void update(int value) {
    _value = value;
    _serialNumber++;
  }
}
