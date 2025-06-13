// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:gallery/themes/material_demo_theme_data.dart';
import 'package:test/test.dart';

void main() {
  test('verify former toggleableActiveColor themes are set', () async {
    const Color primaryColor = Color(0xFF6200EE);
    final ThemeData themeData = MaterialDemoThemeData.themeData;

    expect(
      themeData.checkboxTheme.fillColor!.resolve({WidgetState.selected}),
      primaryColor,
    );
    expect(
      themeData.radioTheme.fillColor!.resolve({WidgetState.selected}),
      primaryColor,
    );
    expect(
      themeData.switchTheme.thumbColor!.resolve({WidgetState.selected}),
      primaryColor,
    );

    // Use component-wise comparison with tolerance for floating-point precision
    final actualTrackColor =
        themeData.switchTheme.trackColor!.resolve({WidgetState.selected});
    final expectedTrackColor = primaryColor.withValues(alpha: 0.502);

    expect(actualTrackColor!.r, closeTo(expectedTrackColor!.r, 0.001));
    expect(actualTrackColor.g, closeTo(expectedTrackColor.g, 0.001));
    expect(actualTrackColor.b, closeTo(expectedTrackColor.b, 0.001));
    expect(actualTrackColor.a, closeTo(expectedTrackColor.a, 0.001));
  });
}
