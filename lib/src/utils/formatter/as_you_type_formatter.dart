import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:libphonenumber/libphonenumber.dart';

typedef OnInputFormatted<T> = void Function(T value);

class AsYouTypeFormatter extends TextInputFormatter {
  final RegExp separatorChars = RegExp(r'[^\d]+');
  final RegExp allowedChars = RegExp(r'[\d+]');
  final RegExp allowOnlyNumbers = new RegExp(r"[^0-9]");

  final String isoCode;
  final String dialCode;
  final OnInputFormatted<TextEditingValue> onInputFormatted;

  AsYouTypeFormatter(
      {@required this.isoCode,
      @required this.dialCode,
      @required this.onInputFormatted})
      : assert(isoCode != null),
        assert(dialCode != null);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int oldValueLength = oldValue.text.length;
    int newValueLength = newValue.text.length;

    if (newValueLength > 0 && newValueLength > oldValueLength) {
      String newValueText = newValue.text;
      String rawText = newValueText.replaceAll(separatorChars, '');
      String textToParse = dialCode + rawText;

      formatAsYouType(input: textToParse).then(
        (String value) {
          String parsedText =
              value.replaceAll(RegExp('^([\\+?${this.dialCode}\\s?]+)'), '');

          if (separatorChars.hasMatch(parsedText))
            this.onInputFormatted(
              TextEditingValue(
                text: parsedText.replaceAll(allowOnlyNumbers, ""),
                selection: TextSelection(
                    baseOffset: parsedText.length,
                    extentOffset: parsedText.length),
              ),
            );
        },
      );
    }
    return newValue;
  }

  Future<String> formatAsYouType({@required String input}) async {
    try {
      String formattedPhoneNumber = await PhoneNumberUtil.formatAsYouType(
          phoneNumber: input, isoCode: isoCode);
      return formattedPhoneNumber;
    } on Exception {
      return '';
    }
  }
}
