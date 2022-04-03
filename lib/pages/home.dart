import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final localNotifications = FlutterLocalNotificationsPlugin();

Future<void> configureLocalTimeZone() async {
  tz.initializeTimeZones();
  //final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  //tz.setLocalLocation(tz.getLocation(timeZoneName));
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late String _userToDO = "";
  late DateTime _userDateTime = DateTime.utc(1900, 1, 1, 0, 0);
  DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  int taskID = 0;

  @override
  void initState() {
    super.initState();
  }

  getDate(Timestamp bdDateNotify){
    String dateNotify = "";
    if (bdDateNotify.toDate().year != 1900){
      dateNotify = bdDateNotify.toDate().toString();
    }
    return dateNotify;
  }

  getLatestDate(Timestamp bdLastDateNoty){
    DateTime dateNotify = DateTime.now();
    if (bdLastDateNoty.toDate().year != 1900){
      dateNotify = bdLastDateNoty.toDate();
    }
    return dateNotify;
  }

  isComplete(yesno){
    if (yesno) {
      return const Icon(Icons.check_box_outlined, color: Colors.teal);
    }
    else{
      return const Icon(Icons.check_box_outline_blank, color: Colors.teal);
    }
  }

  void showNotification(int id, String title, DateTime localtime) async {
    int notifyID = id;
    var notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
          'My channel id',
          'My channel',
          channelDescription: 'Description',
          channelShowBadge: true,
          priority: Priority.high,
          importance: Importance.max,
          icon: "timehascome",
        )
    );

    String body = DateFormat.yMMMd().format(localtime);

    if (localtime.isAfter(DateTime(1900, 1, 1))) {
      await localNotifications.zonedSchedule(
          notifyID,
          title,
          body,
          tz.TZDateTime.from(localtime, tz.local),
          notificationDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidAllowWhileIdle: true
      );

      setState(() {});
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
          title: const Text('Мой список дел'),
          centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.question_mark,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(context: context, builder: (BuildContext
              context) {
                return AlertDialog(
                    title: const Text('Как пользоваться приложением?'),
                    content: const Flexible(
                      child: Text(
                          'Для добавления новой задачи нажми на + в правом нижнем углу экрана. \n \n'
                              'Для каждой задачи можно установить время напоминания, тогда в нужное время приложение отправит напоминалку. '
                              'Уведомления будут приходить только для тех задач, которые помечены, как невыполненные.'
                              'Чтобы поставить или убрать пометку "выполнено" с задачи, совершите долгое нажатие на карточку с задачей.\n \n'
                              'Для редактирования задачи просто нажмите на ее карточку.\n \n'
                              'Удалить задачу можно, нажав иконку корзины справа от задачи или свайпнув ее влево или вправо.'),
                    ),
                    actions: [ElevatedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                        onPressed: (){
                          Navigator.of(context).pop();
                        }, child: const Text('Всё понятно!'))]
                );
                // do something
              }
              );
            }
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('missions').snapshots(),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text("Нет запланированных дел", style:TextStyle(color: Colors.white, fontSize: 26));
          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                    key: Key(snapshot.data!.docs[index].id),
                    child: Card(
                        child: InkWell(
                            onTap: (){
                              showDialog(context: context, builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Редактировать задачу'),
                                  content: TextFormField(
                                    initialValue: snapshot.data!.docs[index].get('description'),
                                    onChanged: (String value) {
                                      _userToDO = value;
                                    },
                                  ),
                                  actions:[
                                    ElevatedButton (
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                                      onPressed: () {
                                      Fluttertoast.showToast(
                                          msg:'Напоминание отключено',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.teal,
                                          textColor: Colors.white,
                                          fontSize: 20.0
                                      );
                                      _userDateTime = DateTime.utc(1900, 1, 1, 0, 0);
                                        },
                                      child: const Icon(Icons.alarm_off_outlined),
                                    ),
                                    ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                                        onPressed: (){
                                          DatePicker.showDateTimePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime(2022, 1, 1),
                                              maxTime: DateTime(2025, 12, 31),
                                              theme: const DatePickerTheme (
                                                  headerColor: Colors.teal,
                                                  backgroundColor: Colors.white60,
                                                  itemStyle: TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 16
                                                  ),
                                                  doneStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                                  cancelStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                              ),
                                              onConfirm: (date){
                                                _userDateTime = date;
                                              },
                                              currentTime: getLatestDate(snapshot.data!.docs[index].get('timeNoty')));
                                        }, child: const Icon(Icons.add_alarm)),
                                    ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                                        onPressed: (){
                                          _userToDO = "";
                                          Navigator.of(context).pop();
                                        }, child: const Text('Отмена')),
                                    ElevatedButton(
                                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                                        onPressed: (){
                                          if (_userToDO == ""){
                                            Map<String, dynamic> newdata = <String, dynamic>{
                                              "description": snapshot.data!.docs[index].get('description'),
                                              "timeNoty": _userDateTime
                                            };
                                            FirebaseFirestore.instance.collection('missions').doc(snapshot.data!.docs[index].id).update(newdata);
                                            Navigator.of(context).pop();
                                            localNotifications.cancel(snapshot.data!.docs[index].get('id'));
                                            showNotification(snapshot.data!.docs[index].get('id'), snapshot.data!.docs[index].get('description'), _userDateTime);
                                          }
                                          else {
                                            Map<String, dynamic> newdata = <String, dynamic>{
                                              "description": _userToDO,
                                              "timeNoty": _userDateTime
                                            };
                                            FirebaseFirestore.instance.collection('missions').doc(snapshot.data!.docs[index].id).update(newdata);
                                            Navigator.of(context).pop();
                                            localNotifications.cancel(snapshot.data!.docs[index].get('id'));
                                            showNotification(snapshot.data!.docs[index].get('id'), _userToDO, _userDateTime);
                                          }
                                        }, child: const Icon(Icons.save_outlined))
                                  ],
                                );
                              });},
                            onLongPress: (){
                              Map<String, dynamic> newdata = <String, dynamic>{
                                "completed": !snapshot.data!.docs[index].get('completed'),
                              };
                              FirebaseFirestore.instance.collection('missions').doc(snapshot.data!.docs[index].id).update(newdata);
                              localNotifications.cancel(snapshot.data!.docs[index].get('id'));
                              if (snapshot.data!.docs[index].get('completed') == false) {
                                showNotification(
                                    snapshot.data!.docs[index].get('id'),
                                    snapshot.data!.docs[index].get(
                                        'description'),
                                    snapshot.data!.docs[index].get('timeNoty'));
                              }
                              else {
                                showNotification(
                                    snapshot.data!.docs[index].get('id'),
                                    snapshot.data!.docs[index].get(
                                        'description'),
                                    DateTime.utc(1900, 1, 1, 0, 0));
                              }
                                },
                            child: ListTile(
                                title: Text(snapshot.data!.docs[index].get('description')),
                              leading: isComplete(snapshot.data!.docs[index].get('completed')),
                              subtitle: Text(getDate(snapshot.data!.docs[index].get('timeNoty')),
                                  style: const TextStyle(color: Colors.black45, fontSize: 15)),
                                trailing: IconButton(
                                  icon: const Icon(
                                      Icons.delete_sweep_outlined,
                                      color: Colors.teal
                                  ), onPressed: () {
                                  localNotifications.cancel(snapshot.data!.docs[index].get('id'));
                                  FirebaseFirestore.instance.collection('missions').doc(snapshot.data!.docs[index].id).delete();
                                },
                                ))
                        )
                    ),
                    onDismissed: (direction) {
                      localNotifications.cancel(snapshot.data!.docs[index].get('id'));
                      FirebaseFirestore.instance.collection('missions').doc(snapshot.data!.docs[index].id).delete();
                    }
                );
              }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Добавить дело'),
              content: TextField(
                onChanged: (String value) {
                  _userToDO = value;
                },
              ),
              actions:[
                ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                    onPressed: (){
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(2022, 1, 1),
                          maxTime: DateTime(2025, 12, 31),
                          theme: const DatePickerTheme (
                              headerColor: Colors.teal,
                              backgroundColor: Colors.white60,
                              itemStyle: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 16
                              ),
                              doneStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              cancelStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          onConfirm: (date){
                            _userDateTime = date;
                          },
                          currentTime: DateTime.now());
                    }, child: const Icon(Icons.add_alarm)),
                ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                    onPressed: (){
                      _userToDO = "";
                      Navigator.of(context).pop();
                    }, child: const Text('Отмена')),
                ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.teal)),
                    onPressed: (){
                      if (_userToDO == ""){
                        Fluttertoast.showToast(
                            msg:'Введите описание задачи',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      else {
                        taskID ++;
                        FirebaseFirestore.instance.collection('missions').add({
                          'id': taskID,
                          'description': _userToDO,
                          'timeNoty': _userDateTime,
                          'completed': false});
                        showNotification(taskID, _userToDO, _userDateTime);
                        _userToDO = "";
                        Navigator.of(context).pop();
                      }
                    }, child: const Text('Добавить'))
              ],
            );
          });
        },
        child: const Icon(
            Icons.add,
            color: Colors.white
        ),

      ),
    );
  }
}