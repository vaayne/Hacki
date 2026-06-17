import 'package:flutter/material.dart';
import 'package:hacki/config/locator.dart';
import 'package:hacki/l10n/app_localizations.dart';
import 'package:hacki/repositories/repositories.dart';
import 'package:hacki/styles/styles.dart';

/// Inline editors for the translation endpoint credentials. Values are read
/// from and written straight to [PreferenceRepository]; the API key lives in
/// secure storage, the rest in shared preferences.
class TranslationSettings extends StatefulWidget {
  const TranslationSettings({super.key});

  @override
  State<TranslationSettings> createState() => _TranslationSettingsState();
}

class _TranslationSettingsState extends State<TranslationSettings> {
  final PreferenceRepository _repository = locator
      .get<PreferenceRepository>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? apiKey = await _repository.translationApiKey;
    final String baseUrl = await _repository.translationBaseUrl;
    final String model = await _repository.translationModel;
    if (!mounted) return;
    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _baseUrlController.text = baseUrl;
      _modelController.text = model;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.pt16,
        Dimens.pt8,
        Dimens.pt16,
        Dimens.pt8,
      ),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsTranslationApiKey,
              hintText: l10n.settingsTranslationApiKeyHint,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureApiKey = !_obscureApiKey),
              ),
            ),
            onChanged: _repository.setTranslationApiKey,
          ),
          SizedBoxes.pt8,
          TextField(
            controller: _baseUrlController,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: l10n.settingsTranslationBaseUrl,
            ),
            onChanged: _repository.setTranslationBaseUrl,
          ),
          SizedBoxes.pt8,
          TextField(
            controller: _modelController,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settingsTranslationModel,
            ),
            onChanged: _repository.setTranslationModel,
          ),
        ],
      ),
    );
  }
}
