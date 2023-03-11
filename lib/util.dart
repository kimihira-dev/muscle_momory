bool intToBool(int a) => a == 0 ? false : true;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
