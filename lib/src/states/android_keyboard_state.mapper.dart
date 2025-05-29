// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'android_keyboard_state.dart';

class AndroidKeyboardVisibilityStateMapper
    extends ClassMapperBase<AndroidKeyboardVisibilityState> {
  AndroidKeyboardVisibilityStateMapper._();

  static AndroidKeyboardVisibilityStateMapper? _instance;
  static AndroidKeyboardVisibilityStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardVisibilityStateMapper._());
      KeyboardVisibilityStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardVisibilityState';

  static KeyboardVisibilityStatus _$status(AndroidKeyboardVisibilityState v) =>
      v.status;
  static const Field<AndroidKeyboardVisibilityState, KeyboardVisibilityStatus>
      _f$status = Field('status', _$status);
  static int _$bottomInsetDevicePixels(AndroidKeyboardVisibilityState v) =>
      v.bottomInsetDevicePixels;
  static const Field<AndroidKeyboardVisibilityState, int>
      _f$bottomInsetDevicePixels =
      Field('bottomInsetDevicePixels', _$bottomInsetDevicePixels);

  @override
  final MappableFields<AndroidKeyboardVisibilityState> fields = const {
    #status: _f$status,
    #bottomInsetDevicePixels: _f$bottomInsetDevicePixels,
  };

  static AndroidKeyboardVisibilityState _instantiate(DecodingData data) {
    return AndroidKeyboardVisibilityState(
        status: data.dec(_f$status),
        bottomInsetDevicePixels: data.dec(_f$bottomInsetDevicePixels));
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardVisibilityStateMappable {
  AndroidKeyboardVisibilityStateCopyWith<AndroidKeyboardVisibilityState,
          AndroidKeyboardVisibilityState, AndroidKeyboardVisibilityState>
      get copyWith => _AndroidKeyboardVisibilityStateCopyWithImpl<
              AndroidKeyboardVisibilityState, AndroidKeyboardVisibilityState>(
          this as AndroidKeyboardVisibilityState, $identity, $identity);
  @override
  String toString() {
    return AndroidKeyboardVisibilityStateMapper.ensureInitialized()
        .stringifyValue(this as AndroidKeyboardVisibilityState);
  }

  @override
  bool operator ==(Object other) {
    return AndroidKeyboardVisibilityStateMapper.ensureInitialized()
        .equalsValue(this as AndroidKeyboardVisibilityState, other);
  }

  @override
  int get hashCode {
    return AndroidKeyboardVisibilityStateMapper.ensureInitialized()
        .hashValue(this as AndroidKeyboardVisibilityState);
  }
}

extension AndroidKeyboardVisibilityStateValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AndroidKeyboardVisibilityState, $Out> {
  AndroidKeyboardVisibilityStateCopyWith<$R, AndroidKeyboardVisibilityState,
          $Out>
      get $asAndroidKeyboardVisibilityState => $base.as((v, t, t2) =>
          _AndroidKeyboardVisibilityStateCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AndroidKeyboardVisibilityStateCopyWith<
    $R,
    $In extends AndroidKeyboardVisibilityState,
    $Out> implements KeyboardVisibilityStateCopyWith<$R, $In, $Out> {
  @override
  $R call({KeyboardVisibilityStatus? status, int? bottomInsetDevicePixels});
  AndroidKeyboardVisibilityStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AndroidKeyboardVisibilityStateCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AndroidKeyboardVisibilityState, $Out>
    implements
        AndroidKeyboardVisibilityStateCopyWith<$R,
            AndroidKeyboardVisibilityState, $Out> {
  _AndroidKeyboardVisibilityStateCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AndroidKeyboardVisibilityState> $mapper =
      AndroidKeyboardVisibilityStateMapper.ensureInitialized();
  @override
  $R call({KeyboardVisibilityStatus? status, int? bottomInsetDevicePixels}) =>
      $apply(FieldCopyWithData({
        if (status != null) #status: status,
        if (bottomInsetDevicePixels != null)
          #bottomInsetDevicePixels: bottomInsetDevicePixels
      }));
  @override
  AndroidKeyboardVisibilityState $make(CopyWithData data) =>
      AndroidKeyboardVisibilityState(
          status: data.get(#status, or: $value.status),
          bottomInsetDevicePixels: data.get(#bottomInsetDevicePixels,
              or: $value.bottomInsetDevicePixels));

  @override
  AndroidKeyboardVisibilityStateCopyWith<$R2, AndroidKeyboardVisibilityState,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AndroidKeyboardVisibilityStateCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AndroidKeyboardAnimationStateMapper
    extends ClassMapperBase<AndroidKeyboardAnimationState> {
  AndroidKeyboardAnimationStateMapper._();

  static AndroidKeyboardAnimationStateMapper? _instance;
  static AndroidKeyboardAnimationStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardAnimationStateMapper._());
      AndroidKeyboardAnimationStatePrepareMapper.ensureInitialized();
      AndroidKeyboardAnimationStateStartMapper.ensureInitialized();
      AndroidKeyboardAnimationStateProgressMapper.ensureInitialized();
      AndroidKeyboardAnimationStateEndMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardAnimationState';

  @override
  final MappableFields<AndroidKeyboardAnimationState> fields = const {};

  static AndroidKeyboardAnimationState _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('AndroidKeyboardAnimationState');
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardAnimationStateMappable {
  AndroidKeyboardAnimationStateCopyWith<
      AndroidKeyboardAnimationState,
      AndroidKeyboardAnimationState,
      AndroidKeyboardAnimationState> get copyWith;
}

abstract class AndroidKeyboardAnimationStateCopyWith<
    $R,
    $In extends AndroidKeyboardAnimationState,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  AndroidKeyboardAnimationStateCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class AndroidKeyboardAnimationStatePrepareMapper
    extends ClassMapperBase<AndroidKeyboardAnimationStatePrepare> {
  AndroidKeyboardAnimationStatePrepareMapper._();

  static AndroidKeyboardAnimationStatePrepareMapper? _instance;
  static AndroidKeyboardAnimationStatePrepareMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardAnimationStatePrepareMapper._());
      AndroidKeyboardAnimationStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardAnimationStatePrepare';

  @override
  final MappableFields<AndroidKeyboardAnimationStatePrepare> fields = const {};

  static AndroidKeyboardAnimationStatePrepare _instantiate(DecodingData data) {
    return AndroidKeyboardAnimationStatePrepare();
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardAnimationStatePrepareMappable {
  AndroidKeyboardAnimationStatePrepareCopyWith<
          AndroidKeyboardAnimationStatePrepare,
          AndroidKeyboardAnimationStatePrepare,
          AndroidKeyboardAnimationStatePrepare>
      get copyWith => _AndroidKeyboardAnimationStatePrepareCopyWithImpl<
              AndroidKeyboardAnimationStatePrepare,
              AndroidKeyboardAnimationStatePrepare>(
          this as AndroidKeyboardAnimationStatePrepare, $identity, $identity);
  @override
  String toString() {
    return AndroidKeyboardAnimationStatePrepareMapper.ensureInitialized()
        .stringifyValue(this as AndroidKeyboardAnimationStatePrepare);
  }

  @override
  bool operator ==(Object other) {
    return AndroidKeyboardAnimationStatePrepareMapper.ensureInitialized()
        .equalsValue(this as AndroidKeyboardAnimationStatePrepare, other);
  }

  @override
  int get hashCode {
    return AndroidKeyboardAnimationStatePrepareMapper.ensureInitialized()
        .hashValue(this as AndroidKeyboardAnimationStatePrepare);
  }
}

extension AndroidKeyboardAnimationStatePrepareValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AndroidKeyboardAnimationStatePrepare, $Out> {
  AndroidKeyboardAnimationStatePrepareCopyWith<
      $R,
      AndroidKeyboardAnimationStatePrepare,
      $Out> get $asAndroidKeyboardAnimationStatePrepare => $base.as((v, t,
          t2) =>
      _AndroidKeyboardAnimationStatePrepareCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AndroidKeyboardAnimationStatePrepareCopyWith<
    $R,
    $In extends AndroidKeyboardAnimationStatePrepare,
    $Out> implements AndroidKeyboardAnimationStateCopyWith<$R, $In, $Out> {
  @override
  $R call();
  AndroidKeyboardAnimationStatePrepareCopyWith<$R2, $In, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AndroidKeyboardAnimationStatePrepareCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AndroidKeyboardAnimationStatePrepare, $Out>
    implements
        AndroidKeyboardAnimationStatePrepareCopyWith<$R,
            AndroidKeyboardAnimationStatePrepare, $Out> {
  _AndroidKeyboardAnimationStatePrepareCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AndroidKeyboardAnimationStatePrepare> $mapper =
      AndroidKeyboardAnimationStatePrepareMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AndroidKeyboardAnimationStatePrepare $make(CopyWithData data) =>
      AndroidKeyboardAnimationStatePrepare();

  @override
  AndroidKeyboardAnimationStatePrepareCopyWith<$R2,
      AndroidKeyboardAnimationStatePrepare, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AndroidKeyboardAnimationStatePrepareCopyWithImpl<$R2, $Out2>(
          $value, $cast, t);
}

class AndroidKeyboardAnimationStateStartMapper
    extends ClassMapperBase<AndroidKeyboardAnimationStateStart> {
  AndroidKeyboardAnimationStateStartMapper._();

  static AndroidKeyboardAnimationStateStartMapper? _instance;
  static AndroidKeyboardAnimationStateStartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardAnimationStateStartMapper._());
      AndroidKeyboardAnimationStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardAnimationStateStart';

  static int _$lowerBoundDevicePixels(AndroidKeyboardAnimationStateStart v) =>
      v.lowerBoundDevicePixels;
  static const Field<AndroidKeyboardAnimationStateStart, int>
      _f$lowerBoundDevicePixels =
      Field('lowerBoundDevicePixels', _$lowerBoundDevicePixels);
  static int _$upperBoundDevicePixels(AndroidKeyboardAnimationStateStart v) =>
      v.upperBoundDevicePixels;
  static const Field<AndroidKeyboardAnimationStateStart, int>
      _f$upperBoundDevicePixels =
      Field('upperBoundDevicePixels', _$upperBoundDevicePixels);

  @override
  final MappableFields<AndroidKeyboardAnimationStateStart> fields = const {
    #lowerBoundDevicePixels: _f$lowerBoundDevicePixels,
    #upperBoundDevicePixels: _f$upperBoundDevicePixels,
  };

  static AndroidKeyboardAnimationStateStart _instantiate(DecodingData data) {
    return AndroidKeyboardAnimationStateStart(
        lowerBoundDevicePixels: data.dec(_f$lowerBoundDevicePixels),
        upperBoundDevicePixels: data.dec(_f$upperBoundDevicePixels));
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardAnimationStateStartMappable {
  AndroidKeyboardAnimationStateStartCopyWith<
          AndroidKeyboardAnimationStateStart,
          AndroidKeyboardAnimationStateStart,
          AndroidKeyboardAnimationStateStart>
      get copyWith => _AndroidKeyboardAnimationStateStartCopyWithImpl<
              AndroidKeyboardAnimationStateStart,
              AndroidKeyboardAnimationStateStart>(
          this as AndroidKeyboardAnimationStateStart, $identity, $identity);
  @override
  String toString() {
    return AndroidKeyboardAnimationStateStartMapper.ensureInitialized()
        .stringifyValue(this as AndroidKeyboardAnimationStateStart);
  }

  @override
  bool operator ==(Object other) {
    return AndroidKeyboardAnimationStateStartMapper.ensureInitialized()
        .equalsValue(this as AndroidKeyboardAnimationStateStart, other);
  }

  @override
  int get hashCode {
    return AndroidKeyboardAnimationStateStartMapper.ensureInitialized()
        .hashValue(this as AndroidKeyboardAnimationStateStart);
  }
}

extension AndroidKeyboardAnimationStateStartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AndroidKeyboardAnimationStateStart, $Out> {
  AndroidKeyboardAnimationStateStartCopyWith<$R,
          AndroidKeyboardAnimationStateStart, $Out>
      get $asAndroidKeyboardAnimationStateStart => $base.as((v, t, t2) =>
          _AndroidKeyboardAnimationStateStartCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AndroidKeyboardAnimationStateStartCopyWith<
    $R,
    $In extends AndroidKeyboardAnimationStateStart,
    $Out> implements AndroidKeyboardAnimationStateCopyWith<$R, $In, $Out> {
  @override
  $R call({int? lowerBoundDevicePixels, int? upperBoundDevicePixels});
  AndroidKeyboardAnimationStateStartCopyWith<$R2, $In, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AndroidKeyboardAnimationStateStartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AndroidKeyboardAnimationStateStart, $Out>
    implements
        AndroidKeyboardAnimationStateStartCopyWith<$R,
            AndroidKeyboardAnimationStateStart, $Out> {
  _AndroidKeyboardAnimationStateStartCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AndroidKeyboardAnimationStateStart> $mapper =
      AndroidKeyboardAnimationStateStartMapper.ensureInitialized();
  @override
  $R call({int? lowerBoundDevicePixels, int? upperBoundDevicePixels}) =>
      $apply(FieldCopyWithData({
        if (lowerBoundDevicePixels != null)
          #lowerBoundDevicePixels: lowerBoundDevicePixels,
        if (upperBoundDevicePixels != null)
          #upperBoundDevicePixels: upperBoundDevicePixels
      }));
  @override
  AndroidKeyboardAnimationStateStart $make(CopyWithData data) =>
      AndroidKeyboardAnimationStateStart(
          lowerBoundDevicePixels: data.get(#lowerBoundDevicePixels,
              or: $value.lowerBoundDevicePixels),
          upperBoundDevicePixels: data.get(#upperBoundDevicePixels,
              or: $value.upperBoundDevicePixels));

  @override
  AndroidKeyboardAnimationStateStartCopyWith<$R2,
      AndroidKeyboardAnimationStateStart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AndroidKeyboardAnimationStateStartCopyWithImpl<$R2, $Out2>(
          $value, $cast, t);
}

class AndroidKeyboardAnimationStateProgressMapper
    extends ClassMapperBase<AndroidKeyboardAnimationStateProgress> {
  AndroidKeyboardAnimationStateProgressMapper._();

  static AndroidKeyboardAnimationStateProgressMapper? _instance;
  static AndroidKeyboardAnimationStateProgressMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardAnimationStateProgressMapper._());
      AndroidKeyboardAnimationStateMapper.ensureInitialized();
      AndroidKeyboardVisibilityStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardAnimationStateProgress';

  static AndroidKeyboardVisibilityState _$visibilityState(
          AndroidKeyboardAnimationStateProgress v) =>
      v.visibilityState;
  static const Field<AndroidKeyboardAnimationStateProgress,
          AndroidKeyboardVisibilityState> _f$visibilityState =
      Field('visibilityState', _$visibilityState);

  @override
  final MappableFields<AndroidKeyboardAnimationStateProgress> fields = const {
    #visibilityState: _f$visibilityState,
  };

  static AndroidKeyboardAnimationStateProgress _instantiate(DecodingData data) {
    return AndroidKeyboardAnimationStateProgress(
        visibilityState: data.dec(_f$visibilityState));
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardAnimationStateProgressMappable {
  AndroidKeyboardAnimationStateProgressCopyWith<
          AndroidKeyboardAnimationStateProgress,
          AndroidKeyboardAnimationStateProgress,
          AndroidKeyboardAnimationStateProgress>
      get copyWith => _AndroidKeyboardAnimationStateProgressCopyWithImpl<
              AndroidKeyboardAnimationStateProgress,
              AndroidKeyboardAnimationStateProgress>(
          this as AndroidKeyboardAnimationStateProgress, $identity, $identity);
  @override
  String toString() {
    return AndroidKeyboardAnimationStateProgressMapper.ensureInitialized()
        .stringifyValue(this as AndroidKeyboardAnimationStateProgress);
  }

  @override
  bool operator ==(Object other) {
    return AndroidKeyboardAnimationStateProgressMapper.ensureInitialized()
        .equalsValue(this as AndroidKeyboardAnimationStateProgress, other);
  }

  @override
  int get hashCode {
    return AndroidKeyboardAnimationStateProgressMapper.ensureInitialized()
        .hashValue(this as AndroidKeyboardAnimationStateProgress);
  }
}

extension AndroidKeyboardAnimationStateProgressValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AndroidKeyboardAnimationStateProgress, $Out> {
  AndroidKeyboardAnimationStateProgressCopyWith<
      $R,
      AndroidKeyboardAnimationStateProgress,
      $Out> get $asAndroidKeyboardAnimationStateProgress => $base.as((v, t,
          t2) =>
      _AndroidKeyboardAnimationStateProgressCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AndroidKeyboardAnimationStateProgressCopyWith<
    $R,
    $In extends AndroidKeyboardAnimationStateProgress,
    $Out> implements AndroidKeyboardAnimationStateCopyWith<$R, $In, $Out> {
  AndroidKeyboardVisibilityStateCopyWith<$R, AndroidKeyboardVisibilityState,
      AndroidKeyboardVisibilityState> get visibilityState;
  @override
  $R call({AndroidKeyboardVisibilityState? visibilityState});
  AndroidKeyboardAnimationStateProgressCopyWith<$R2, $In, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AndroidKeyboardAnimationStateProgressCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AndroidKeyboardAnimationStateProgress, $Out>
    implements
        AndroidKeyboardAnimationStateProgressCopyWith<$R,
            AndroidKeyboardAnimationStateProgress, $Out> {
  _AndroidKeyboardAnimationStateProgressCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AndroidKeyboardAnimationStateProgress> $mapper =
      AndroidKeyboardAnimationStateProgressMapper.ensureInitialized();
  @override
  AndroidKeyboardVisibilityStateCopyWith<$R, AndroidKeyboardVisibilityState,
          AndroidKeyboardVisibilityState>
      get visibilityState => $value.visibilityState.copyWith
          .$chain((v) => call(visibilityState: v));
  @override
  $R call({AndroidKeyboardVisibilityState? visibilityState}) =>
      $apply(FieldCopyWithData(
          {if (visibilityState != null) #visibilityState: visibilityState}));
  @override
  AndroidKeyboardAnimationStateProgress $make(CopyWithData data) =>
      AndroidKeyboardAnimationStateProgress(
          visibilityState:
              data.get(#visibilityState, or: $value.visibilityState));

  @override
  AndroidKeyboardAnimationStateProgressCopyWith<$R2,
      AndroidKeyboardAnimationStateProgress, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AndroidKeyboardAnimationStateProgressCopyWithImpl<$R2, $Out2>(
          $value, $cast, t);
}

class AndroidKeyboardAnimationStateEndMapper
    extends ClassMapperBase<AndroidKeyboardAnimationStateEnd> {
  AndroidKeyboardAnimationStateEndMapper._();

  static AndroidKeyboardAnimationStateEndMapper? _instance;
  static AndroidKeyboardAnimationStateEndMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = AndroidKeyboardAnimationStateEndMapper._());
      AndroidKeyboardAnimationStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AndroidKeyboardAnimationStateEnd';

  @override
  final MappableFields<AndroidKeyboardAnimationStateEnd> fields = const {};

  static AndroidKeyboardAnimationStateEnd _instantiate(DecodingData data) {
    return AndroidKeyboardAnimationStateEnd();
  }

  @override
  final Function instantiate = _instantiate;
}

mixin AndroidKeyboardAnimationStateEndMappable {
  AndroidKeyboardAnimationStateEndCopyWith<AndroidKeyboardAnimationStateEnd,
          AndroidKeyboardAnimationStateEnd, AndroidKeyboardAnimationStateEnd>
      get copyWith => _AndroidKeyboardAnimationStateEndCopyWithImpl<
              AndroidKeyboardAnimationStateEnd,
              AndroidKeyboardAnimationStateEnd>(
          this as AndroidKeyboardAnimationStateEnd, $identity, $identity);
  @override
  String toString() {
    return AndroidKeyboardAnimationStateEndMapper.ensureInitialized()
        .stringifyValue(this as AndroidKeyboardAnimationStateEnd);
  }

  @override
  bool operator ==(Object other) {
    return AndroidKeyboardAnimationStateEndMapper.ensureInitialized()
        .equalsValue(this as AndroidKeyboardAnimationStateEnd, other);
  }

  @override
  int get hashCode {
    return AndroidKeyboardAnimationStateEndMapper.ensureInitialized()
        .hashValue(this as AndroidKeyboardAnimationStateEnd);
  }
}

extension AndroidKeyboardAnimationStateEndValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AndroidKeyboardAnimationStateEnd, $Out> {
  AndroidKeyboardAnimationStateEndCopyWith<$R, AndroidKeyboardAnimationStateEnd,
          $Out>
      get $asAndroidKeyboardAnimationStateEnd => $base.as((v, t, t2) =>
          _AndroidKeyboardAnimationStateEndCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AndroidKeyboardAnimationStateEndCopyWith<
    $R,
    $In extends AndroidKeyboardAnimationStateEnd,
    $Out> implements AndroidKeyboardAnimationStateCopyWith<$R, $In, $Out> {
  @override
  $R call();
  AndroidKeyboardAnimationStateEndCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AndroidKeyboardAnimationStateEndCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AndroidKeyboardAnimationStateEnd, $Out>
    implements
        AndroidKeyboardAnimationStateEndCopyWith<$R,
            AndroidKeyboardAnimationStateEnd, $Out> {
  _AndroidKeyboardAnimationStateEndCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AndroidKeyboardAnimationStateEnd> $mapper =
      AndroidKeyboardAnimationStateEndMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  AndroidKeyboardAnimationStateEnd $make(CopyWithData data) =>
      AndroidKeyboardAnimationStateEnd();

  @override
  AndroidKeyboardAnimationStateEndCopyWith<$R2,
      AndroidKeyboardAnimationStateEnd, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AndroidKeyboardAnimationStateEndCopyWithImpl<$R2, $Out2>(
          $value, $cast, t);
}
