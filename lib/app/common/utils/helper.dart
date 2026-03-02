import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helper {
  Map<String, dynamic>? decodeJwt(String token) {
    if (token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    String payload = parts[1];

    String normalizedPayload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');

    try {
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadJson = utf8.decode(payloadBytes);
      return json.decode(payloadJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  List<T> listParser<T>(dynamic response, T Function(Map<String, dynamic>) fromJson) {
    if (response is List) {
      try {
        return response.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error mapping list element (List case): $e');
        throw Exception('Failed to parse list elements: $e');
      }
    }

    if (response is Map<String, dynamic> && response['data'] is List) {
      try {
        final rawList = response['data'] as List;
        return rawList.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error mapping list element (Map case): $e');
        throw Exception('Failed to parse list elements: $e');
      }
    }

    throw Exception('Expected List but got ${response.runtimeType}');
  }

  String encodeQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final queryBuffer = StringBuffer('?');

    void addParam(String prefix, dynamic value) {
      if (value is Map) {
        value.forEach((k, v) {
          addParam('$prefix[$k]', v);
        });
      } else if (value is List) {
        for (int i = 0; i < value.length; i++) {
          addParam('$prefix[$i]', value[i]);
        }
      } else if (value != null && value.toString().isNotEmpty) {
        queryBuffer.write(queryBuffer.length > 1 ? '&' : '');
        queryBuffer.write('${Uri.encodeQueryComponent(prefix)}=${Uri.encodeQueryComponent(value.toString())}');
      }
    }

    params.forEach((key, value) {
      addParam(key, value);
    });

    return queryBuffer.toString();
  }

  String formatDateTimeToID(DateTime? dateTime, {String format = 'dd MMMM yyyy'}) {
    if (dateTime == null) {
      return '';
    }

    try {
      return DateFormat(format, 'id_ID').format(dateTime.toLocal());
    } catch (e) {
      debugPrint('Error formatting DateTime: $e');
      return '';
    }
  }

  String formatToRupiah(num? number, {int decimalDigits = 0, bool includeSymbol = true}) {
    if (number == null) {
      return '';
    }

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: includeSymbol ? 'Rp' : '',
      decimalDigits: decimalDigits,
    );

    return formatter.format(number).trim();
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove semua karakter non-digit
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Convert ke number dan format
    int value = int.parse(digitsOnly);
    String formatted = _formatter.format(value);

    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
