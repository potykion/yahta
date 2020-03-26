// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named

part of 'view_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

class _$HabitMarkFrequencyTearOff {
  const _$HabitMarkFrequencyTearOff();

  _HabitMarkFrequency call({DateTime date, int freq}) {
    return _HabitMarkFrequency(
      date: date,
      freq: freq,
    );
  }
}

// ignore: unused_element
const $HabitMarkFrequency = _$HabitMarkFrequencyTearOff();

mixin _$HabitMarkFrequency {
  DateTime get date;
  int get freq;

  $HabitMarkFrequencyCopyWith<HabitMarkFrequency> get copyWith;
}

abstract class $HabitMarkFrequencyCopyWith<$Res> {
  factory $HabitMarkFrequencyCopyWith(
          HabitMarkFrequency value, $Res Function(HabitMarkFrequency) then) =
      _$HabitMarkFrequencyCopyWithImpl<$Res>;
  $Res call({DateTime date, int freq});
}

class _$HabitMarkFrequencyCopyWithImpl<$Res>
    implements $HabitMarkFrequencyCopyWith<$Res> {
  _$HabitMarkFrequencyCopyWithImpl(this._value, this._then);

  final HabitMarkFrequency _value;
  // ignore: unused_field
  final $Res Function(HabitMarkFrequency) _then;

  @override
  $Res call({
    Object date = freezed,
    Object freq = freezed,
  }) {
    return _then(_value.copyWith(
      date: date == freezed ? _value.date : date as DateTime,
      freq: freq == freezed ? _value.freq : freq as int,
    ));
  }
}

abstract class _$HabitMarkFrequencyCopyWith<$Res>
    implements $HabitMarkFrequencyCopyWith<$Res> {
  factory _$HabitMarkFrequencyCopyWith(
          _HabitMarkFrequency value, $Res Function(_HabitMarkFrequency) then) =
      __$HabitMarkFrequencyCopyWithImpl<$Res>;
  @override
  $Res call({DateTime date, int freq});
}

class __$HabitMarkFrequencyCopyWithImpl<$Res>
    extends _$HabitMarkFrequencyCopyWithImpl<$Res>
    implements _$HabitMarkFrequencyCopyWith<$Res> {
  __$HabitMarkFrequencyCopyWithImpl(
      _HabitMarkFrequency _value, $Res Function(_HabitMarkFrequency) _then)
      : super(_value, (v) => _then(v as _HabitMarkFrequency));

  @override
  _HabitMarkFrequency get _value => super._value as _HabitMarkFrequency;

  @override
  $Res call({
    Object date = freezed,
    Object freq = freezed,
  }) {
    return _then(_HabitMarkFrequency(
      date: date == freezed ? _value.date : date as DateTime,
      freq: freq == freezed ? _value.freq : freq as int,
    ));
  }
}

class _$_HabitMarkFrequency implements _HabitMarkFrequency {
  _$_HabitMarkFrequency({this.date, this.freq});

  @override
  final DateTime date;
  @override
  final int freq;

  @override
  String toString() {
    return 'HabitMarkFrequency(date: $date, freq: $freq)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _HabitMarkFrequency &&
            (identical(other.date, date) ||
                const DeepCollectionEquality().equals(other.date, date)) &&
            (identical(other.freq, freq) ||
                const DeepCollectionEquality().equals(other.freq, freq)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(date) ^
      const DeepCollectionEquality().hash(freq);

  @override
  _$HabitMarkFrequencyCopyWith<_HabitMarkFrequency> get copyWith =>
      __$HabitMarkFrequencyCopyWithImpl<_HabitMarkFrequency>(this, _$identity);
}

abstract class _HabitMarkFrequency implements HabitMarkFrequency {
  factory _HabitMarkFrequency({DateTime date, int freq}) =
      _$_HabitMarkFrequency;

  @override
  DateTime get date;
  @override
  int get freq;
  @override
  _$HabitMarkFrequencyCopyWith<_HabitMarkFrequency> get copyWith;
}
