import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:swarapp/frideos/streamed_object.dart';
import 'streamed_list.dart';

class StreamedValue<T> implements StreamedObject<T?> {
  StreamedValue({this.initialData, this.onError}) {
    stream = BehaviorSubject<T>()
      ..stream.listen((e) {
        _lastValue = e;
        if (_onChange != null) {
          _onChange!(e);
        }
      }, onError: onError);

    if (initialData != null) {
      _lastValue = initialData;
      stream!.sink.add(_lastValue);
    }
  }

  /// Stream of type [BehaviorSubject] in order to emit
  /// the last event to every new listener.
  BehaviorSubject<T?>? stream;

  /// Callback to handle the errors
  final Function? onError;

  /// Stream getter
  @override
  Stream<T?>? get outStream => stream;

  /// Sink for the stream
  Function get inStream => stream!.sink.add;

  /// Last value emitted by the stream
  T? _lastValue;

  /// The initial event of the stream
  T? initialData;

  /// timesUpdate shows how many times the stream got updated
  int timesUpdated = 0;

  /// Debug mode (Default: false)
  bool _debugMode = false;

  /// This function will be called every time the stream updates.
  Function(T data)? _onChange;

  /// Getter for the last value emitted by the stream
  @override
  T? get value => _lastValue;

  /// To send to stream a new event
  set value(T? value) {
    _lastValue = value;
    stream!.sink.add(value);
    if (_debugMode) {
      timesUpdated++;
    }
  }

  /// To set a function that will be called every time the stream updates.
  void onChange(Function(T data) onDataChanged) => _onChange = onDataChanged;

  /// Method to refresh the stream (e.g to use when the type it is not
  /// a basic type, and a property of an object has changed).
  void refresh() {
    stream!.sink.add(value);
    if (_debugMode) {
      timesUpdated++;
    }
  }

  /// To enable the debug mode
  void debugMode() {
    _debugMode = true;
  }

  void dispose() {
    if (_debugMode) {
      print('---------- Closing Stream ------ type: $T');
      print('Value: $value');
      print('Updated times: $timesUpdated');
    }
    stream!.close();
  }
}

///
///
///
/// The MemoryObject has a property to preserve the previous value.
///
/// The setter checks for the new value, if it is different from the one
/// already stored, this one is given [oldValue] before storing and streaming
/// the new one.
///
///
///
class MemoryValue<T> extends StreamedValue<T?> {
  MemoryValue({T? initialData, Function? onError}) : super(initialData: initialData, onError: onError);

  T? _oldValue;

  T? get oldValue => _oldValue;

  @override
  set value(T? value) {
    if (_lastValue != value) {
      _oldValue = _lastValue;
      _lastValue = value;
      stream!.add(value);
      if (_debugMode) {
        timesUpdated++;
      }
    }
  }
}

/// HistoryObject extends the [MemoryValue] class, adding a [StreamedList].
///
/// When the current value needs to be stored, the [saveValue] function
/// is called to send it to the [_historyStream].
///
class HistoryObject<T> extends MemoryValue<T> {
  HistoryObject({T? initialData, Function? onError}) : super(initialData: initialData, onError: onError);

  final StreamedList<T?> _historyStream = StreamedList<T>(initialData: []);

  @override
  set value(T? value) {
    if (_lastValue != value) {
      _oldValue = _lastValue;
      inStream(value);
      if (_debugMode) {
        timesUpdated++;
      }
    }
  }

  ///
  /// Getter for the list
  ///
  List<T?>? get history => _historyStream.value;

  ///
  /// Getter for the stream
  ///
  StreamedValue<List<T?>>? get historyStream => _historyStream.stream;

  ///
  /// Function to store the current value to a collection and
  /// sending it to stream
  ///
  void saveValue() {
    _historyStream.addElement(value);
  }

  /// To enable the debug mode
  @override
  void debugMode() {
    _debugMode = true;
    _historyStream.debugMode();
  }

  @override
  void dispose() {
    super.dispose();
    _historyStream.dispose();
  }
}

///
///
/// Timer refresh time
const int updateTimerMilliseconds = 17;


/// An object that embeds a timer and a stopwatch.
/// #### Usage
///
/// ```dart
/// final timerObject = TimerObject();
///
/// startTimer() {
///   timerObject.startTimer();
/// }
///
/// stopTimer() {
///   timerObject.stopTimer();
/// }
///
/// getLapTime() {
///   timerObject.getLapTime();
/// }
///
/// incrementCounter(Timer t) {
///   counter.value += 2.0;
/// }
///
/// startPeriodic() {
///   var interval = Duration(milliseconds: 1000);
///   timerObject.startPeriodic(interval, incrementCounter);
/// }
///
///```
///
class TimerObject extends StreamedValue<int> {
  Timer? _timer;

  Duration _interval = Duration(milliseconds: updateTimerMilliseconds);

  bool isTimerActive = false;

  int _time = 0; // milliseconds

  /// STOPWATCH
  final _stopwatch = Stopwatch();

  final _stopwatchStreamed = StreamedValue<int>();

  bool isStopwatchActive = false;

  @override
  set value(int? value) {
    if (_lastValue != value) {
      inStream(value);
      if (_debugMode) {
        timesUpdated++;
      }
    }
  }

  /// GETTERS
  ///
  int get time => _time;

  /// Getter for the stream of the stopwatch
  Stream<int?>? get stopwatchStream => _stopwatchStreamed.outStream;

  /// Getter for the stopwatch object
  StreamedValue<int> get stopwatch => _stopwatchStreamed;

  /// Start timer and stopwatch only if they aren't active
  ///
  void startTimer() {
    if (!isTimerActive) {
      _timer = Timer.periodic(_interval, updateTime);
      isTimerActive = true;
    }

    if (!isStopwatchActive) {
      _stopwatch.start();
      isStopwatchActive = true;
    }
  }

  /// Update the time and send it to stream
  ///
  void updateTime(Timer t) {
    _time = _interval.inMilliseconds * t.tick;
    inStream(_time);
  }

  /// Method to start a periodic function and set the isTimerActive to true
  ///
  void startPeriodic(Duration interval, Function(Timer) callback) {
    if (!isTimerActive) {
      _timer = Timer.periodic(interval, callback);
      _interval = interval;
      isTimerActive = true;
    }
  }

  /// Method to get the lap time
  void getLapTime() {
    if (isStopwatchActive) {
      final milliseconds = _stopwatch.elapsedMilliseconds;
      _stopwatchStreamed.value = milliseconds;
      _stopwatch
        ..reset()
        ..start();
    }
  }

  /// Stop timer and stopwatch, and set to false the booleans
  void stopTimer() {
    if (isTimerActive) {
      _timer!.cancel();
      _time = 0;
      inStream(null);
      isTimerActive = false;
    }
    if (isStopwatchActive) {
      _stopwatch
        ..reset()
        ..stop();
      isStopwatchActive = false;
    }
  }

  /// Method to reset the timer
  void resetTimer() {
    _time = 0;
    inStream(_time);
  }

  /// Method to cancel the current timer
  void pauseTimer() {
    _timer!.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    _stopwatchStreamed.dispose();
    _stopwatch.stop();
  }
}

///
///
/// A particular class the implement the [StreamedObject] interface, to use when
/// there is the need of a StreamTransformer (e.g. stream transformation,
/// validation of input fields, etc.).
///
///
/// #### Usage
///
/// From the StreamedMap example:
///
/// ```dart
/// // In the BLoC class
///   final streamedKey = StreamedTransformed<String, int>();
///
///
/// // In the constructor of the BLoC class
///   streamedKey.setTransformer(validateKey);
///
///
/// // Validation (e.g. in the BLoC or in a mixin class)
/// final validateKey =
///       StreamTransformer<String, int>.fromHandlers(handleData: (key, sink) {
///     var k = int.tryParse(key);
///     if (k != null) {
///       sink.add(k);
///     } else {
///       sink.addError('The key must be an integer.');
///     }
///   });
///
///
/// // In the view:
/// StreamBuilder<int>(
///             stream: bloc.streamedKey.outTransformed,
///             builder: (context, snapshot) {
///               return Column(
///                 children: <Widget>[
///                   Padding(
///                     padding: const EdgeInsets.symmetric(
///                       vertical: 12.0,
///                       horizontal: 20.0,
///                     ),
///                     child: TextField(
///                       style: TextStyle(
///                         fontSize: 18.0,
///                         color: Colors.black,
///                       ),
///                       decoration: InputDecoration(
///                         labelText: 'Key:',
///                         hintText: 'Insert an integer...',
///                         errorText: snapshot.error,
///                       ),
///                       // To avoid the user could insert text use the TextInputType.number
///                       // Here is commented to show the error msg.
///                       //keyboardType: TextInputType.number,
///                       onChanged: bloc.streamedKey.inStream,
///                     ),
///                   ),
///                 ],
///               );
///             }),
/// ```
///
///
///
class StreamedTransformed<T, S> implements StreamedObject<T?> {
  StreamedTransformed({this.initialData, this.onError}) {
    stream = BehaviorSubject<T>()
      ..listen((e) {
        _lastValue = e;
        if (_onChange != null) {
          _onChange!(e);
        }
      }, onError: onError);

    if (initialData != null) {
      _lastValue = initialData;
      stream.sink.add(_lastValue);
    }
  }

  /// Last value emitted by the stream
  T? _lastValue;

  /// The initial event of the stream
  T? initialData;

  /// Value of the last event transformed
  S? transformed;

  /// timesUpdate shows how many times the stream got updated
  int timesUpdated = 0;

  /// Debug mode (Default: false)
  bool _debugMode = false;

  late BehaviorSubject<T?> stream;

  /// Callback to handle the errors
  final Function? onError;

  /// Sink for the stream
  Function get inStream => stream.sink.add;

  /// Stream getter
  @override
  Stream<T?> get outStream => stream.stream;

  /// Streamtransformer
  late StreamTransformer _transformer;

  /// Getter for the stream transformed
  Stream<S?> get outTransformed => stream.stream.transform(_transformer as StreamTransformer<T?, S?>);

  /// Value getter
  @override
  T? get value => _lastValue;

  /// Value setter
  set value(T? value) => inStream(value);

  /// This function will be called every time the stream updates.
  Function(T data)? _onChange;

  /// This function will be called every time the stream updates.
  void onChange(Function(T data) onDataChanged) {
    _onChange = onDataChanged;
  }

  /// To set a function that will be called every time the stream updates.
  void setTransformer(StreamTransformer<T, S> transformer) {
    assert(transformer != null, 'Invalid transformer.');
    _transformer = transformer;
  }

  /// To enable the debug mode
  void debugMode() {
    _debugMode = true;
  }

  /// Method to refresh the stream (e.g to use when the type it is not
  /// a basic type, and a property of an object has changed).
  void refresh() {
    inStream(value);
    if (_debugMode) {
      timesUpdated++;
    }
  }

  /// Dispose the stream.
  void dispose() {
    if (_debugMode) {
      print('---------- Closing Stream ------ type: $T');
      print('Value: $value');
      print('Updated times: $timesUpdated');
    }
    stream.close();
  }
}
