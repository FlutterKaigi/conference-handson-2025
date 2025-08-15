import '../../fundamental/model/base_objects_model.dart';
import 'my_counter_value_object.dart';

/// アプリケーションスコープで共有されるカウンターの状態をカプセル化する状態モデルクラス。
class CountState extends StateObject<CountValueObject> {
  CountState();

  late int _serialNumber;
  late CountValueObject? _valueObject;

  @override
  int get serialNumber => _serialNumber;

  @override
  CountValueObject get valueObject => _valueObject!;

  int get count => _valueObject!.count;

  @override
  void init() {
    _valueObject = const CountValueObject(stateType: int, count: 0);
    _serialNumber = 0;
  }

  @override
  void dispose() {
    _valueObject = null;
    _serialNumber = 0;
  }

  @override
  void update(CountValueObject value) {
    _valueObject = value;
    _serialNumber++;
  }
}
