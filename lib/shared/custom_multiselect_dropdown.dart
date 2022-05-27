import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:swarapp/shared/app_colors.dart';
import 'package:swarapp/shared/ui_helpers.dart';

class _TheState {}

var _theState = RM.inject(() => _TheState());

class _SelectRow extends StatelessWidget {
  final Function(bool) onChange;
  final bool selected;
  final String text;

  const _SelectRow({Key? key, required this.onChange, required this.selected, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: selected,
            onChanged: (x) {
              onChange(x!);
              _theState.notify();
            }),
        Expanded(child: Text(text).fontSize(13)),
      ],
    );
  }
}

///
/// A Dropdown multiselect menu
///
///
class DropDownMultiSelect extends StatefulWidget {
  /// The options form which a user can select
  final List<String> options;

  /// Selected Values
  final List<String> selectedValues;

  /// This function is called whenever a value changes
  final Function(List<String>) onChanged;

  /// defines whether the field is dense
  final bool isDense;

  /// defines whether the widget is enabled;
  final bool enabled;

  /// Input decoration
  final InputDecoration? decoration;

  /// this text is shown when there is no selection
  final String? whenEmpty;

  /// a function to build custom childern
  final Widget Function(List<String> selectedValues)? childBuilder;

  /// a function to build custom menu items
  final Widget Function(String option)? menuItembuilder;

  const DropDownMultiSelect({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.whenEmpty,
    this.childBuilder,
    this.menuItembuilder,
    this.isDense = false,
    this.enabled = true,
    this.decoration,
  }) : super(key: key);
  @override
  _DropDownMultiSelectState createState() => _DropDownMultiSelectState();
}

class _DropDownMultiSelectState extends State<DropDownMultiSelect> {
  List<String> defaultSelectedValues = [];
  List<String> unSelectedValues = [];
  //final _selectedValues = Set<V>();
  // void initState() {
  //   super.initState();
  //   if (widget.selectedValues != null) {
  //     defaultSelectedValues = widget.selectedValues;
  //   }
  // }

  void _onCancelTap() {
    //widget.selectedValues.clear();
    // widget.selectedValues.addAll(defaultSelectedValues!);
    print('default selected----' + defaultSelectedValues.toString());
    //widget.selectedValues.remove(defaultSelectedValues);
    //widget.onChanged(defaultSelectedValues!);

    setState(() {
      if (defaultSelectedValues.isNotEmpty) {
        widget.selectedValues.removeWhere((item) => defaultSelectedValues.contains(item));
      } else {
        widget.selectedValues.addAll(unSelectedValues);
      }
    });
    defaultSelectedValues.clear();
    print('REMOVED_________----' + widget.selectedValues.toString());
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    defaultSelectedValues.clear();
    Navigator.pop(context, widget.selectedValues);
  }

  void _onItemCheckedChange(itemValue, bool checked) {
    print("Onchanged value " + itemValue);
    setState(() {
      if (checked) {
        widget.selectedValues.add(itemValue);
      } else {
        widget.selectedValues.remove(itemValue);
      }
    });
  }

  Widget _buildItem(List<String> item) {
    print('============item' + item.toString());
    final checked = widget.selectedValues.contains(item);
    return CheckboxListTile(
      value: checked,
      title: Text(item.toString()),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        print('onchange value' + item.toString());
        _onItemCheckedChange(item, checked!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //  defaultSelectedValues = widget.selectedValues;
    return GestureDetector(
        onTap: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Select your options'),
                  contentPadding: EdgeInsets.only(top: 12.0),
                  content: SingleChildScrollView(
                    child: ListTileTheme(
                      contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
                      child: ListBody(
                          children: widget.options
                              .map((x) => DropdownMenuItem(
                                    //child: Container(),
                                    child: _theState.rebuilder(() {
                                      return widget.menuItembuilder != null
                                          ? widget.menuItembuilder!(x)
                                          : _SelectRow(
                                              selected: widget.selectedValues.contains(x),
                                              text: x,
                                              onChange: (isSelected) {
                                                if (isSelected) {
                                                  print("XXXX" + x);
                                                  var ns = widget.selectedValues;
                                                  defaultSelectedValues.add(x);
                                                  ns.add(x);
                                                  widget.onChanged(ns);
                                                } else {
                                                  var ns = widget.selectedValues;
                                                  defaultSelectedValues.remove(x);
                                                  unSelectedValues.add(x);
                                                  ns.remove(x);
                                                  widget.onChanged(ns);
                                                }
                                              },
                                            );
                                    }),
                                  ))
                              .toList()),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('CANCEL'),
                      onPressed: _onCancelTap,
                    ),
                    FlatButton(
                      child: Text('OK'),
                      onPressed: _onSubmitTap,
                    )
                  ],
                );
              });
        },
        child: Container(
          decoration: UIHelper.roundedBorderWithColor(10, Colors.white),
          height: 47,
          child: Stack(
            children: [
              _theState.rebuilder(() => widget.childBuilder != null
                  ? widget.childBuilder!(widget.selectedValues)
                  : Align(
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12), child: Text(widget.selectedValues.length > 0 ? widget.selectedValues.reduce((a, b) => a + ' , ' + b) : widget.whenEmpty ?? '')),
                      alignment: Alignment.centerLeft)),
              UIHelper.horizontalSpaceSmall,
              // Align(
              GestureDetector(
                onTap: () async {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () async {},
                    ),
                  ],
                ),
              )
              //alignment: Alignment.topRight)
            ],
          ),
        ));
  }
}
