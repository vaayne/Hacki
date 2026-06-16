import 'dart:async';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/config/constants.dart';
import 'package:hacki/config/locator.dart';
import 'package:hacki/config/paths.dart';
import 'package:hacki/config/router.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/repositories/repositories.dart';
import 'package:hacki/screens/home/home_screen.dart';
import 'package:hacki/screens/settings/widgets/widgets.dart';
import 'package:hacki/screens/widgets/widgets.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String routeName = 'settings';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with ItemActionMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text(AppLocalizations.of(context).settingsTitle),
      ),
      body: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with ItemActionMixin, Loggable {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferenceCubit, PreferenceState>(
      builder: (BuildContext context, PreferenceState preferenceState) {
        final AuthState authState = context.watch<AuthBloc>().state;
        final bool isLoggedIn = authState.isLoggedIn;
        return SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: isLoggedIn
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  isLoggedIn
                      ? AppLocalizations.of(context).settingsLogOut
                      : AppLocalizations.of(context).settingsLogIn,
                ),
                subtitle: isLoggedIn
                    ? Text(context.read<AuthBloc>().state.username)
                    : null,
                onTap: () {
                  if (isLoggedIn) {
                    onLogoutTapped();
                  } else {
                    onLoginTapped();
                  }
                },
              ),
              const EnterOfflineModeListTile(),
              const OfflineListTile(),
              const SizedBox(height: Dimens.pt8),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowSpacing: Dimens.pt12,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.pt16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).settingsDefaultFetchMode,
                        ),
                        DropdownMenu<FetchMode>(
                          initialSelection: preferenceState.fetchMode,
                          dropdownMenuEntries: FetchMode.values
                              .map(
                                (FetchMode val) => DropdownMenuEntry<FetchMode>(
                                  value: val,
                                  label: val.description,
                                ),
                              )
                              .toList(),
                          onSelected: (FetchMode? fetchMode) {
                            if (fetchMode != null) {
                              HapticFeedbackUtils.selection();
                              context.read<PreferenceCubit>().update(
                                FetchModePreference(val: fetchMode.index),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimens.pt16,
                      right: Dimens.pt16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(
                            context,
                          ).settingsDefaultCommentsOrder,
                        ),
                        DropdownMenu<CommentsOrder>(
                          initialSelection: preferenceState.order,
                          dropdownMenuEntries: CommentsOrder.values
                              .map(
                                (CommentsOrder val) =>
                                    DropdownMenuEntry<CommentsOrder>(
                                      value: val,
                                      label: val.description,
                                    ),
                              )
                              .toList(),
                          onSelected: (CommentsOrder? order) {
                            if (order != null) {
                              HapticFeedbackUtils.selection();
                              context.read<PreferenceCubit>().update(
                                CommentsOrderPreference(val: order.index),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.pt12),
              OverflowBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowSpacing: Dimens.pt12,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: Dimens.pt16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(
                            context,
                          ).settingsDateTimeDisplayOfComments,
                        ),
                        DropdownMenu<DateDisplayFormat>(
                          initialSelection: preferenceState.displayDateFormat,
                          dropdownMenuEntries: DateDisplayFormat.values
                              .map(
                                (DateDisplayFormat val) =>
                                    DropdownMenuEntry<DateDisplayFormat>(
                                      value: val,
                                      label: val.description,
                                    ),
                              )
                              .toList(),
                          onSelected: (DateDisplayFormat? order) {
                            if (order != null) {
                              HapticFeedbackUtils.selection();
                              context.read<PreferenceCubit>().update(
                                DateFormatPreference(val: order.index),
                              );
                              DateDisplayFormat.clearCache();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Dimens.pt16,
                      right: Dimens.pt16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(AppLocalizations.of(context).settingsDataSource),
                        BlocSelector<StoriesBloc, StoriesState, bool>(
                          selector: (StoriesState state) =>
                              state.statusByType.values.any(
                                (Status status) => status == Status.inProgress,
                              ),
                          builder: (BuildContext context, bool isInProgress) {
                            return DropdownMenu<HackerNewsDataSource>(
                              initialSelection: preferenceState.dataSource,
                              dropdownMenuEntries: HackerNewsDataSource.values
                                  .map(
                                    (HackerNewsDataSource val) =>
                                        DropdownMenuEntry<HackerNewsDataSource>(
                                          value: val,
                                          label: val.description,
                                        ),
                                  )
                                  .toList(),
                              onSelected: (HackerNewsDataSource? source) {
                                if (source != null) {
                                  HapticFeedbackUtils.selection();
                                  context.read<PreferenceCubit>().update(
                                    HackerNewsDataSourcePreference(
                                      val: source.index,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.pt12),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: Dimens.pt16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AppLocalizations.of(context).language),
                      DropdownMenu<AppLanguage>(
                        initialSelection: AppLanguage.values.elementAt(
                          preferenceState.preferences
                              .singleWhereType<LocalePreference>()
                              .val,
                        ),
                        dropdownMenuEntries: AppLanguage.values
                            .map(
                              (AppLanguage val) =>
                                  DropdownMenuEntry<AppLanguage>(
                                    value: val,
                                    label: val.label(context),
                                  ),
                            )
                            .toList(),
                        onSelected: (AppLanguage? language) {
                          if (language != null) {
                            HapticFeedbackUtils.selection();
                            context.read<PreferenceCubit>().update(
                              LocalePreference(val: language.index),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimens.pt12),
              const TabBarSettings(),
              const TextScaleFactorSettings(),
              const Divider(),
              StoryTile(
                shouldShowWebPreview: preferenceState.isRichStoryTileEnabled,
                shouldShowMetadata: preferenceState.isMetadataEnabled,
                shouldShowUrl: preferenceState.isUrlEnabled,
                shouldShowFavicon: preferenceState.isFaviconEnabled,
                shouldShowPreviewImage:
                    preferenceState.isStoryTilePreviewImageEnabled,
                isExpandedTileEnabled: preferenceState.isExpandedTileEnabled,
                isIndexedStoryTileEnabled:
                    preferenceState.isIndexedStoryTileEnabled,
                isImageLeftAligned: preferenceState.isPreviewImageLeftAligned,
                index: 0,
                story: Story.placeholder(),
                onTap: () => LinkUtils.launch(Constants.guidelineLink, context),
              ),
              const Divider(),
              for (final Preference<dynamic> preference
                  in preferenceState.settingsPreferences) ...<Widget>[
                if (preference is DividerPlaceholder)
                  SizedBox(
                    height: Dimens.pt36,
                    child: Flex(
                      mainAxisAlignment: MainAxisAlignment.center,
                      direction: Axis.horizontal,
                      children: <Widget>[
                        SizedBoxes.pt12,
                        const Flexible(child: Divider()),
                        SizedBoxes.pt12,
                        Text(preference.label),
                        SizedBoxes.pt12,
                        const Flexible(child: Divider()),
                        SizedBoxes.pt12,
                      ],
                    ),
                  )
                else if (preference is PreviewImageAlignmentPreference)
                  FadeIn(
                    child: ListTile(
                      enabled: preference.dependencies.satisfy(
                        preferenceState.preferences,
                      ),
                      title: Text(preference.title),
                      trailing: SegmentedButton<bool>(
                        showSelectedIcon: false,
                        segments: <ButtonSegment<bool>>[
                          ButtonSegment<bool>(
                            value: true,
                            label: Text(
                              AppLocalizations.of(context).settingsLeft,
                            ),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text(
                              AppLocalizations.of(context).settingsRight,
                            ),
                          ),
                        ],
                        selected: <bool>{
                          preferenceState.isOn(preference as BooleanPreference),
                        },
                        onSelectionChanged:
                            preference.dependencies.satisfy(
                              preferenceState.preferences,
                            )
                            ? (Set<bool> val) {
                                HapticFeedbackUtils.light();
                                context.read<PreferenceCubit>().update(
                                  preference.copyWith(val: val.single),
                                );
                              }
                            : null,
                      ),
                    ),
                  )
                else
                  SwitchListTile(
                    key: ValueKey<String>(preference.key),
                    title: Text(preference.title),
                    subtitle: preference.subtitle.isNotEmpty
                        ? Text(preference.subtitle)
                        : null,
                    value: preferenceState.isOn(
                      preference as BooleanPreference,
                    ),
                    onChanged:
                        preference.dependencies.satisfy(
                          preferenceState.preferences,
                        )
                        ? (bool val) {
                            HapticFeedbackUtils.light();

                            context.read<PreferenceCubit>().update(
                              preference.copyWith(val: val),
                            );

                            if (preference is MarkReadStoriesModePreference &&
                                val == false) {
                              context.read<StoriesBloc>().add(
                                ClearAllReadStories(),
                              );
                            }
                          }
                        : null,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                if (preference is MarkReadStoriesModePreference) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimens.pt16,
                    ),
                    child: DropdownMenu<StoryMarkingMode>(
                      enabled: preferenceState.isMarkReadStoriesEnabled,
                      label: Text(StoryMarkingModePreference().title),
                      initialSelection: preferenceState.storyMarkingMode,
                      onSelected: (StoryMarkingMode? storyMarkingMode) {
                        if (storyMarkingMode != null) {
                          HapticFeedbackUtils.selection();
                          context.read<PreferenceCubit>().update(
                            StoryMarkingModePreference(
                              val: storyMarkingMode.index,
                            ),
                          );
                        }
                      },
                      dropdownMenuEntries: StoryMarkingMode.values
                          .map(
                            (StoryMarkingMode val) =>
                                DropdownMenuEntry<StoryMarkingMode>(
                                  value: val,
                                  label: val.label,
                                ),
                          )
                          .toList(),
                      inputDecorationTheme: const InputDecorationTheme(
                        disabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Palette.grey),
                        ),
                      ),
                      expandedInsets: EdgeInsets.zero,
                    ),
                  ),
                  SizedBoxes.pt12,
                  const Divider(),
                ],
                if (preference is DividerPreference) const Divider(),
              ],
              ListTile(
                title: Text(AppLocalizations.of(context).settingsAccentColor),
                onTap: showColorPicker,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).settingsFont),
                onTap: showFontSettingDialog,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).settingsTheme),
                onTap: showThemeSettingDialog,
              ),
              const Divider(),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsFilterKeywords,
                ),
                onTap: onFilterKeywordsTapped,
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsExportFavorites,
                ),
                onTap: onExportFavoritesTapped,
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsImportFavorites,
                ),
                onTap: () => onImportFavoritesTapped(context.read<FavCubit>()),
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsClearFavorites,
                ),
                onTap: showClearFavoritesDialog,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).settingsClearCache),
                onTap: showClearCacheDialog,
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsRestoreDefaultSettings,
                ),
                onTap: showRestoreDefaultSettingsDialog,
              ),
              if (preferenceState.isDevModeEnabled) ...<Widget>[
                ListTile(
                  title: Text(AppLocalizations.of(context).settingsLogs),
                  onTap: () {
                    context.go(Paths.logs.landing);
                  },
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context).settingsResetFeatureDiscovery,
                  ),
                  onTap: () {
                    HapticFeedbackUtils.light();
                    locator.get<PreferenceRepository>().resetTourStatus();
                    FeatureDiscovery.clearPreferences(
                      context,
                      DiscoverableFeature.values.map(
                        (DiscoverableFeature f) => f.featureId,
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).settingsResetTips),
                  onTap: () {
                    HapticFeedbackUtils.light();
                    context.read<TipsCubit>().reset();
                  },
                ),
              ],
              const Divider(),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).settingsFeatureRequest,
                ),
                onTap: () => LinkUtils.launch(Constants.githubLink, context),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).settingsRateHacki),
                onTap: () {
                  LinkUtils.launch(
                    Platform.isIOS
                        ? Constants.appStoreLink
                        : Constants.googlePlayLink,
                    context,
                  );
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).settingsAbout),
                subtitle: Text(Constants.magicWord),
                onTap: showAboutHackiDialog,
                onLongPress: () {
                  context.go(HomeScreen.routeName);
                  final DevMode updatedDevMode = DevMode(
                    val: !preferenceState.isDevModeEnabled,
                  );
                  context.read<PreferenceCubit>().update(updatedDevMode);
                  HapticFeedbackUtils.heavy();
                  if (updatedDevMode.val) {
                    showSnackBar(
                      content: AppLocalizations.of(context).settingsDevModeOn,
                    );
                  } else {
                    showSnackBar(
                      content: AppLocalizations.of(context).settingsDevModeOff,
                    );
                  }
                },
              ),
              const SizedBox(height: Dimens.pt200),
            ],
          ),
        );
      },
    );
  }

  void onLogoutTapped() {
    final AuthBloc authBloc = context.read<AuthBloc>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            AppLocalizations.of(
              context,
            ).settingsLogOutConfirmation(authBloc.state.username),
            style: const TextStyle(fontSize: TextDimens.pt16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).settingsCancel),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                context.read<AuthBloc>().add(AuthLogout());
                context.read<HistoryCubit>().reset();
              },
              child: Text(AppLocalizations.of(context).settingsLogOut),
            ),
          ],
        );
      },
    );
  }

  void showHackerNewsThemeError() {
    context
      ..removeSnackBar()
      ..showErrorSnackBar(
        AppLocalizations.of(context).settingsDisableHackerNewsThemeFirst,
      );
  }

  void showFontSettingDialog() {
    if (context.read<PreferenceCubit>().state.isHackerNewsThemeEnabled) {
      showHackerNewsThemeError();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) {
        return BlocBuilder<PreferenceCubit, PreferenceState>(
          buildWhen: (PreferenceState previous, PreferenceState current) =>
              previous.font != current.font,
          builder: (BuildContext context, PreferenceState state) {
            return AlertDialog(
              content: RadioGroup<Font>(
                groupValue: state.font,
                onChanged: (Font? val) {
                  if (val != null) {
                    context.read<PreferenceCubit>().update(
                      FontPreference(val: val.index),
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final Font font in Font.values)
                      RadioListTile<Font>(
                        value: font,
                        title: Text(
                          font.uiLabel,
                          style: TextStyle(fontFamily: font.name),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showThemeSettingDialog() {
    if (context.read<PreferenceCubit>().state.isHackerNewsThemeEnabled) {
      showHackerNewsThemeError();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) {
        final AdaptiveThemeMode themeMode = AdaptiveTheme.of(context).mode;
        return AlertDialog(
          content: RadioGroup<AdaptiveThemeMode>(
            groupValue: themeMode,
            onChanged: updateThemeSetting,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RadioListTile<AdaptiveThemeMode>(
                  value: AdaptiveThemeMode.light,
                  title: Text(AppLocalizations.of(context).settingsLight),
                ),
                RadioListTile<AdaptiveThemeMode>(
                  value: AdaptiveThemeMode.dark,
                  title: Text(AppLocalizations.of(context).settingsDark),
                ),
                RadioListTile<AdaptiveThemeMode>(
                  value: AdaptiveThemeMode.system,
                  title: Text(AppLocalizations.of(context).settingsSystem),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateThemeSetting(AdaptiveThemeMode? val) {
    switch (val) {
      case AdaptiveThemeMode.light:
        AdaptiveTheme.of(context).setLight();
      case AdaptiveThemeMode.dark:
        AdaptiveTheme.of(context).setDark();
      case AdaptiveThemeMode.system:
      case null:
        AdaptiveTheme.of(context).setSystem();
    }

    final Brightness brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    ThemeUtils.updateStatusBarSetting(brightness, val);
  }

  void showColorPicker() {
    if (context.read<PreferenceCubit>().state.isHackerNewsThemeEnabled) {
      showHackerNewsThemeError();
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(Dimens.pt18),
          title: Text(AppColorPreference().title),
          content: MaterialColorPicker(
            colors: materialColors,
            selectedColor: context.read<PreferenceCubit>().state.appColor,
            onMainColorChange: (ColorSwatch<dynamic>? color) {
              ColorUtils.levelToRainbowBorderColors.clear();
              context.read<PreferenceCubit>().update(
                AppColorPreference(
                  val: materialColors.indexOf(color ?? Palette.deepOrange),
                ),
              );
              context.pop();
            },
            onBack: context.pop,
          ),
        );
      },
    );
  }

  void showRestoreDefaultSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.settingsRestoreDefaultSettingsConfirmation),
          content: Text(l10n.settingsRestoreDefaultSettingsDescription),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.settingsCancel),
            ),
            TextButton(
              onPressed: () {
                context.pop();

                context.read<PreferenceCubit>().restoreDefaultSettings();

                HapticFeedbackUtils.success();
                showSnackBar(content: l10n.settingsDefaultSettingsRestored);
              },
              child: Text(
                l10n.settingsYes,
                style: const TextStyle(color: Palette.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showClearCacheDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.settingsClearCacheConfirmation),
          content: Text(l10n.settingsClearCacheDescription),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.settingsCancel),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                locator.get<OfflineRepository>().deleteAll();
                locator.get<HistoryRepository>().clearAllReadStoryIds();
                DefaultCacheManager().emptyCache();
                locator.get<SembastRepository>()
                  ..deleteAllCachedItems()
                  ..deleteCachedComments()
                  ..deleteCachedMetadata()
                  ..deleteCachedMetadata();
                locator.get<CollapseStateCacheRepository>().clear();

                HapticFeedbackUtils.success();
                showSnackBar(
                  content: AppLocalizations.of(context).settingsCacheCleared,
                );
              },
              child: Text(
                AppLocalizations.of(context).settingsYes,
                style: const TextStyle(color: Palette.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAboutHackiDialog() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;

    if (mounted) {
      showAboutDialog(
        context: context,
        applicationName: 'Hacki',
        applicationVersion: 'v$version',
        applicationIcon: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(Dimens.pt12)),
          child: Image.asset(
            Constants.hackiIconPath,
            height: Dimens.pt50,
            width: Dimens.pt50,
          ),
        ),
        children: <Widget>[
          ElevatedButton(
            onPressed: () => LinkUtils.launch(Constants.portfolioLink, context),
            child: Row(
              children: <Widget>[
                const FaIcon(FontAwesomeIcons.addressCard),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsDeveloper),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => LinkUtils.launch(Constants.githubLink, context),
            child: Row(
              children: <Widget>[
                const FaIcon(FontAwesomeIcons.github),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsSourceCode),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => LinkUtils.launch(
              Platform.isIOS
                  ? Constants.appStoreLink
                  : Constants.googlePlayLink,
              context,
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.thumb_up),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsLikeThisApp),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => LinkUtils.launch(Constants.spotifyLink, context),
            child: Row(
              children: <Widget>[
                const Icon(FeatherIcons.music),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsMusicIListenTo),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                LinkUtils.launch(Constants.privacyPolicyLink, context),
            child: Row(
              children: <Widget>[
                const Icon(Icons.privacy_tip_outlined),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsPrivacyPolicy),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onReportIssueTapped,
            child: Row(
              children: <Widget>[
                const Icon(Icons.bug_report_outlined),
                const SizedBox(width: Dimens.pt12),
                Text(AppLocalizations.of(context).settingsReportIssue),
              ],
            ),
          ),
        ],
      );
    }
  }

  Future<void> onReportIssueTapped() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsPadding: const EdgeInsets.all(Dimens.pt16),
          actions: <Widget>[
            ElevatedButton(
              onPressed: onSendEmailTapped,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.email),
                  const SizedBox(width: Dimens.pt12),
                  Text(AppLocalizations.of(context).settingsEmail),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => onGithubTapped(context.rect),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.bug_report_outlined),
                  SizedBox(width: Dimens.pt12),
                  Text('GitHub'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Send an email with log attached.
  Future<void> onSendEmailTapped() async {
    final Directory tempDir = await getTemporaryDirectory();
    final String previousLogPath =
        '${tempDir.path}/${Constants.previousLogFileName}';

    await LogUtils.exportLogs();

    final Email email = Email(
      body:
          '''Please describe how to reproduce the bug or what you have down before the bug occurred:''',
      subject: 'Found a bug in Hacki',
      recipients: <String>[Constants.supportEmail],
      attachmentPaths: <String>[previousLogPath],
    );

    await FlutterEmailSender.send(email);
  }

  /// Open an issue on GitHub.
  Future<void> onGithubTapped(Rect? rect) async {
    try {
      final File originalFile = await LogUtils.exportLogs();
      final XFile file = XFile(originalFile.path);
      final ShareResult result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[file],
          subject: 'hacki_log',
          sharePositionOrigin: rect,
        ),
      );

      if (result.status == ShareResultStatus.success) {
        LinkUtils.launchInExternalBrowser(Constants.githubIssueLink);
      }
    } catch (error, stackTrace) {
      logError(error, stackTrace: stackTrace);
    }
  }

  void onFilterKeywordsTapped() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).settingsFilterKeywords,
            style: const TextStyle(fontSize: TextDimens.pt16),
          ),
          content: BlocBuilder<FilterCubit, FilterState>(
            builder: (BuildContext context, FilterState state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (state.keywords.isEmpty)
                    CenteredText(
                      text: AppLocalizations.of(
                        context,
                      ).settingsFilterKeywordsDescription,
                    ),
                  Wrap(
                    spacing: Dimens.pt4,
                    children: <Widget>[
                      for (final String keyword in state.keywords)
                        ActionChip(
                          avatar: const Icon(
                            Icons.close,
                            size: TextDimens.pt14,
                          ),
                          label: Text(keyword),
                          onPressed: () => context
                              .read<FilterCubit>()
                              .removeKeyword(keyword),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: onAddKeywordTapped,
              child: Text(AppLocalizations.of(context).settingsAddKeyword),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).settingsOkay),
            ),
          ],
        );
      },
    );
  }

  void onAddKeywordTapped() {
    final TextEditingController controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(autofocus: true, controller: controller),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).settingsCancel),
            ),
            TextButton(
              onPressed: () {
                final String keyword = controller.text.trim();
                if (keyword.isEmpty) return;
                context.read<FilterCubit>().addKeyword(keyword.toLowerCase());
                context.pop();
              },
              child: Text(AppLocalizations.of(context).settingsConfirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> onExportFavoritesTapped() async {
    return showModalBottomSheet<ExportDestination>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...ExportDestination.values.map(
                (ExportDestination e) => ListTile(
                  leading: Icon(e.icon),
                  title: Text(e.label),
                  onTap: () => context.pop<ExportDestination>(e),
                ),
              ),
            ],
          ),
        );
      },
    ).then(
      (ExportDestination? destination) => exportFavorites(to: destination),
    );
  }

  Future<void> onImportFavoritesTapped(FavCubit favCubit) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Let the user pick the source QR camera or a plain text file
    final ImportSource? importSource = await showModalBottomSheet<ImportSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(AppLocalizations.of(context).settingsQrCode),
                onTap: () => context.pop(ImportSource.qrCode),
              ),
              ListTile(
                leading: const Icon(Icons.file_open_outlined),
                title: Text(AppLocalizations.of(context).settingsFromFile),
                onTap: () => context.pop(ImportSource.file),
              ),
            ],
          ),
        );
      },
    );

    if (importSource == null) return; // user dismissed

    String? data;

    switch (importSource) {
      case ImportSource.qrCode:
        data = await router.push(Paths.qrCode.scanner) as String?;
      case ImportSource.file:
        final FilePickerResult? result = await FilePicker.pickFiles(
          withData: true,
        );
        if (result == null) return;
        final List<int>? bytes = result.files.first.bytes;
        if (bytes == null) {
          showSnackBar(content: l10n.settingsCouldNotReadFile);
          return;
        }
        data = String.fromCharCodes(bytes).trim();
    }

    // Identical parsing to QR path, one integer ID per line
    final List<int>? ids = data
        ?.split('\n')
        .map(int.tryParse)
        .whereType<int>()
        .toList();
    if (ids == null || ids.isEmpty) return;
    for (final int id in ids) {
      await favCubit.addFav(id);
    }
    showSnackBar(content: l10n.settingsFavoritesImported);
  }

  Future<void> exportFavorites({required ExportDestination? to}) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ExportDestination? destination = to;
    if (destination == null) return;

    final List<int> allFavorites = context.read<FavCubit>().state.favIds;
    if (allFavorites.isEmpty) {
      showSnackBar(content: l10n.settingsNoFavoriteItem);
      return;
    }
    final String allFavoritesStr = allFavorites.join('\n');

    switch (destination) {
      case ExportDestination.qrCode:
        await router.push(Paths.qrCode.viewer, extra: allFavoritesStr);
      case ExportDestination.clipBoard:
        try {
          await Clipboard.setData(
            ClipboardData(text: allFavoritesStr),
          ).whenComplete(HapticFeedbackUtils.selection);
          showSnackBar(content: l10n.settingsFavoritesCopied);
        } catch (error, stackTrace) {
          logError(error, stackTrace: stackTrace);
        }
    }
  }

  void showClearFavoritesDialog() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).settingsRemoveAllFavoritesConfirmation,
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).settingsRemoveAllFavoritesDescription,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context).settingsCancel),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                try {
                  context.read<FavCubit>().removeAll();
                  showSnackBar(
                    content: AppLocalizations.of(
                      context,
                    ).settingsAllFavoritesRemoved,
                  );
                } catch (error, stackTrace) {
                  logError(error, stackTrace: stackTrace);
                }
              },
              child: Text(
                AppLocalizations.of(context).settingsConfirm,
                style: const TextStyle(color: Palette.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  String get logIdentifier => 'Settings';
}
