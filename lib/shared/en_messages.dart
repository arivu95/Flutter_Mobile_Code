/// English Messages
/// [LookupMessages] template for any language
abstract class LookupMessages {
  /// Example: `prefixAgo()` 1 min `suffixAgo()`
  String prefixAgo();

  /// Example: `prefixFromNow()` 1 min `suffixFromNow()`
  String prefixFromNow();

  /// Example: `prefixAgo()` 1 min `suffixAgo()`
  String suffixAgo();

  /// Example: `prefixFromNow()` 1 min `suffixFromNow()`
  String suffixFromNow();

  /// Format when time is less than a minute
  String lessThanOneMinute(int seconds);

  /// Format when time is about a minute
  String aboutAMinute(int minutes);

  /// Format when time is in minutes
  String minutes(int minutes);

  /// Format when time is about an hour
  String aboutAnHour(int minutes);

  /// Format when time is in hours
  String hours(int hours);

  /// Format when time is a day
  String aDay(int hours);

  /// Format when time is in days
  String days(int days);

  /// Format when time is about a month
  String aboutAMonth(int days);

  /// Format when time is in months
  String months(int months);

  /// Format when time is about a year
  String aboutAYear(int year);

  /// Format when time is about a year
  String years(int years);

  /// word separator when words are concatenated
  String wordSeparator() => ' ';
}

class EnMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'ago';
  @override
  String suffixFromNow() => 'from now';
  @override
  String lessThanOneMinute(int seconds) => 'a moment';
  @override
  String aboutAMinute(int minutes) => 'a minute';
  @override
  String minutes(int minutes) => '$minutes minutes';
  @override
  String aboutAnHour(int minutes) => 'about an hour';
  @override
  String hours(int hours) => '$hours hours';
  @override
  String aDay(int hours) => 'a day';
  @override
  String days(int days) => '$days days';
  @override
  String aboutAMonth(int days) => 'about a month';
  @override
  String months(int months) => '$months months';
  @override
  String aboutAYear(int year) => 'about a year';
  @override
  String years(int years) => '$years years';
  @override
  String wordSeparator() => ' ';
}

/// English short Messages
class EnShortMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '~1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '~1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int days) => '~1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int year) => '~1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}
