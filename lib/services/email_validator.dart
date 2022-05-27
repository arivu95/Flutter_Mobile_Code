import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/intl/messages_all.dart';
import 'package:intl/intl.dart';

class EmailLocalizations {
  static Future<EmailLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? true) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return EmailLocalizations();
    });
  }

  static const LocalizationsDelegate<EmailLocalizations> delegate = _EmailLocalizationsDelegate();

  static EmailLocalizations of(BuildContext context) {
    /*return Localizations.of<EmailLocalizations>(
        context, EmailLocalizations);*/
    return Localizations.of<EmailLocalizations>(
          context,
          EmailLocalizations,
        ) ??
        EmailLocalizations();
  }

  String get requiredErrorText {
    return Intl.message(
      'This field cannot be empty.',
      name: 'requiredErrorText',
      desc: 'Error Text for required validator',
    );
  }

  String equalErrorText<T>(T value) => Intl.message(
        'This field value must be equal to $value.',
        name: 'equalErrorText',
        args: [value!],
        desc: 'Error Text for equal validator',
      );

  String notEqualErrorText<T>(T value) => Intl.message(
        'This field value must not be equal to $value.',
        name: 'notEqualErrorText',
        args: [value!],
        desc: 'Error Text for not-equal validator',
      );

  String minErrorText(num min) => Intl.message(
        'Value must be greater than or equal to $min.',
        name: 'minErrorText',
        args: [min],
        desc: 'Error Text for required field',
      );

  String minLengthErrorText(int minLength) => Intl.message(
        //'Value must have a length greater than or equal to $minLength',
        'Please enter a valid email address',
        name: 'minLengthErrorText',
        args: [minLength],
        desc: 'Error Text for minLength validator',
      );

  String maxErrorText(num max) => Intl.message(
        'Value must be less than or equal to $max',
        name: 'maxErrorText',
        args: [max],
        desc: 'Error Text for max validator',
      );

  String maxLengthErrorText(int maxLength) => Intl.message(
        'Value must have a length less than or equal to $maxLength',
        name: 'maxLengthErrorText',
        args: [maxLength],
        desc: 'Error Text for required field',
      );

  String get emailErrorText => Intl.message(
        'Please enter a valid email address',
        name: 'emailErrorText',
        desc: 'Error Text for email validator',
      );

  String get urlErrorText => Intl.message(
        'This field requires a valid URL address.',
        name: 'urlErrorText',
        desc: 'Error Text for URL validator',
      );

  String get matchErrorText => Intl.message(
        'Value does not match pattern.',
        name: 'matchErrorText',
        desc: 'Error Text for pattern validator',
      );

  String get numericErrorText => Intl.message(
        'Value must be numeric.',
        name: 'numericErrorText',
        desc: 'Error Text for numeric validator',
      );

  String get integerErrorText => Intl.message(
        'Value must be an integer.',
        name: 'integerErrorText',
        desc: 'Error Text for integer validator',
      );

  String get creditCardErrorText => Intl.message(
        'This field requires a valid credit card number.',
        name: 'creditCardErrorText',
        desc: 'Error Text for credit card validator',
      );

  String get ipErrorText => Intl.message(
        'This field requires a valid IP.',
        name: 'ipErrorText',
        desc: 'Error Text for IP address validator',
      );

  String get dateStringErrorText => Intl.message(
        'This field requires a valid date string.',
        name: 'dateStringErrorText',
        desc: 'Error Text for date string validator',
      );
}

class _EmailLocalizationsDelegate extends LocalizationsDelegate<EmailLocalizations> {
  const _EmailLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['de', 'en', 'es', 'fr', 'hu', 'it', 'ja', 'pt', 'sk', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<EmailLocalizations> load(Locale locale) {
    return EmailLocalizations.load(locale);
  }

  @override
  bool shouldReload(_EmailLocalizationsDelegate old) {
    return false;
  }
}

String get emailErrorText => Intl.message(
      'Please enter a valid email address',
      name: 'emailErrorText',
      desc: 'Error Text for email validator',
    );

typedef EmailValidator<T> = String? Function(T? value);

//RegExp _email = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
RegExp _email = RegExp(r"^(?!.*?[_.-]{2})[a-z][A-Za-z0-9_.-]+@[A-Za-z0-9.]+\.[a-zA-Z]+$");
//RegExp _email = RegExp(r"^(?!.*?[_.-]{2})[a-z][A-Za-z0-9_.-]+@[a-zA-Z]+\.[a-zA-Z]+$");
bool isEmail(String str) {
  return _email.hasMatch(str.toLowerCase());
}

/// For creation of [FormFieldValidator]s.
class EmailValidators {
  /// [FormFieldValidator] that is composed of other [FormFieldValidator]s.
  /// Each validator is run against the [FormField] value and if any returns a
  /// non-null result validation fails, otherwise, validation passes
  static EmailValidator<T> compose<T>(List<EmailValidator<T>> validators) {
    return (valueCandidate) {
      for (var validator in validators) {
        final validatorResult = validator.call(valueCandidate);
        if (validatorResult != null) {
          return validatorResult;
        }
      }
      return null;
    };
  }

  /// [FormFieldValidator] that requires the field's value to be a valid email address.
  static EmailValidator<String> email(
    BuildContext context, {
    String? errorText,
  }) =>
      (valueCandidate) => true == valueCandidate?.isNotEmpty && !isEmail(valueCandidate!.trim()) ? errorText ?? EmailLocalizations.of(context).emailErrorText : null;
}
