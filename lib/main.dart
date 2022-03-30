import 'dart:async';

import 'package:eyebody/data/data.dart';
import 'package:eyebody/data/database.dart';
import 'package:eyebody/utils.dart';
import 'package:eyebody/view/body.dart';
import 'package:eyebody/view/food.dart';
import 'package:eyebody/view/workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {

  runApp(MyApp());
  tz.initializeTimeZones();

  const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel("fastcampus", "eyebody", "eyebody notification");
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      androidNotificationChannel);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  List<Food> todayFood = [];
  List<Workout> todayWorkout = [];
  List<EyeBody> todayEyeBody = [];
  CalendarController controller = CalendarController();

  final dbHelper = DatabaseHelper.instance;
  DateTime time = DateTime.now();

  void getHistories() async {
    int d = Utils.getFormatTime(time);

    todayFood = await dbHelper.queryFoodByDate(d);
    todayWorkout = await dbHelper.queryWorkoutByDate(d);
    todayEyeBody = await dbHelper.queryEyeBodyByDate(d);
    setState(() {

    });
  }

  Future<bool> initNotification() async {
    if(flutterLocalNotificationsPlugin == null){
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    }

    var initSettingAndroid = AndroidInitializationSettings("app_icon");
    var initiOS = IOSInitializationSettings();

    var initSetting = InitializationSettings(
        android: initSettingAndroid, iOS: initiOS
    );

    await flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: (payload) async {

        }
    );

    setScheduling();
    return true;

  }

  void getAllHistories() async {
    todayFood = await dbHelper.queryAllFood();
    todayWorkout = await dbHelper.queryAllWorkout();
    todayEyeBody = await dbHelper.queryAllEyeBody();
    setState(() {

    });
  }

  @override
  void initState() {
    getHistories();
    initNotification();
    super.initState();
  }

  void setScheduling() async{
    var android = AndroidNotificationDetails(
        "fastcampus", "eyebody", "eyebody notification",
        importance: Importance.max,
        priority: Priority.max);
    var ios = IOSNotificationDetails();

    NotificationDetails detail = NotificationDetails(
        iOS: ios,
        android: android
    );

    flutterLocalNotificationsPlugin.zonedSchedule(
        0, "오늘 다이어트를 기록해주세요!",
        "앱에서 기록을 알려주세요!!",
        tz.TZDateTime.from(DateTime.now().add(Duration(seconds: 10)), tz.local),
        detail,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: "eyebody",
        matchDateTimeComponents: DateTimeComponents.time
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: getPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "오늘"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "기록"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "통계"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_album_outlined),
              label: "갤러리"
          ),
        ],
        currentIndex: currentIndex,
        onTap: (idx){
          setState(() {
            currentIndex = idx;
            if(currentIndex == 0 || currentIndex == 1){
              time = DateTime.now();
              getHistories();
            }else if(currentIndex == 2 || currentIndex == 3){
              getAllHistories();
            }
          });
        },
      ),
      floatingActionButton: [2, 3].contains(currentIndex) ? Container() : FloatingActionButton(
        onPressed: (){
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              builder: (ctx){
                return SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      TextButton(child: Text("식단"),
                        onPressed: () async {
                          await Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => FoodAddPage(
                                food: Food(
                                    date: Utils.getFormatTime(time),
                                    kcal: 0,
                                    memo: "",
                                    type: 0,
                                    image: ""
                                ),
                              ))
                          );
                          getHistories();
                        },),
                      TextButton(child: Text("운동"),
                        onPressed: () async {
                          await Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => WorkoutAddPage(
                                workout: Workout(
                                    date: Utils.getFormatTime(time),
                                    time: 0,
                                    memo: "",
                                    name: "",
                                    image: ""
                                ),
                              ))
                          );
                          getHistories();

                        },),
                      TextButton(child: Text("눈바디"),
                        onPressed: () async {
                          await Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => EyeBodyAddPage(
                                eyeBody: EyeBody(
                                    date: Utils.getFormatTime(time),
                                    weight: 0,
                                    image: ""
                                ),
                              ))
                          );
                          getHistories();
                        },),
                    ],
                  ),
                );
              }
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  Widget getPage() {
    if(currentIndex == 0 ){
      return getMainPage();
    }else if(currentIndex == 1){
      return getHistoryPage();
    }else if(currentIndex == 2){
      return getChartPage();
    }else if(currentIndex == 3){
      return getGalleryPage();
    }
    return Container();
  }

  Widget getMainPage(){
    return Container(
      child: Column(
          children: [
            todayFood.isEmpty ? Container() : Container(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(todayFood.length, (idx){
                  return InkWell(child: Container(
                    width: 140,
                    child: FoodCard(food: todayFood[idx]),
                  ),
                    onTap: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => FoodAddPage(
                            food: todayFood[idx],
                          ))
                      );
                      getHistories();
                    },
                  );
                }),
              ),
            ),
            todayWorkout.isEmpty ? Container() : Container(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(todayWorkout.length, (idx){
                  return InkWell(child: Container(
                    width: 140,
                    child: WorkoutCard(workout: todayWorkout[idx]),
                  ),
                      onTap: () async {
                        await Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => WorkoutAddPage(
                              workout: todayWorkout[idx],
                            ))
                        );
                        getHistories();
                      }
                  );
                }),
              ),
            ),
            todayEyeBody.isEmpty ? Container() : Container(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(todayEyeBody.length, (idx){
                  return InkWell(child: Container(
                    width: 140,
                    child: EyeBodyCard(eyeBody: todayEyeBody[idx]),
                  ),
                    onTap: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => EyeBodyAddPage(
                            eyeBody: todayEyeBody[idx],
                          ))
                      );
                      getHistories();
                    },
                  );
                }),
              ),
            ),
          ]
      ),
    );
  }
  Widget getHistoryPage(){
    return Container(
      child: ListView(
        children: [
          TableCalendar(
            initialSelectedDay: time,
            calendarController: controller,
            onDaySelected: (date, events, holidays){
              time = date;
              getHistories();
            },
          ),
          getMainPage()
        ],
      ),
    );
  }
  Widget getChartPage(){
    return Container(
      child: Column(children: [
        getMainPage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("총 기록 식단 수\n${todayFood.length}"),
            Text("총 기록 운동 수\n${todayWorkout.length}"),
            Text("총 기록 눈바디 수\n${todayEyeBody.length}"),
          ],
        )
      ]),
    );
  }
  Widget getGalleryPage(){
    return Container(
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        children: List.generate(
            todayEyeBody.length, (idx){
          return EyeBodyCard(eyeBody: todayEyeBody[idx]);
        }
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final Food food;
  FoodCard({Key key, this.food}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.all(8),
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetThumb(asset: Asset(food.image, "food.png", 0, 0), width: 300, height: 300),
            ),
            Positioned.fill(
              child: Container(color: Colors.black38),
            ),
            Container(
              alignment: Alignment.center,
              child: Text("${["아침", "점심", "저녁", "간식"][food.type]}", style: TextStyle(color: Colors.white),),
            )
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  WorkoutCard({Key key, this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.all(8),
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetThumb(asset: Asset(workout.image, "food.png", 0, 0), width: 300, height: 300),
            ),
            Positioned.fill(
              child: Container(color: Colors.black38),
            ),
            Container(
              alignment: Alignment.center,
              child: Text("${workout.name}", style: TextStyle(color: Colors.white),),
            )
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class EyeBodyCard extends StatelessWidget {
  final EyeBody eyeBody;
  EyeBodyCard({Key key, this.eyeBody}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.all(8),
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AssetThumb(asset: Asset(eyeBody.image, "food.png", 0, 0), width: 300, height: 300),
            ),
            Positioned.fill(
              child: Container(color: Colors.black38),
            ),
            Container(
              alignment: Alignment.center,
              child: Text("${eyeBody.weight}kg", style: TextStyle(color: Colors.white),),
            )
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

