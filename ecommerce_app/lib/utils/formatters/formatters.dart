import 'package:intl/intl.dart';

abstract final class CFormatters {
  // ---------- Currency (NGN) ----------
  static final _naira = NumberFormat.currency(
    locale: 'en',
    symbol: '₦',
    decimalDigits: 2,
  );
  static final _nairaNoDecimals = NumberFormat.currency(
    locale: 'en',
    symbol: '₦',
    decimalDigits: 0,
  );
  static final _nairaCompact = NumberFormat.compactCurrency(
    locale: 'en',
    symbol: '₦',
  );
  static final _number = NumberFormat.decimalPattern('en');

  /// ₦1,250,000.00
  static String naira(num amount) => _naira.format(amount);

  /// ₦1,250,000
  static String nairaWhole(num amount) => _nairaNoDecimals.format(amount);

  /// ₦1.3M, ₦450K
  static String nairaCompact(num amount) => _nairaCompact.format(amount);

  /// 1,250,000 (no symbol, e.g. for input fields)
  static String number(num value) => _number.format(value);

  /// "₦1,250,000.00" or "1,250,000" -> 1250000.0
  static double? parseNaira(String input) =>
      double.tryParse(input.replaceAll(RegExp(r'[^0-9.]'), ''));

  /// 12.5%
  static String percent(num value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  // ---------- Dates ----------
  /// 03 Oct 2026
  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  /// 03/10/2026 (Nigerian day-first order)
  static String dateShort(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  /// Saturday, 3 October 2026
  static String dateLong(DateTime d) =>
      DateFormat('EEEE, d MMMM yyyy').format(d);

  /// 3:45 PM
  static String time(DateTime d) => DateFormat('h:mm a').format(d);

  /// 03 Oct 2026, 3:45 PM
  static String dateTime(DateTime d) =>
      DateFormat('dd MMM yyyy, h:mm a').format(d);

  /// 2026-10-03 (for APIs / databases)
  static String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// just now, 5 min ago, 3 hrs ago, yesterday, 03 Oct 2026
  static String timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return date(d);
  }

  // ---------- Phone (Nigeria) ----------
  /// Strips everything to the 10-digit national number: 8031234567
  /// Accepts 08031234567, +2348031234567, 2348031234567, 0803 123 4567
  static String? _national(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits.length == 10 ? digits : null;
  }

  /// Valid NG mobile: 10 national digits starting with 7, 8 or 9
  static bool isValidPhone(String phone) {
    final n = _national(phone);
    return n != null && RegExp(r'^[789]').hasMatch(n);
  }

  /// 0803 123 4567
  static String phoneLocal(String phone) {
    final n = _national(phone);
    if (n == null) return phone;
    return '0${n.substring(0, 3)} ${n.substring(3, 6)} ${n.substring(6)}';
  }

  /// +234 803 123 4567
  static String phoneInternational(String phone) {
    final n = _national(phone);
    if (n == null) return phone;
    return '+234 ${n.substring(0, 3)} ${n.substring(3, 6)} ${n.substring(6)}';
  }

  /// +2348031234567 (no spaces, for APIs, SMS gateways, WhatsApp links)
  static String phoneE164(String phone) {
    final n = _national(phone);
    return n == null ? phone : '+234$n';
  }

  // ---------- Misc ----------
  /// 1st, 2nd, 3rd, 4th, 11th, 22nd
  static String ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }

  /// Masks an account number: ******7890
  static String maskAccount(String acct) => acct.length <= 4
      ? acct
      : '${'*' * (acct.length - 4)}${acct.substring(acct.length - 4)}';
}
