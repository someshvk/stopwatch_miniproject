import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audio_cache.dart';

void main() {
  runApp(StartPage());
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "New Task",
      debugShowCheckedModeBanner: false,
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Speech"),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.white,
          tabs: [
            new Tab(icon: new Icon(Icons.mic)),
            new Tab(
              icon: new Icon(Icons.alarm_on),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,),
        bottomOpacity: 1,

      ),
      body: TabBarView(
        children: [
          MyApp(),
          stopwatch(),
        ],
        controller: _tabController,),
    );
  }
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Stopwatch',
      debugShowCheckedModeBanner : false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: speechScreen(),
    );
  }
}

class speechScreen extends StatefulWidget{
  @override
  _speechScreenState createState() => _speechScreenState();
}

class _speechScreenState extends State<speechScreen>{
  final Map<String, HighlightedWord> _word = {};
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the mic button and start speaking.';
  @override
  void initState(){
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 1000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
      child: FloatingActionButton(
        onPressed: _listen01,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _word,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
    ),
    );
  }
  void _listen00() async{
    if(!_isListening){
      bool available= await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if(available){
        setState(() => _isListening=true);
        _speech.listen(
          listenFor: Duration(minutes: 10),
          onResult: (val) => setState(() {
            _text= val.recognizedWords;
          }),
        );
      }
     }
    else{
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
  void _listen01() async{
    int n=0;
    while(n != 10){
      _listen00();
      if(_text == "cancel recording"){
        break;
      }
      n++;
    }
  }
}
// STOPWATCH
// ================================
// ================================
// ================================

class stopwatch extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      title: 'stopwatch',
      home: MyHomePage(title: 'stopwatch'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final player = AudioCache();
  final Map<String, HighlightedWord> _word = {};
  stt.SpeechToText _speech2;
  bool _isListening2 = false;
  String _text = '  ';
  @override
  void initState(){
    super.initState();
    _speech2 = stt.SpeechToText();
  }

  bool startPressed = true;
  bool stopPressed = true;
  bool resetPressed = true;
  String timeDisplay = '00:00:00';
  var swatch = Stopwatch();
  final dur = const Duration(seconds: 1);

  void startTimer() {
    Timer(dur, keepRunning);
  }

  void keepRunning() {
    if (swatch.isRunning) {
      startTimer();
    }
    setState(() {
      timeDisplay = swatch.elapsed.inHours.toString().padLeft(2, "0") + ":" +
          (swatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") + ":" +
          (swatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  void startStopwatch() {
    setState(() {
      stopPressed = false;
      startPressed = false;
    });
    swatch.start();
    startTimer();
  }

  void stopStopwatch() {
    setState(() {
      stopPressed = true;
      resetPressed = false;
      startPressed = true;
    });
    swatch.stop();
  }

  void resetStopwatch() {
    setState(() {
      startPressed = true;
      resetPressed = true;
    });
    swatch.reset();
    timeDisplay= "00:00:00";
  }

  void _listen2() async{
      if (!_isListening2) {
        bool available2 = await _speech2.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available2) {
          setState(() => _isListening2 = true);
          _speech2.listen(
            onResult: (val) =>
                setState(() {
                  _text = val.recognizedWords;
                  if (_text == "start") {
                    startStopwatch();
                  }
                  else if (_text == "stop") {
                    stopStopwatch();
                  }
                  else if (_text == "reset") {
                    resetStopwatch();
                  }
                  int r=10;
                  for(int i=0; i<= r; i++){
                    _listen2();
                  }
                }),
          );
        }
      }
      else {
        setState(() => _isListening2 = false);
        _speech2.stop();
      }
  }
  void _listen3() async{
    int n=10;
    for(int i=0; i<= n; i++){
      _listen2();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  timeDisplay,
                  style: TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.none,
                    fontFamily: 'digital-7',
                    fontSize: 60.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
                flex:2,
                child: RawMaterialButton(
                  elevation: 2.0,
                  fillColor: Colors.red,
                  onPressed: () {
                      _listen3();
                      player.play('wave1.mp3');
                    },
                  child: (
                      Icon(_isListening2 ? Icons.mic : Icons.mic_none)
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                )
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: stopPressed ? null : stopStopwatch,
                          color: Colors.orange[600],
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 15.0,
                          ),
                          child: Text(
                            "STOP",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        RaisedButton(
                          onPressed: resetPressed ? null : resetStopwatch,
                          color: Colors.green[600],
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical: 15.0,
                          ),
                          child: Text(
                            "RESET",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    RaisedButton(
                      onPressed: startPressed ? startStopwatch : null,
                      color: Colors.blue[600],
                      padding: EdgeInsets.symmetric(
                        horizontal: 80.0,
                        vertical: 20.0,
                      ),
                      child: Text(
                        "START",
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }
}
