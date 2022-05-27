import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/screen_size.dart';
import 'package:swarapp/shared/text_styles.dart';

class CustomYearPicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onChanged;
  final CustomYearContoller controller;
  CustomYearPicker({
    Key? key,
    this.initialDate,
    required this.onChanged,
    required this.controller,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  _CustomYearPickerState createState() => _CustomYearPickerState();
}

class _CustomYearPickerState extends State<CustomYearPicker> {
  final now = DateTime.now();
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<String> dummy = [];
  String? currentMonth;
  int? currentYear;
  int? getCurrentmonth;
  String msg = ''; // Variable for handling the error message
 

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      
      String yr = DateFormat('yyyy').format(widget.initialDate!);
      String mn = DateFormat('MMM').format(widget.initialDate!);
      String intMn = DateFormat('MM').format(widget.initialDate!);
      String dt = DateFormat('dd').format(widget.initialDate!);

      setState(() {
        currentYear = int.parse(yr);
        getCurrentmonth = int.parse(intMn);
        currentMonth = mn;
      });
    }
    validateDate();
  }

  List<DropdownMenuItem<String>> _buildDropdownMenuItemListForMonth() {
    List itm = [];
    itm = months;

    return itm
        .map(
          (i) => DropdownMenuItem<String>(
            value: i,
            child: Container(
              alignment: Alignment.centerLeft,
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
    return currentMonth != null?    
     _intGenerator(min, max, true)
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
        :dummy
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
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

  Widget _buildMonthDropdownButton() {
    return _buildDropdownButtonForMonth(
      items: _buildDropdownMenuItemListForMonth(),
      hint: "MMM",
      onChanged: (final month) {
        setState(() {
          currentMonth = month;
          widget.controller.validate = true;
        });
        
        int index = months.indexWhere((item) => item == currentMonth);
        getCurrentmonth = index + 1;
        validateDate();
      },
    );
  }

  Widget _buildYearDropdownButton() {
    return 
    
    _buildDropdownButton(
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
        validateDate();
      },
    );
  }

  List<Widget> _buildDropdownButtonsByDateFormat() {
    final dropdownButtonList = <Widget>[
      Expanded(child: _buildMonthDropdownButton()),
      SizedBox(
        width: 1,
      ),
      Expanded(child: _buildYearDropdownButton()),
    ];
    return dropdownButtonList;
  }

  void validateDate() {
    if (currentMonth != null && currentYear != null) {
      String date_ = "$currentYear$currentMonth"+"01";
      DateTime dateTime = DateFormat("yyyyMMMdd").parse(date_);
      widget.onChanged(dateTime);
      setState(() {
        msg = '';
      widget.controller.current_date = dateTime.toString();
           widget.controller.validate = false;
      });
    }  else {
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
          height: 47,
          padding: EdgeInsets.only(left: 5, right: 2),
          child: Column(
           // crossAxisAlignment: CrossAxisAlignment.center,
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
              color: widget.controller.validate ? Colors.red : Colors.white,
            ),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
        widget.controller.validate ? Padding(padding: const EdgeInsets.fromLTRB(20, 6, 0, 2), child: Text(msg, style: TextStyle(color: activeColor, fontSize: 12))) : SizedBox()
      ],
    );
  }
}

class CustomYearContoller extends ChangeNotifier {
  bool validate = false;
  String current_date = '';
  
  void enableValidate(bool v) {
    validate = v;
    notifyListeners();
  }
}
