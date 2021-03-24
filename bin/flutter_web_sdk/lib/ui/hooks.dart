// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(dnfield): Remove unused_import ignores when https://github.com/dart-lang/sdk/issues/35164 is resolved.

// @dart = 2.10

part of dart.ui;

@pragma('vm:entry-point')
// ignore: unused_element
void _updateWindowMetrics(
  double devicePixelRatio,
  double width,
  double height,
  double viewPaddingTop,
  double viewPaddingRight,
  double viewPaddingBottom,
  double viewPaddingLeft,
  double viewInsetTop,
  double viewInsetRight,
  double viewInsetBottom,
  double viewInsetLeft,
  double systemGestureInsetTop,
  double systemGestureInsetRight,
  double systemGestureInsetBottom,
  double systemGestureInsetLeft,
) {
  window
    .._devicePixelRatio = devicePixelRatio
    .._physicalSize = Size(width, height)
    .._viewPadding = WindowPadding._(
        top: viewPaddingTop,
        right: viewPaddingRight,
        bottom: viewPaddingBottom,
        left: viewPaddingLeft)
    .._viewInsets = WindowPadding._(
        top: viewInsetTop,
        right: viewInsetRight,
        bottom: viewInsetBottom,
        left: viewInsetLeft)
    .._padding = WindowPadding._(
        top: math.max(0.0, viewPaddingTop - viewInsetTop),
        right: math.max(0.0, viewPaddingRight - viewInsetRight),
        bottom: math.max(0.0, viewPaddingBottom - viewInsetBottom),
        left: math.max(0.0, viewPaddingLeft - viewInsetLeft))
    .._systemGestureInsets = WindowPadding._(
        top: math.max(0.0, systemGestureInsetTop),
        right: math.max(0.0, systemGestureInsetRight),
        bottom: math.max(0.0, systemGestureInsetBottom),
        left: math.max(0.0, systemGestureInsetLeft));
  _invoke(window.onMetricsChanged, window._onMetricsChangedZone);
}

typedef _LocaleClosure = String? Function();

String? _localeClosure() {
  if (window.locale == null) {
    return null;
  }
  return window.locale.toString();
}

@pragma('vm:entry-point')
// ignore: unused_element
_LocaleClosure? _getLocaleClosure() => _localeClosure;

@pragma('vm:entry-point')
// ignore: unused_element
void _updateLocales(List<String> locales) {
  const int stringsPerLocale = 4;
  final int numLocales = locales.length ~/ stringsPerLocale;
  final List<Locale> newLocales = <Locale>[];
  for (int localeIndex = 0; localeIndex < numLocales; localeIndex++) {
    final String countryCode = locales[localeIndex * stringsPerLocale + 1];
    final String scriptCode = locales[localeIndex * stringsPerLocale + 2];

    newLocales.add(Locale.fromSubtags(
      languageCode: locales[localeIndex * stringsPerLocale],
      countryCode: countryCode.isEmpty ? null : countryCode,
      scriptCode: scriptCode.isEmpty ? null : scriptCode,
    ));
  }
  window._locales = newLocales;
  _invoke(window.onLocaleChanged, window._onLocaleChangedZone);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _updateUserSettingsData(String jsonData) {
  final Map<String, dynamic> data = json.decode(jsonData) as Map<String, dynamic>;
  if (data.isEmpty) {
    return;
  }
  _updateTextScaleFactor((data['textScaleFactor'] as num).toDouble());
  _updateAlwaysUse24HourFormat(data['alwaysUse24HourFormat'] as bool);
  _updatePlatformBrightness(data['platformBrightness'] as String);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _updateLifecycleState(String state) {
  // We do not update the state if the state has already been used to initialize
  // the lifecycleState.
  if (!window._initialLifecycleStateAccessed)
    window._initialLifecycleState = state;
}


void _updateTextScaleFactor(double textScaleFactor) {
  window._textScaleFactor = textScaleFactor;
  _invoke(window.onTextScaleFactorChanged, window._onTextScaleFactorChangedZone);
}

void _updateAlwaysUse24HourFormat(bool alwaysUse24HourFormat) {
  window._alwaysUse24HourFormat = alwaysUse24HourFormat;
}

void _updatePlatformBrightness(String brightnessName) {
  window._platformBrightness = brightnessName == 'dark' ? Brightness.dark : Brightness.light;
  _invoke(window.onPlatformBrightnessChanged, window._onPlatformBrightnessChangedZone);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _updateSemanticsEnabled(bool enabled) {
  window._semanticsEnabled = enabled;
  _invoke(window.onSemanticsEnabledChanged, window._onSemanticsEnabledChangedZone);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _updateAccessibilityFeatures(int values) {
  final AccessibilityFeatures newFeatures = AccessibilityFeatures._(values);
  if (newFeatures == window._accessibilityFeatures)
    return;
  window._accessibilityFeatures = newFeatures;
  _invoke(window.onAccessibilityFeaturesChanged, window._onAccessibilityFeaturesChangedZone);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _dispatchPlatformMessage(String name, ByteData? data, int responseId) {
  if (name == ChannelBuffers.kControlChannelName) {
    try {
      channelBuffers.handleMessage(data!);
    } catch (ex) {
      _printDebug('Message to "$name" caused exception $ex');
    } finally {
      window._respondToPlatformMessage(responseId, null);
    }
  } else if (window.onPlatformMessage != null) {
    _invoke3<String, ByteData?, PlatformMessageResponseCallback>(
      window.onPlatformMessage,
      window._onPlatformMessageZone,
      name,
      data,
      (ByteData? responseData) {
        window._respondToPlatformMessage(responseId, responseData);
      },
    );
  } else {
    channelBuffers.push(name, data, (ByteData? responseData) {
      window._respondToPlatformMessage(responseId, responseData);
    });
  }
}

@pragma('vm:entry-point')
// ignore: unused_element
void _dispatchPointerDataPacket(ByteData packet) {
  if (window.onPointerDataPacket != null)
    _invoke1<PointerDataPacket>(window.onPointerDataPacket, window._onPointerDataPacketZone, _unpackPointerDataPacket(packet));
}

@pragma('vm:entry-point')
// ignore: unused_element
void _dispatchSemanticsAction(int id, int action, ByteData? args) {
  _invoke3<int, SemanticsAction, ByteData?>(
    window.onSemanticsAction,
    window._onSemanticsActionZone,
    id,
    SemanticsAction.values[action]!,
    args,
  );
}

@pragma('vm:entry-point')
// ignore: unused_element
void _beginFrame(int microseconds) {
  _invoke1<Duration>(window.onBeginFrame, window._onBeginFrameZone, Duration(microseconds: microseconds));
}

@pragma('vm:entry-point')
// ignore: unused_element
void _reportTimings(List<int> timings) {
  assert(timings.length % FramePhase.values.length == 0);
  final List<FrameTiming> frameTimings = <FrameTiming>[];
  for (int i = 0; i < timings.length; i += FramePhase.values.length) {
    frameTimings.add(FrameTiming._(timings.sublist(i, i + FramePhase.values.length)));
  }
  _invoke1(window.onReportTimings, window._onReportTimingsZone, frameTimings);
}

@pragma('vm:entry-point')
// ignore: unused_element
void _drawFrame() {
  _invoke(window.onDrawFrame, window._onDrawFrameZone);
}

// ignore: always_declare_return_types, prefer_generic_function_type_aliases
typedef _UnaryFunction(Null args);
// ignore: always_declare_return_types, prefer_generic_function_type_aliases
typedef _BinaryFunction(Null args, Null message);

@pragma('vm:entry-point')
// ignore: unused_element
void _runMainZoned(Function startMainIsolateFunction,
                   Function userMainFunction,
                   List<String> args) {
  startMainIsolateFunction((){
    runZonedGuarded<void>(() {
      if (userMainFunction is _BinaryFunction) {
        // This seems to be undocumented but supported by the command line VM.
        // Let's do the same in case old entry-points are ported to Flutter.
        (userMainFunction as dynamic)(args, '');
      } else if (userMainFunction is _UnaryFunction) {
        (userMainFunction as dynamic)(args);
      } else {
        userMainFunction();
      }
    }, (Object error, StackTrace stackTrace) {
      _reportUnhandledException(error.toString(), stackTrace.toString());
    });
  }, null);
}

void _reportUnhandledException(String error, String stackTrace) native 'PlatformConfiguration_reportUnhandledException';

/// Invokes [callback] inside the given [zone].
void _invoke(void callback()?, Zone zone) {
  if (callback == null)
    return;

  assert(zone != null); // ignore: unnecessary_null_comparison

  if (identical(zone, Zone.current)) {
    callback();
  } else {
    zone.runGuarded(callback);
  }
}

/// Invokes [callback] inside the given [zone] passing it [arg].
void _invoke1<A>(void callback(A a)?, Zone zone, A arg) {
  if (callback == null)
    return;

  assert(zone != null); // ignore: unnecessary_null_comparison

  if (identical(zone, Zone.current)) {
    callback(arg);
  } else {
    zone.runUnaryGuarded<A>(callback, arg);
  }
}

/// Invokes [callback] inside the given [zone] passing it [arg1], [arg2], and [arg3].
void _invoke3<A1, A2, A3>(void callback(A1 a1, A2 a2, A3 a3)?, Zone zone, A1 arg1, A2 arg2, A3 arg3) {
  if (callback == null)
    return;

  assert(zone != null); // ignore: unnecessary_null_comparison

  if (identical(zone, Zone.current)) {
    callback(arg1, arg2, arg3);
  } else {
    zone.runGuarded(() {
      callback(arg1, arg2, arg3);
    });
  }
}

// If this value changes, update the encoding code in the following files:
//
//  * pointer_data.cc
//  * pointer.dart
//  * AndroidTouchProcessor.java
const int _kPointerDataFieldCount = 29;

PointerDataPacket _unpackPointerDataPacket(ByteData packet) {
  const int kStride = Int64List.bytesPerElement;
  const int kBytesPerPointerData = _kPointerDataFieldCount * kStride;
  final int length = packet.lengthInBytes ~/ kBytesPerPointerData;
  assert(length * kBytesPerPointerData == packet.lengthInBytes);
  final List<PointerData> data = <PointerData>[];
  for (int i = 0; i < length; ++i) {
    int offset = i * _kPointerDataFieldCount;
    data.add(PointerData(
      embedderId: packet.getInt64(kStride * offset++, _kFakeHostEndian),
      timeStamp: Duration(microseconds: packet.getInt64(kStride * offset++, _kFakeHostEndian)),
      change: PointerChange.values[packet.getInt64(kStride * offset++, _kFakeHostEndian)],
      kind: PointerDeviceKind.values[packet.getInt64(kStride * offset++, _kFakeHostEndian)],
      signalKind: PointerSignalKind.values[packet.getInt64(kStride * offset++, _kFakeHostEndian)],
      device: packet.getInt64(kStride * offset++, _kFakeHostEndian),
      pointerIdentifier: packet.getInt64(kStride * offset++, _kFakeHostEndian),
      physicalX: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      physicalY: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      physicalDeltaX: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      physicalDeltaY: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      buttons: packet.getInt64(kStride * offset++, _kFakeHostEndian),
      obscured: packet.getInt64(kStride * offset++, _kFakeHostEndian) != 0,
      synthesized: packet.getInt64(kStride * offset++, _kFakeHostEndian) != 0,
      pressure: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      pressureMin: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      pressureMax: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      distance: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      distanceMax: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      size: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      radiusMajor: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      radiusMinor: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      radiusMin: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      radiusMax: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      orientation: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      tilt: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      platformData: packet.getInt64(kStride * offset++, _kFakeHostEndian),
      scrollDeltaX: packet.getFloat64(kStride * offset++, _kFakeHostEndian),
      scrollDeltaY: packet.getFloat64(kStride * offset++, _kFakeHostEndian)
    ));
    assert(offset == (i + 1) * _kPointerDataFieldCount);
  }
  return PointerDataPacket(data: data);
}
