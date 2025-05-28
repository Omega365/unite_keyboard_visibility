// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'keyboard_state.dart';

class KeyboardVisibilityStateMapper
    extends ClassMapperBase<KeyboardVisibilityState> {
  KeyboardVisibilityStateMapper._();

  static KeyboardVisibilityStateMapper? _instance;
  static KeyboardVisibilityStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = KeyboardVisibilityStateMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'KeyboardVisibilityState';

  static KeyboardVisibilityStatus _$status(KeyboardVisibilityState v) =>
      v.status;
  static const Field<KeyboardVisibilityState, KeyboardVisibilityStatus>
      _f$status = Field('status', _$status);

  @override
  final MappableFields<KeyboardVisibilityState> fields = const {
    #status: _f$status,
  };

  static KeyboardVisibilityState _instantiate(DecodingData data) {
    return KeyboardVisibilityState(status: data.dec(_f$status));
  }

  @override
  final Function instantiate = _instantiate;
}

mixin KeyboardVisibilityStateMappable {
  KeyboardVisibilityStateCopyWith<KeyboardVisibilityState,
          KeyboardVisibilityState, KeyboardVisibilityState>
      get copyWith => _KeyboardVisibilityStateCopyWithImpl<
              KeyboardVisibilityState, KeyboardVisibilityState>(
          this as KeyboardVisibilityState, $identity, $identity);
  @override
  String toString() {
    return KeyboardVisibilityStateMapper.ensureInitialized()
        .stringifyValue(this as KeyboardVisibilityState);
  }

  @override
  bool operator ==(Object other) {
    return KeyboardVisibilityStateMapper.ensureInitialized()
        .equalsValue(this as KeyboardVisibilityState, other);
  }

  @override
  int get hashCode {
    return KeyboardVisibilityStateMapper.ensureInitialized()
        .hashValue(this as KeyboardVisibilityState);
  }
}

extension KeyboardVisibilityStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, KeyboardVisibilityState, $Out> {
  KeyboardVisibilityStateCopyWith<$R, KeyboardVisibilityState, $Out>
      get $asKeyboardVisibilityState => $base.as((v, t, t2) =>
          _KeyboardVisibilityStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class KeyboardVisibilityStateCopyWith<
    $R,
    $In extends KeyboardVisibilityState,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({KeyboardVisibilityStatus? status});
  KeyboardVisibilityStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _KeyboardVisibilityStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, KeyboardVisibilityState, $Out>
    implements
        KeyboardVisibilityStateCopyWith<$R, KeyboardVisibilityState, $Out> {
  _KeyboardVisibilityStateCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<KeyboardVisibilityState> $mapper =
      KeyboardVisibilityStateMapper.ensureInitialized();
  @override
  $R call({KeyboardVisibilityStatus? status}) =>
      $apply(FieldCopyWithData({if (status != null) #status: status}));
  @override
  KeyboardVisibilityState $make(CopyWithData data) =>
      KeyboardVisibilityState(status: data.get(#status, or: $value.status));

  @override
  KeyboardVisibilityStateCopyWith<$R2, KeyboardVisibilityState, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _KeyboardVisibilityStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
