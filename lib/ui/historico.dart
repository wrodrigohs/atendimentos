import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';

class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  DatePickerController _controller = DatePickerController();
  DateTime _selectedValue = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () {
            _controller.animateToDate(DateTime.now());
          },
        ),
        appBar: AppBar(
          title: Text('widget.title'),
        ),
        body: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.blueGrey[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("You Selected:"),
              Text(_selectedValue.toString()),
              Padding(
                padding: EdgeInsets.all(10),
              ),
              Container(
                child: DatePicker(
                  DateTime.now(),
                  locale: 'pt-BR',
                  width: 60,
                  height: 80,
                  controller: _controller,
                  daysCount: 30,

                  //initialSelectedDate: DateTime.now().subtract(Duration(days: 2)),
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  /*inactiveDates: [
                    DateTime.now().subtract(Duration(days: 365)),
                    DateTime.now().add(Duration(days: 365)),
                  ],*/
                  onDateChange: (date) {
                    // New date selected
                    setState(() {
                      _selectedValue = date;
                    });
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}
