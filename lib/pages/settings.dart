// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/layout/adaptive.dart';
import 'package:gallery/pages/about.dart' as about;
import 'package:gallery/pages/home.dart';
import 'package:gallery/pages/settings_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

enum _ExpandableSetting {
  textScale,
  textDirection,
  locale,
  platform,
  theme,
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.animationController,
  });

  final AnimationController animationController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _ExpandableSetting? _expandedSettingId;
  late Animation<double> _staggerSettingsItemsAnimation;

  void onTapSetting(_ExpandableSetting settingId) {
    setState(() {
      if (_expandedSettingId == settingId) {
        _expandedSettingId = null;
      } else {
        _expandedSettingId = settingId;
      }
    });
  }

  void _closeSettingId(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      setState(() {
        _expandedSettingId = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // When closing settings, also shrink expanded setting.
    widget.animationController.addStatusListener(_closeSettingId);

    _staggerSettingsItemsAnimation = CurvedAnimation(
      parent: widget.animationController,
      curve: const Interval(
        0.4,
        1.0,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.animationController.removeStatusListener(_closeSettingId);
  }

  /// Given a [Locale], returns a [DisplayOption] with its native name for a
  /// title and its name in the currently selected locale for a subtitle. If the
  /// native name can't be determined, it is omitted. If the locale can't be
  /// determined, the locale code is used.
  DisplayOption _getLocaleDisplayOption(BuildContext context, Locale? locale) {
    final localeCode = locale.toString();
    final localeName = LocaleNames.of(context)!.nameOf(localeCode);
    if (localeName != null) {
      final localeNativeName =
          LocaleNamesLocalizationsDelegate.nativeLocaleNames[localeCode];
      return localeNativeName != null
          ? DisplayOption(localeNativeName, subtitle: localeName)
          : DisplayOption(localeName);
    } else {
      // gsw, fil, and es_419 aren't in flutter_localized_countries' dataset
      // so we handle them separately
      switch (localeCode) {
        case 'gsw':
          return DisplayOption('Schwiizertüütsch', subtitle: 'Swiss German');
        case 'fil':
          return DisplayOption('Filipino', subtitle: 'Filipino');
        case 'es_419':
          return DisplayOption(
            'español (Latinoamérica)',
            subtitle: 'Spanish (Latin America)',
          );
      }
    }

    return DisplayOption(localeCode);
  }

  /// Create a sorted — by native name – map of supported locales to their
  /// intended display string, with a system option as the first element.
  LinkedHashMap<Locale, DisplayOption> _getLocaleOptions() {
    var localeOptions = LinkedHashMap.of({
      systemLocaleOption: DisplayOption(
        GalleryLocalizations.of(context)!.settingsSystemDefault +
            (deviceLocale != null
                ? ' - ${_getLocaleDisplayOption(context, deviceLocale).title}'
                : ''),
      ),
    });
    var supportedLocales =
        List<Locale>.from(GalleryLocalizations.supportedLocales);
    supportedLocales.removeWhere((locale) => locale == deviceLocale);

    final displayLocales = Map<Locale, DisplayOption>.fromIterable(
      supportedLocales,
      value: (dynamic locale) =>
          _getLocaleDisplayOption(context, locale as Locale?),
    ).entries.toList()
      ..sort((l1, l2) => compareAsciiUpperCase(l1.value.title, l2.value.title));

    localeOptions.addAll(LinkedHashMap.fromEntries(displayLocales));
    return localeOptions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final options = GalleryOptions.of(context);
    final isDesktop = isDisplayDesktop(context);
    final localizations = GalleryLocalizations.of(context)!;

    final settingsListItems = [
      SettingsListItem<double?>(
        title: localizations.settingsTextScaling,
        selectedOption: options.textScaleFactor(
          context,
          useSentinel: true,
        ),
        optionsMap: LinkedHashMap.of({
          systemTextScaleFactorOption: DisplayOption(
            localizations.settingsSystemDefault,
          ),
          0.8: DisplayOption(
            localizations.settingsTextScalingSmall,
          ),
          1.0: DisplayOption(
            localizations.settingsTextScalingNormal,
          ),
          2.0: DisplayOption(
            localizations.settingsTextScalingLarge,
          ),
          3.0: DisplayOption(
            localizations.settingsTextScalingHuge,
          ),
        }),
        onOptionChanged: (newTextScale) => GalleryOptions.update(
          context,
          options.copyWith(textScaleFactor: newTextScale),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.textScale),
        isExpanded: _expandedSettingId == _ExpandableSetting.textScale,
      ),
      SettingsListItem<CustomTextDirection?>(
        title: localizations.settingsTextDirection,
        selectedOption: options.customTextDirection,
        optionsMap: LinkedHashMap.of({
          CustomTextDirection.localeBased: DisplayOption(
            localizations.settingsTextDirectionLocaleBased,
          ),
          CustomTextDirection.ltr: DisplayOption(
            localizations.settingsTextDirectionLTR,
          ),
          CustomTextDirection.rtl: DisplayOption(
            localizations.settingsTextDirectionRTL,
          ),
        }),
        onOptionChanged: (newTextDirection) => GalleryOptions.update(
          context,
          options.copyWith(customTextDirection: newTextDirection),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.textDirection),
        isExpanded: _expandedSettingId == _ExpandableSetting.textDirection,
      ),
      SettingsListItem<Locale?>(
        title: localizations.settingsLocale,
        selectedOption: options.locale == deviceLocale
            ? systemLocaleOption
            : options.locale,
        optionsMap: _getLocaleOptions(),
        onOptionChanged: (newLocale) {
          if (newLocale == systemLocaleOption) {
            newLocale = deviceLocale;
          }
          GalleryOptions.update(
            context,
            options.copyWith(locale: newLocale),
          );
        },
        onTapSetting: () => onTapSetting(_ExpandableSetting.locale),
        isExpanded: _expandedSettingId == _ExpandableSetting.locale,
      ),
      SettingsListItem<TargetPlatform?>(
        title: localizations.settingsPlatformMechanics,
        selectedOption: options.platform,
        optionsMap: LinkedHashMap.of({
          TargetPlatform.android: DisplayOption('Android'),
          TargetPlatform.iOS: DisplayOption('iOS'),
          TargetPlatform.macOS: DisplayOption('macOS'),
          TargetPlatform.linux: DisplayOption('Linux'),
          TargetPlatform.windows: DisplayOption('Windows'),
        }),
        onOptionChanged: (newPlatform) => GalleryOptions.update(
          context,
          options.copyWith(platform: newPlatform),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.platform),
        isExpanded: _expandedSettingId == _ExpandableSetting.platform,
      ),
      SettingsListItem<ThemeMode?>(
        title: localizations.settingsTheme,
        selectedOption: options.themeMode,
        optionsMap: LinkedHashMap.of({
          ThemeMode.system: DisplayOption(
            localizations.settingsSystemDefault,
          ),
          ThemeMode.dark: DisplayOption(
            localizations.settingsDarkTheme,
          ),
          ThemeMode.light: DisplayOption(
            localizations.settingsLightTheme,
          ),
        }),
        onOptionChanged: (newThemeMode) => GalleryOptions.update(
          context,
          options.copyWith(themeMode: newThemeMode),
        ),
        onTapSetting: () => onTapSetting(_ExpandableSetting.theme),
        isExpanded: _expandedSettingId == _ExpandableSetting.theme,
      ),
      ToggleSetting(
        text: GalleryLocalizations.of(context)!.settingsSlowMotion,
        value: options.timeDilation != 1.0,
        onChanged: (isOn) => GalleryOptions.update(
          context,
          options.copyWith(timeDilation: isOn ? 5.0 : 1.0),
        ),
      ),
    ];

    return Material(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: isDesktop
            ? EdgeInsets.zero
            : const EdgeInsets.only(
                bottom: galleryHeaderHeight,
              ),
        // Remove ListView top padding as it is already accounted for.
        child: MediaQuery.removePadding(
          removeTop: isDesktop,
          context: context,
          child: ListView(
            children: [
              if (isDesktop)
                const SizedBox(height: firstHeaderDesktopTopPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ExcludeSemantics(
                  child: Header(
                    color: Theme.of(context).colorScheme.onSurface,
                    text: localizations.settingsTitle,
                  ),
                ),
              ),
              if (isDesktop)
                ...settingsListItems
              else ...[
                _AnimateSettingsListItems(
                  animation: _staggerSettingsItemsAnimation,
                  children: settingsListItems,
                ),
                const SizedBox(height: 16),
                Divider(thickness: 2, height: 0, color: colorScheme.outline),
                const SizedBox(height: 12),
                const SettingsAbout(),
                const SettingsFeedback(),
                const SizedBox(height: 12),
                Divider(thickness: 2, height: 0, color: colorScheme.outline),
                const SettingsAttribution(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsAbout extends StatelessWidget {
  const SettingsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsLink(
      title: GalleryLocalizations.of(context)!.settingsAbout,
      icon: Icons.info_outline,
      onTap: () {
        about.showAboutDialog(context: context);
      },
    );
  }
}

class SettingsFeedback extends StatelessWidget {
  const SettingsFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsLink(
      title: GalleryLocalizations.of(context)!.settingsFeedback,
      icon: Icons.feedback,
      onTap: () async {
        final url =
            Uri.parse('https://github.com/flutter/gallery/issues/new/choose/');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      },
    );
  }
}

class SettingsAttribution extends StatelessWidget {
  const SettingsAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final verticalPadding = isDesktop ? 0.0 : 28.0;
    return MergeSemantics(
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: isDesktop ? 24 : 32,
          end: isDesktop ? 0 : 32,
          top: verticalPadding,
          bottom: verticalPadding,
        ),
        child: SelectableText(
          GalleryLocalizations.of(context)!.settingsAttribution,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
          textAlign: isDesktop ? TextAlign.end : TextAlign.start,
        ),
      ),
    );
  }
}

class _SettingsLink extends StatelessWidget {
  final String title;
  final IconData? icon;
  final GestureTapCallback? onTap;

  const _SettingsLink({
    required this.title,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 32,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.onSecondary.withValues(alpha: 0.5),
              size: 24,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Text(
                  title,
                  style: textTheme.titleSmall!.apply(
                    color: colorScheme.onSecondary,
                  ),
                  textAlign: isDesktop ? TextAlign.end : TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animate the settings list items to stagger in from above.
class _AnimateSettingsListItems extends StatelessWidget {
  const _AnimateSettingsListItems({
    required this.animation,
    required this.children,
  });

  final Animation<double> animation;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const dividingPadding = 4.0;
    final dividerTween = Tween<double>(
      begin: 0,
      end: dividingPadding,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          for (Widget child in children)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: dividerTween.animate(animation).value,
                  ),
                  child: child,
                );
              },
              child: child,
            ),
        ],
      ),
    );
  }
}
