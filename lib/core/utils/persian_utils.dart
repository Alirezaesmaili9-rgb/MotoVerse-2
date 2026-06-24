/// Helpers for Persian (Farsi) digits & currency formatting.
/// MotoVerse is RTL and Persian-first.
class PersianUtils {
  const PersianUtils._();

  static const _en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  /// Converts Latin digits in [input] to Persian digits.
  static String toFa(String input) {
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(_en[i], _fa[i]);
    }
    return out;
  }

  /// Converts Persian digits in [input] back to Latin (for parsing).
  static String toEn(String input) {
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(_fa[i], _en[i]);
    }
    return out;
  }

  /// Groups thousands with a separator, then converts to Persian digits.
  static String formatNumber(num value) {
    final str = value.round().toString();
    final buf = StringBuffer();
    final digits = str.replaceAll('-', '');
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final grouped = '${value < 0 ? '-' : ''}$buf';
    return toFa(grouped);
  }

  /// Formats a Toman amount, e.g. `۱۸۵,۰۰۰ تومان`.
  static String formatToman(num value) => '${formatNumber(value)} تومان';

  /// Formats kilometres, e.g. `۱۲,۵۰۰ کیلومتر`.
  static String formatKm(num value) => '${formatNumber(value)} کیلومتر';
}
