// // Copyright 2019 Aleksander Woźniak
// // SPDX-License-Identifier: Apache-2.0

// import 'package:flutter/material.dart';
// import 'package:intl/date_symbol_data_local.dart';

// class calend extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TableCalendar Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: StartPage(),
//     );
//   }
// }

// class StartPage extends StatefulWidget {
//   @override
//   _StartPageState createState() => _StartPageState();
// }

// class _StartPageState extends State<StartPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TableCalendar Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               child: Text('Basics'),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => TableBasicsExample()),
//               ),
//             ),
//             const SizedBox(height: 12.0),
//             ElevatedButton(
//               child: Text('Range Selection'),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => TableRangeExample()),
//               ),
//             ),
//             const SizedBox(height: 12.0),
//             ElevatedButton(
//               child: Text('Events'),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => TableEventsExample()),
//               ),
//             ),
//             const SizedBox(height: 12.0),
//             ElevatedButton(
//               child: Text('Multiple Selection'),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => TableMultiExample()),
//               ),
//             ),
//             const SizedBox(height: 12.0),
//             ElevatedButton(
//               child: Text('Complex'),
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => TableComplexExample()),
//               ),
//             ),
//             const SizedBox(height: 20.0),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:swarapp/shared/app_colors.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CustomTableCalendar extends StatefulWidget {
//   final dynamic dataView;

//   const CustomTableCalendar({
//     Key? key,
//     required this.dataView,
//   }) : super(key: key);

//   @override
//   _CustomTableCalendarState createState() => _CustomTableCalendarState();
// }

// class _CustomTableCalendarState extends State<CustomTableCalendar> {
//   final todaysDate = DateTime.now();
//   var _focusedCalendarDate = DateTime.now();
//   final _initialCalendarDate = DateTime(2000);
//   final _lastCalendarDate = DateTime(2050);
//   DateTime? selectedCalendarDate;
//   final titleController = TextEditingController();
//   final descpController = TextEditingController();
//   dynamic selection_date_list = {};
//   late Map<DateTime, List<MyEvents>> mySelectedEvents;

//   @override
//   void initState() {
//     selectedCalendarDate = _focusedCalendarDate;
//     mySelectedEvents = {};
//     super.initState();
//   }

//   @override
//   void dispose() {
//     titleController.dispose();
//     descpController.dispose();
//     super.dispose();
//   }

//   List<MyEvents> _listOfDayEvents(DateTime dateTime) {
//     var glist = widget.dataView;
//     var d2;
//     var d1;
//     if (glist.length > 0) {
//       glist.map((user) => {
//             // from = Jiffy(user['slot_date']),
//             // d2 = from.format('MM-dd-yyyy'),
//             // d2 = user['slot_date'],
//             // if (d2 == d1)
//             //   {
//             //     selection_date_list = user,
//             //     // setState(() {
//             //     //   isload = true;
//             //     //   toupdate = true;
//             //     //   isChangedSelection = true;
//             //     // })
//             //   }
//             user['slot_date'] = user['slot_date'].replaceAll('-', ''),
//             //DateFormat('MM-dd-yyyy').format(args.value)
//             // mySelectedEvents[DateTime.parse(user['slot_date']!)] = [MyEvents(eventTitle: "new", eventDescp: "desc")]
//             mySelectedEvents[DateTime.parse(user['slot_date']!)] = [MyEvents(eventTitle: titleController.text, eventDescp: descpController.text)]
//           });
//       //.toList();
//     }

//     for (var gtdate in widget.dataView) {
//       mySelectedEvents[DateTime.parse(gtdate['slot_date']!)] = [MyEvents(eventTitle: titleController.text, eventDescp: descpController.text)];
//     }
//     return mySelectedEvents[dateTime] ?? [];
//   }

//   _showAddEventDialog() async {
//     await showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               title: const Text('New Event'),
//               content: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   buildTextField(controller: titleController, hint: 'Enter Title'),
//                   const SizedBox(
//                     height: 20.0,
//                   ),
//                   buildTextField(controller: descpController, hint: 'Enter Description'),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     if (titleController.text.isEmpty && descpController.text.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please enter title & description'),
//                           duration: Duration(seconds: 3),
//                         ),
//                       );
//                       //Navigator.pop(context);
//                       return;
//                     } else {
//                       setState(() {
//                         if (mySelectedEvents[selectedCalendarDate] != null) {
//                           mySelectedEvents[selectedCalendarDate]?.add(MyEvents(eventTitle: titleController.text, eventDescp: descpController.text));
//                         } else {
//                           mySelectedEvents[selectedCalendarDate!] = [MyEvents(eventTitle: titleController.text, eventDescp: descpController.text)];
//                         }
//                       });

//                       titleController.clear();
//                       descpController.clear();

//                       Navigator.pop(context);
//                       return;
//                     }
//                   },
//                   child: const Text('Add'),
//                 ),
//               ],
//             ));
//   }

//   Widget buildTextField({String? hint, required TextEditingController controller}) {
//     return TextField(
//       controller: controller,
//       textCapitalization: TextCapitalization.words,
//       decoration: InputDecoration(
//         labelText: hint ?? '',
//         focusedBorder: OutlineInputBorder(
//           borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
//           borderRadius: BorderRadius.circular(
//             10.0,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: const BorderSide(width: 1.5),
//           borderRadius: BorderRadius.circular(
//             10.0,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     var glist = widget.dataView;
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Custom Calendar'),
//       // ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () => _showAddEventDialog(),
//       //   label: const Text('Add Event'),
//       // ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Card(
//               margin: const EdgeInsets.all(4.0),
//               elevation: 5.0,
//               shape: const RoundedRectangleBorder(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(10),
//                 ),
//                 side: BorderSide(color: Colors.white, width: 1.0),
//               ),
//               child: TableCalendar(
//                 focusedDay: _focusedCalendarDate,
//                 // today's date
//                 firstDay: _initialCalendarDate,
//                 // earliest possible date
//                 lastDay: _lastCalendarDate,
//                 // latest allowed date
//                 calendarFormat: CalendarFormat.month,
//                 rangeSelectionMode: RangeSelectionMode.toggledOn,
//                 // default view when displayed
//                 // default is Saturday & Sunday but can be set to any day.
//                 // instead of day number can be mentioned as well.
//                 weekendDays: const [DateTime.sunday, 6],
//                 // default is Sunday but can be changed according to locale
//                 startingDayOfWeek: StartingDayOfWeek.monday,
//                 // height between the day row and 1st date row, default is 16.0
//                 daysOfWeekHeight: 40.0,
//                 // height between the date rows, default is 52.0
//                 rowHeight: 60.0,
//                 // this property needs to be added if we want to show events
//                 eventLoader: _listOfDayEvents,
//                 // Calendar Header Styling
//                 headerStyle: const HeaderStyle(
//                   titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0),
//                   decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
//                   formatButtonTextStyle: TextStyle(color: Colors.black, fontSize: 16.0),
//                   formatButtonDecoration: BoxDecoration(
//                     color: Colors.grey,
//                     borderRadius: BorderRadius.all(
//                       Radius.circular(5.0),
//                     ),
//                   ),
//                   leftChevronIcon: Icon(
//                     Icons.chevron_left,
//                     color: Colors.grey,
//                     size: 28,
//                   ),
//                   rightChevronIcon: Icon(
//                     Icons.chevron_right,
//                     color: Colors.grey,
//                     size: 28,
//                   ),
//                 ),
//                 // Calendar Days Styling
//                 daysOfWeekStyle: const DaysOfWeekStyle(
//                   // Weekend days color (Sat,Sun)
//                   weekendStyle: TextStyle(color: activeColor),
//                 ),
//                 // Calendar Dates styling
//                 calendarStyle: const CalendarStyle(
//                   // Weekend dates color (Sat & Sun Column)
//                   weekendTextStyle: TextStyle(color: activeColor),
//                   // highlighted color for today
//                   todayDecoration: BoxDecoration(
//                     color: Colors.grey,
//                     shape: BoxShape.circle,
//                   ),
//                   // highlighted color for selected day
//                   selectedDecoration: BoxDecoration(
//                     color: activeColor,
//                     shape: BoxShape.circle,
//                   ),
//                   markerDecoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
//                 ),
//                 selectedDayPredicate: (currentSelectedDate) {
//                   // as per the documentation 'selectedDayPredicate' needs to determine
//                   // current selected day
//                   return (isSameDay(selectedCalendarDate!, currentSelectedDate));
//                 },
//                 onDaySelected: (selectedDay, focusedDay) {
//                   // as per the documentation
//                   if (!isSameDay(selectedCalendarDate, selectedDay)) {
//                     setState(() {
//                       selectedCalendarDate = selectedDay;
//                       _focusedCalendarDate = focusedDay;
//                       mySelectedEvents[selectedCalendarDate!] = [MyEvents(eventTitle: titleController.text, eventDescp: descpController.text)];
//                     });
//                   }
//                 },
//               ),
//             ),
//             // ..._listOfDayEvents(selectedCalendarDate!).map(
//             //   (myEvents) => ListTile(
//             //     leading: const Icon(
//             //       Icons.done,
//             //       color: Colors.grey,
//             //     ),
//             //     title: Padding(
//             //       padding: const EdgeInsets.only(bottom: 8.0),
//             //       child: Text('Event Title:   ${myEvents.eventTitle}'),
//             //     ),
//             //     subtitle: Text('Description:   ${myEvents.eventDescp}'),
//             //   ),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyEvents {
//   final String eventTitle;
//   final String eventDescp;

//   MyEvents({required this.eventTitle, required this.eventDescp});

//   @override
//   String toString() => eventTitle;
// }

import 'package:flutter/material.dart';

class AnimatedScreen extends StatefulWidget {
  @override
  _AnimatedScreenState createState() => _AnimatedScreenState();
}

class _AnimatedScreenState extends State<AnimatedScreen> with TickerProviderStateMixin {
  Animation? _containerRadiusAnimation, _containerSizeAnimation, _containerColorAnimation;
  AnimationController? _containerAnimationController;

  @override
  void initState() {
    super.initState();
    _containerAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 3000));

    _containerRadiusAnimation =
        BorderRadiusTween(begin: BorderRadius.circular(100.0), end: BorderRadius.circular(0.0)).animate(CurvedAnimation(curve: Curves.fastLinearToSlowEaseIn, parent: _containerAnimationController!));

    _containerSizeAnimation = Tween(begin: 0.0, end: 0.5).animate(CurvedAnimation(curve: Curves.ease, parent: _containerAnimationController!));

    _containerColorAnimation = ColorTween(begin: Colors.black, end: Colors.white).animate(CurvedAnimation(curve: Curves.ease, parent: _containerAnimationController!));

    _containerAnimationController!.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _containerAnimationController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Animated Screen'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _containerAnimationController!,
          builder: (context, index) {
            return Container(
              // transform: Matrix4.translationValues(_containerSizeAnimation!.value * width - 200.0, 0.0, 0.0),
              width: _containerSizeAnimation!.value * height,
              height: _containerSizeAnimation!.value * height,
              decoration: BoxDecoration(borderRadius: _containerRadiusAnimation!.value, color: _containerColorAnimation!.value),
            );
          },
        ),
      ),
    );
  }
}
