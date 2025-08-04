/*
MIT License

Copyright (c) 2018 Felix Angelov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

/// Returns a `hashCode` for [props].
int mapPropsToHashCode(Iterable<Object?>? props) {
  return _finish(props == null ? 0 : props.fold(0, _combine));
}

const DeepCollectionEquality _equality = DeepCollectionEquality();

/// Determines whether [list1] and [list2] are equal.
bool equals(List<Object?>? list1, List<Object?>? list2) {
  if (identical(list1, list2)) return true;
  if (list1 == null || list2 == null) return false;
  final length = list1.length;
  if (length != list2.length) return false;

  for (var i = 0; i < length; i++) {
    final unit1 = list1[i];
    final unit2 = list2[i];

    if (_isEquatable(unit1) && _isEquatable(unit2)) {
      if (unit1 != unit2) return false;
    } else if (unit1 is Iterable || unit1 is Map) {
      if (!_equality.equals(unit1, unit2)) return false;
    } else if (unit1?.runtimeType != unit2?.runtimeType) {
      return false;
    } else if (unit1 != unit2) {
      return false;
    }
  }
  return true;
}

bool _isEquatable(Object? object) {
  return object is Equatable || object is EquatableMixin;
}

/// Jenkins Hash Functions
/// https://en.wikipedia.org/wiki/Jenkins_hash_function
int _combine(int hash, Object? object) {
  if (object is Map) {
    object.keys
        .sorted((Object? a, Object? b) => a.hashCode - b.hashCode)
        .forEach((Object? key) {
      hash = hash ^ _combine(hash, [key, (object! as Map)[key]]);
    });
    return hash;
  }
  if (object is Set) {
    object = object.sorted((Object? a, Object? b) => a.hashCode - b.hashCode);
  }
  if (object is Iterable) {
    for (final value in object) {
      hash = hash ^ _combine(hash, value);
    }
    return hash ^ object.length;
  }

  hash = 0x1fffffff & (hash + object.hashCode);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

int _finish(int hash) {
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// Returns a string for [props].
String mapPropsToString(Type runtimeType, List<Object?> props) {
  return '$runtimeType(${props.map((prop) => prop.toString()).join(', ')})';
}
*/

// ignore_for_file: always_put_control_body_on_new_line
//
// Above is the original code.
// https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart
//
// Below is the modified code with some excerpts from the original
//
// For study purposes, I copied some function from the equatable package,
// but you can also add the [equatable](https://pub.dev/packages/equatable) package
// to `pubspec.yaml` and make each model an Equatable-derived model class.

/// source: `mapPropsToHashCode`
///
/// - [equatable/lib/src/equatable_utils.dart](https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart#L4-L7)
///
/// ```dart
/// class Person {
///   const Person(this.name);
///
///   final String name;
///   final String? nickname;
///
///   @override
///   int get hashCode => runtimeType.hashCode ^ mapPropsToHashCode(props);
///
///   @override
///   List<Object> get props => [
///     name,
///     ?nickname,
///   ];
/// }
/// ```
@pragma('vm:prefer-inline')
int mapPropsToHashCode(Iterable<Object?>? props) {
  return _finish(props == null ? 0 : props.fold(0, _combine));
}

/// source: `_combine`
///
/// - [equatable/lib/src/equatable_utils.dart](https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart#L39-L63)
/// - [Jenkins Hash Functions](https://en.wikipedia.org/wiki/Jenkins_hash_function)
///
@pragma('vm:prefer-inline')
int _combine(int hashCode, Object? object) {
  int hash = 0x1fffffff & (hashCode + object.hashCode);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

/// source: `_finish`
///
/// - [equatable/lib/src/equatable_utils.dart](https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart#L65-L69)
///
@pragma('vm:prefer-inline')
int _finish(int hashCode) {
  int hash = 0x1fffffff & (hashCode + ((0x03ffffff & hashCode) << 3));
  hash = hash ^ (hash >> 11);
  return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

/// source: `equals`
///
/// - [equatable/lib/src/equatable_utils.dart](https://github.com/felangel/equatable/blob/fc5cf81060b3aab54fc6e641ebdfe998b00a619b/lib/src/equatable_utils.dart#L11-L33)
/// - [equatable/lib/src/equatable_utils.dart](https://github.com/felangel/equatable/blob/49c860437d0d3cfb7c386bfe9b09c8f352b6f25e/lib/src/equatable_utils.dart#L9-L67)
///
/// ```dart
/// class Person {
///   const Person(this.name);
///
///   final String name;
///   final String? nickname;
///
///   @override
///   bool operator ==(Object other) {
///     return identical(this, other) ||
///         other is Person &&
///             runtimeType == other.runtimeType &&
///             equals(props, other.props);
///   }
///
///   @override
///   List<Object> get props => [
///     name,
///     ?nickname,
///   ];
/// }
/// ```
@pragma('vm:prefer-inline')
bool equals(Iterable<Object?>? list1, Iterable<Object?>? list2) {
  if (identical(list1, list2)) return true;
  if (list1 == null || list2 == null) return false;
  final int length = list1.length;
  if (length != list2.length) return false;

  // ignore: always_specify_types
  for (var i = 0; i < length; i++) {
    final Object? unit1 = list1.elementAt(i);
    final Object? unit2 = list2.elementAt(i);

    if (unit1.runtimeType != unit2.runtimeType) return false;
    if (unit1 is Iterable<Object?> && unit2 is Iterable<Object?>) {
      if(unit1 is Set && unit2 is Set) return equals(unit1, unit2);
      if(unit1 is Map && unit2 is Map){
        final bool isOkKeys = equals(
          (unit1 as Map<dynamic, dynamic>).keys,
          (unit2 as Map<dynamic, dynamic>).keys,
        );
        final bool isOkEntries = equals(
          (unit1 as Map<dynamic, dynamic>).entries,
          (unit2 as Map<dynamic, dynamic>).entries,
        );
        return isOkKeys && isOkEntries;
      }
      return equals(unit1, unit2);
    }
    if (unit1 != unit2) return false;
  }
  return true;
}
