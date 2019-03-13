class Util {
  /* get weekday name of MM-dd-yyyy date */
  static String getWeekDay(String _date) {
    DateTime date = DateTime.parse(_date[6] +
        _date[7] +
        _date[8] +
        _date[9] +
        _date[0] +
        _date[1] +
        _date[3] +
        _date[4]);
    List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[date.weekday - 1];
  }
}
