import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';

class CustomDatePicker extends StatefulWidget {
  bool isDateHidden = false;
  bool isMonthHidden = false;
  final double? height;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onChanged;
  final CustomDropDownContoller controller;
  CustomDatePicker({
    Key? key,
    this.initialDate,
    required this.onChanged,
    required this.controller,
    this.height,
    this.firstDate,
    this.lastDate,
    this.isDateHidden = false,
    this.isMonthHidden = false,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  final now = DateTime.now();
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  List<String> dummy = [];
  int? currentDate;
  String? currentMonth;
  int? currentYear;
  int? getCurrentmonth;
  String msg = ''; // Variable for handling the error message
  bool fieldValidate = false;
  bool monthField_validate = false;
  bool yearField_validate = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
// if(widget.firstDate!=null && widget.lastDate!=null){
//     if (date.year < firstDate.year) return false;
// }
      String yr = DateFormat('yyyy').format(widget.initialDate!);
      String mn = DateFormat('MMM').format(widget.initialDate!);
      String intMn = DateFormat('MM').format(widget.initialDate!);
      String dt = DateFormat('dd').format(widget.initialDate!);

      setState(() {
        currentYear = int.parse(yr);
        currentDate = int.parse(dt);
        getCurrentmonth = int.parse(intMn);

        currentMonth = mn;
      });
    }
    validateDate();
  }

// ^^^leap years
  static bool isLeapYear(final int year) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

//^^^^ days count
  static int daysInDate({required int month, required int year}) {
    if (month == 2) {
      if (isLeapYear(year)) {
        return 29;
      } else {
        return 28;
      }
    }

    if ((month == 4 || month == 6 || month == 9 || month == 11)) {
      return 30;
    }

    return 31;
  }

//^^^^^

  List<DropdownMenuItem<String>> _buildDropdownMenuItemListForMonth() {
    List itm = [];
    itm = widget.isDateHidden? months
        : currentDate != null
            ? months
            : dummy;
    return itm
        .map(
          (i) => DropdownMenuItem<String>(
            value: i,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "$i",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        )
        .toList();
  }

  List<DropdownMenuItem<int>> _buildDropdownMenuItemList(int min, int max) {
    return widget.isMonthHidden? _intGenerator(min, max, true)
            .map(
              (i) => DropdownMenuItem<int>(
                value: i,
                child: Container(
                  alignment: widget.isMonthHidden? Alignment.centerLeft
                      : Alignment.center,
                  child: Text(
                    "$i",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            )
            .toList()
        : currentMonth != null
            ? _intGenerator(min, max, true)
                .map(
                  (i) => DropdownMenuItem<int>(
                    value: i,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "$i",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                )
                .toList()
            : dummy
                .map(
                  (i) => DropdownMenuItem<int>(
                    //value: i,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "$i",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                )
                .toList();
  }

  List<DropdownMenuItem<int>> _buildDropdownDayList(int min, int max) {
    return _intGenerator(min, max, true)
        .map(
          (i) => DropdownMenuItem<int>(
            value: i,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "$i",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildDropdownButtonForMonth({
    // required final String initialValue,
    required final String hint,
    required final Function onChanged,
    required final List<DropdownMenuItem<String>> items,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 2),
      height: 30,
      child: DropdownButton<String>(
        value: currentMonth,
        hint: Text(
          hint, // dd, mm, yyyy
          style: inputHintStyle,
        ),
        onChanged: (val) => Function.apply(onChanged, [val]),
        items: items,
        isExpanded: true,
        underline: SizedBox(),
        elevation: 2,
        //menuMaxHeight: 220,
        menuMaxHeight: Screen.height(context) / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );
  }

  Widget _buildDropdownButtonForDay({
    // required final int initialValue,
    required final String hint,
    required final Function onChanged,
    required final List<DropdownMenuItem<int>> items,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 2),
      height: 30,
      child: DropdownButton<int>(
        value: currentDate,
        hint: Text(
          hint, // dd, mm, yyyy
          style: inputHintStyle,
        ),
        onChanged: (val) => Function.apply(onChanged, [val]),
        items: items,
        isExpanded: true,
        underline: SizedBox(),
        elevation: 2,
        //menuMaxHeight: 220,
        menuMaxHeight: Screen.height(context) / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
    );
  }

  Widget _buildDropdownButton({
    // required final int initialValue,
    required final String hint,
    required final Function onChanged,
    required final List<DropdownMenuItem<int>> items,
  }) {
    return Container(
      padding: EdgeInsets.only(left: 2),
      height: 30,
      child: DropdownButton<int>(
        value: currentYear,
        hint: Text(
          hint, // dd, mm, yyyy
          style: inputHintStyle,
        ),
        onChanged: (val) => Function.apply(onChanged, [val]),
        items: items,
        isExpanded: true,
        underline: SizedBox(),
        elevation: 2,
        menuMaxHeight: Screen.height(context) / 2,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
    );
  }

  Iterable<int> _intGenerator(int start, int end, bool ascending) sync* {
    if (ascending) {
      for (var i = start; i <= end; i++) {
        yield i;
      }
    } else {
      for (var i = end; i >= start; i--) {
        yield i;
      }
    }
  }

  Widget _buildDayDropdownButton() {
    var minDay = 1;
    int tk = 31;

    if (widget.initialDate != null || currentMonth != null) {
      int index = months.indexWhere((item) => item == currentMonth);
      getCurrentmonth = index + 1;
      tk = daysInDate(
          month: getCurrentmonth!,
          year: currentYear == null ? 0 : currentYear!);
    }

//initialDate
    return _buildDropdownButtonForDay(
      items: _buildDropdownDayList(minDay, tk),
      hint: "DD",
      onChanged: (final day) {
        setState(() {
          currentDate = day;
        });
        validateDate();
      },
    );
  }

  Widget _buildMonthDropdownButton() {
    return _buildDropdownButtonForMonth(
      items: _buildDropdownMenuItemListForMonth(),
      // initialValue: currentMonth!,
      hint: "MMM",
      onChanged: (final month) {
        setState(() {
          currentMonth = month;
        });

        int index = months.indexWhere((item) => item == currentMonth);
        getCurrentmonth = index + 1;
        int gtDay = daysInDate(
            month: getCurrentmonth!,
            year: currentYear == null ? 0 : currentYear!);
        if (currentDate! > gtDay) {
          setState(() {
            currentDate = gtDay;
          });
        }

        _buildDropdownDayList(1, gtDay);
        validateDate();
      },
    );
  }

  Widget _buildYearDropdownButton() {
    return _buildDropdownButton(
      items: widget.firstDate != null && widget.lastDate != null
          ? _buildDropdownMenuItemList(
              widget.firstDate!.year,
              widget.lastDate!.year,
            )
          : _buildDropdownMenuItemList(
              1900,
              2040,
            ),
      hint: "YYYY",
      onChanged: (final year) {
        setState(() {
          currentYear = year;
        });
        int gtDay = daysInDate(
            month: getCurrentmonth == null ? 1 : getCurrentmonth!,
            year: currentYear!);
        if (currentDate! > gtDay) {
          setState(() {
            currentDate = gtDay;
          });
        }
        _buildDropdownDayList(1, gtDay);

        validateDate();
      },
    );
  }

  List<Widget> _buildDropdownButtonsByDateFormat() {
    final dropdownButtonList = <Widget>[
      widget.isDateHidden? SizedBox()
          : Flexible(child: _buildDayDropdownButton()),
      SizedBox(
        width: 1,
      ),
      widget.isMonthHidden? SizedBox()
          : Expanded(child: _buildMonthDropdownButton()),
      SizedBox(
        width: 1,
      ),
      Expanded(child: _buildYearDropdownButton()),
    ];
    return dropdownButtonList;
  }

  void validateDate() {
    if (currentDate != null && currentMonth != null && currentYear != null) {
      String date_ = "$currentYear$currentMonth$currentDate";
      DateTime dateTime = DateFormat("yyyyMMMdd").parse(date_);
      widget.onChanged(dateTime);

      print(dateTime.toString());
      print(widget.lastDate.toString());
      var lastDateVar = Jiffy(widget.lastDate).format("MM-dd-yyyy");
      var lastDateFormat = Jiffy(lastDateVar, 'MM-dd-yyyy');
      var selectDateVar = Jiffy(dateTime).format("MM-dd-yyyy");
      var selectDateFormat = Jiffy(selectDateVar, 'MM-dd-yyyy');
      String differenceMonth =
          selectDateFormat.diff(lastDateFormat, Units.DAY).toString();
      int different = int.parse(differenceMonth);


      setState(() {
        if(different <0){
             msg = '';
        widget.controller.current_date = dateTime.toString();
           widget.controller.validate = false;
       
        }else{
             widget.controller.validate = true;
            msg = 'Date of Birth should be past date only';
        widget.controller.current_date = '';
        }
     
      });
    } else if (currentDate != null &&
            (currentMonth == null && currentYear == null) ||
        (currentMonth != null && currentYear == null) ||
        (currentMonth == null && currentYear != null)) {
      widget.controller.validate = true;
      widget.controller.current_date = 'Wrong Date';
    } else {
      setState(() {
        msg = 'Invalid Date';
        widget.controller.current_date = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height != null ? widget.height : 47,
          padding: EdgeInsets.only(left: 5, right: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildDropdownButtonsByDateFormat(),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border.all(
              //color: Colors.white,
              color: widget.controller.validate ? Colors.red : Colors.white,
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        widget.controller.validate
            ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 0, 2),
                child: Text(msg,
                    style: TextStyle(color: activeColor, fontSize: 12)))
            : SizedBox()
      ],
    );
  }
}

class CustomDropDownContoller extends ChangeNotifier {
  bool validate = false;
  String current_date = '';
  void enableValidate(bool v) {
    validate = v;

    notifyListeners();
  }
}
