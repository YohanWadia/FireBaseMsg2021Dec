import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_noti_v11/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging_noti_v11/redpage.dart';
import 'package:firebase_messaging_noti_v11/greenpage.dart';
import 'package:flutter/services.dart';

//I have used HealthDemo FIrebase project. If you try to send the notification from the console via the App's users in the Target section
//it will take really long... more than 5mins each time. But the TokenId method is really really fast. works faster.

//we mannually made an entry in the Manifest: that is under the "DefaultFirebaseNotificationChannel"... over here we set this channels id as our own
// channel'sID: "yos_channel_id". I also changed the icon to yosicon & added the .png to mipmap

//=======According to a video this was said....
// But until you dont run #Line XXX at least once, you wont get Heads Up notifications... the headsUp notis also
// require the channel to be made... until that HeadsUp notifications wont start. the foreground firebase never shows any noti... so #Line XXX
// can make that possible if you want.
//Also, default notis from the background never show heads up... but with LocalNotiPkg, entry in Manifest & #Line XXX....
// you will now automatically get HeadsUp even when app is background too... Its because #Line XXX was run at least once after the app was installed

//
// ===========according to https://firebase.flutter.dev/docs/messaging/notifications/#advanced-usage for Heads UP
// just add the line in the manifest overriding the "DefaultFirebaseNotificationChannel"...check the manifest file
// and when making the channel.. put "importance: Importance.max"... and headsUp should work.

//=====I have done an extra thing... instead of just making a notification channel and overriding it... everytime the app starts
// I first check if that channel 1st exists.. and only then override it!
//===========================
//please check the way i sent the notification from NODE server side on glitch project military-agreeable-dirigible




//Receive message when app is in background and has been terminated
//THIS IS THE TOP LEVEL HANDLER.. as it is outside the scope of main()
Future<void> backgroundHandler(RemoteMessage message) async{
  print("from the Background Handler Top Function()");
  print(message.data.toString());
  print(message.notification?.title);
  
}



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);//this has to be a TOP LEVEL METHOD
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( primarySwatch: Colors.blue, ),
      home:  MyHomePage(title: 'FirebaseMessaging Page'),
      routes: {
        "red": (_) => RedPage(),
        "green": (_) => GreenPage(),
      },
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //for TokenMonitoring
  Stream<String>? _tokenStream;


  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    LocalNotificationService.initialize(context);
    LocalNotificationService.wasChannelMade().then((value) {
      print("CHANNEL STATUS: $value");
      if(value==false){
        LocalNotificationService.createChannel().then((value) {print("Finished Creating");});
      }
    });

    //this gives you the message when the app returns from terminated state... its fired when the noti is clicked on... once again you by default
    //can never get a headsUp... but after #Line XXX has been executed even once you will automatically get a headsUp.
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      print("Back from Terminated state ============= ONTAP");
      if(message != null){
        print(message.notification?.body);
        print(message.notification?.title);
        print(message.data["route"]);
        print(message.data["xtra"]);
        print("Back from Terminated state xxxxxxxxxxxxxxx");

        final routeFromMessage = message.data["route"];
        Navigator.of(context).pushNamed(routeFromMessage);
      }
    });


    //forground work... this will only print to the console... you wont see or hear in the sysTray drawer
    FirebaseMessaging.onMessage.listen((message) {
      print("OnMessage()... fired when App is in an OPENED state");
      if(message.notification != null){
        print(message.notification?.body);
        print(message.notification?.title);
        print(message.data["xtra"] );
      }

      //...But if you still want it to ring with a heads up.. use the code below from the localNotificationsPkg
      //LocalNotificationService.display(message);//#Line XXX
    });

    //When the app is in background but opened(eg Minimized) and user taps on the notification... But still it wont show you a headsUp... it
    //will be a notification in the sysTray... BUT after you have encorprated LocalNotificationsPKG and run code at #Line XXX: a channel also
    //got set up... and now this will display as a headsUp too!
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("notification of MINIMIZED app state just TAPPED============");
      print(message.notification?.body);
      print(message.notification?.title);
      print(message.data["route"]);
      print(message.data["xtra"]);

      final routeFromMessage = message.data["route"] ;
      Navigator.of(context).pushNamed(routeFromMessage);
    });


    //forToken monitoring
    FirebaseMessaging.instance.getToken().then((token)=>{print("TOKEN: $token")});//how to get the token
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;//this is for incase it changes, how to listen to it for changes
    _tokenStream?.listen((token)=>{print("NEW REFRESHED TOKEN: $token")});

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
            child: Text(
              "You will receive message soon",
              style: TextStyle(fontSize: 34),
            )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()async{LocalNotificationService.getNotificationChannelsInfo();},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }


//==========================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



}






