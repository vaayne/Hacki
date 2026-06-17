# i18n 简体中文落地计划（Hacki）

目标：为 App 增加简体中文（zh-CN），用户可在设置里手动切换语言（覆盖系统语言），方案基于 **Flutter 官方 gen-l10n**。

## 现状

- 零 i18n 基础设施：无 `flutter_localizations`、无 `l10n.yaml`、无 `.arb`、`MaterialApp.router` 未挂任何 localization delegate。
- `intl: ^0.20.2` 已在（仅用于日期格式化），`pubspec.yaml` 的 `flutter:` 段已有 `generate: true`。
- 文案全硬编码：29 个文件含 `Text('...')`（131+ 处）；`lib/models/preference.dart` 约 50 条 `title`/`subtitle`；`lib/config/constants.dart` 含 `tips` 与 `SnackBarMessages`；各处 dialog/snackbar。
- 偏好系统（`PreferenceCubit` + `Preference<T>`）只支持 `bool/int/double`，存储走 `PreferenceRepository.getInt/setInt` 等。

## 约束

- **本机无 `flutter`（不在 PATH）**：无法本地跑 `flutter gen-l10n` / `flutter analyze` / build。生成的 `AppLocalizations` 和编译验证需要 V 在自己环境执行。
- 现有偏好 `title`/`subtitle` 是 `const` getter、无 `BuildContext`，无法直接本地化 —— 这是本次最硬的点，见 Step 2。

---

## Step 1 — 双语基础设施 + 语言切换器（可独立提交、可验证）

完成后切到「简体中文」应能立即看到设置页等已迁移区域变中文，验证整条链路打通。

### 1.1 `pubspec.yaml`
在 `dependencies:` 下新增：
```yaml
flutter_localizations:
  sdk: flutter
```
（`generate: true` 已存在，无需改动。）

### 1.2 仓库根目录新增 `l10n.yaml`
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/l10n
output-class: AppLocalizations
nullable-getter: false
```
> Flutter 3.41 已移除 synthetic package，生成物直接落在 `lib/l10n/`，import 路径为
> `package:hacki/l10n/app_localizations.dart`。

### 1.3 新增 ARB 文件
- `lib/l10n/app_en.arb`（模板 / 兜底）：
  ```json
  {
    "@@locale": "en",
    "language": "Language",
    "languageSystem": "System",
    "languageEnglish": "English",
    "languageChinese": "简体中文"
  }
  ```
- `lib/l10n/app_zh.arb`：
  ```json
  {
    "@@locale": "zh",
    "language": "语言",
    "languageSystem": "跟随系统",
    "languageEnglish": "English",
    "languageChinese": "简体中文"
  }
  ```
  （Step 2 持续往两个文件追加 key。）

### 1.4 语言枚举 + `LocalePreference`
在 `lib/models/`（新建 `app_language.dart` 或并入 preference 相关）：
```dart
enum AppLanguage {
  system(null),
  english(Locale('en')),
  chinese(Locale('zh'));

  const AppLanguage(this.locale);
  final Locale? locale;
}
```
在 `lib/models/preference.dart` 新增（复用现有 `IntPreference` 机制，存 enum index）：
```dart
final class LocalePreference extends IntPreference {
  LocalePreference({int? val}) : super(val: val ?? _defaultValue);
  static const int _defaultValue = 0; // AppLanguage.system

  @override
  LocalePreference copyWith({required int? val}) => LocalePreference(val: val);

  @override
  String get key => 'locale';

  @override
  String get title => 'Language';

  // 由设置页的自定义下拉渲染，不进 bool 列表。
  @override
  bool get isDisplayable => false;
}
```
并加入 `Preference.allPreferences` 顶部的 IntPreference 区块。

### 1.5 `PreferenceState` 暴露 locale
```dart
Locale? get locale => AppLanguage.values
    .elementAt(preferences.singleWhereType<LocalePreference>().val)
    .locale; // null = 跟随系统
```

### 1.6 `main.dart` 挂载
- import：
  ```dart
  import 'package:flutter_localizations/flutter_localizations.dart';
  import 'package:hacki/l10n/app_localizations.dart';
  ```
- `MaterialApp.router(...)` 增加：
  ```dart
  locale: state.locale,
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  ```
- 外层 `BlocConsumer<PreferenceCubit>` 的 `buildWhen` 增加：
  ```dart
  previous.locale != current.locale ||
  ```

### 1.7 设置页语言下拉
在 `lib/screens/settings/settings_screen.dart` 现有下拉（fetchMode / order / dateFormat 区域）旁加一个语言下拉，选项来自 `AppLanguage.values`，label 用 `AppLocalizations.of(context)`（`languageSystem/English/Chinese`），onChanged 调
`context.read<PreferenceCubit>().update(LocalePreference(val: index))`。

### 1.8 Step 1 验证（V 执行）
```bash
flutter pub get
flutter gen-l10n      # 或直接 flutter run，build 时自动生成
flutter analyze
flutter run
```
切到「简体中文」→ 设置页语言相关文案变中文即通过。

---

## Step 2 — 全量文案迁移（多智能体 workflow，已授权）

### 2.1 范围
- 29 个文件、131+ 处 `Text('...')` 及其它字面量（button/label/tooltip/dialog）。
- `lib/config/constants.dart`：`tips` 列表、`SnackBarMessages`。
- `lib/models/preference.dart` 约 50 条 `title`/`subtitle`。

### 2.2 偏好标题本地化方案（关键决策）
不逐个改 50 个 `const` 子类（侵入大），改为**集中映射**：新增 `lib/l10n/preference_l10n.dart`，按 `preference.key` 映射到 `AppLocalizations` getter：
```dart
String localizedPreferenceTitle(BuildContext c, Preference<dynamic> p) {
  final l = AppLocalizations.of(c);
  switch (p.key) {
    case 'skipButtonsPreference': return l.prefSkipButtonsTitle;
    // ...
    default: return p.title; // 兜底英文
  }
}
String localizedPreferenceSubtitle(BuildContext c, Preference<dynamic> p) { ... }
```
设置页把 `Text(preference.title)` / `preference.subtitle` 改为调用这两个函数。`DividerPlaceholder.label` 同理走映射。

### 2.3 Workflow 设计（避免文件 / arb 竞争）
agent **不直接并发写 arb**（会 race），而是**返回结构化数据**，主循环确定性合并与落盘：

1. **Discover**：列出全部待迁移文件 + 提取每个字面量 → 生成稳定 `key`（命名约定：`<screen><Purpose>`，如 `settingsRestoreDefault`）。
2. **Per-file（pipeline）**：每个文件一个 agent，返回 `{ filePath, edits: [{old, new}], strings: [{key, en, zh}] }`。`new` 用 `AppLocalizations.of(context).<key>`（无 context 处先标记，单独处理）。
3. **Merge & Apply（主循环）**：去重 key、冲突检测，合并写入 `app_en.arb` / `app_zh.arb`，再对每个文件确定性应用 edits。
4. **Translate review**：对所有 zh 值做一致性/术语校对（HN 术语：story/comment/karma/upvote 等统一）。
5. **Completeness critic**：`grep -rE "Text\(\s*'"` 等扫残留字面量，未尽项进入下一轮。

### 2.4 已知坑
- **无 context 的字符串**（`constants.dart` 的 `tips`/`SnackBarMessages`、cubit 内消息）：要么改成接收 `BuildContext`/`AppLocalizations` 参数，要么在调用点（widget 内）本地化。需逐个判断，workflow 标记后人工/规则处理。
- **带占位符的字符串**（如计数、用户名插值）：用 ARB 的 placeholder 语法（`"{count}"` + `@key.placeholders`），不要字符串拼接。
- **复数**：用 ARB `plural` 语法。
- 迁移后必须 V 本地 `flutter gen-l10n && flutter analyze` 验证无漏 key / 无类型错误。

---

## 提交切分建议
1. `i18n: scaffold gen-l10n and wire localization delegates`（1.1–1.6）
2. `settings: add in-app language switcher`（1.4–1.7 的 UI 部分）
3. Step 2 按文件批次多次提交（workflow 产出后分批 review 落地）
