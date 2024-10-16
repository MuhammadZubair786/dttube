import 'dart:developer';

import 'package:dttube/pages/musicdetails.dart';
import 'package:dttube/provider/allcontentprovider.dart';
import 'package:dttube/provider/contentdetailprovider.dart';
import 'package:dttube/provider/galleryvideoprovider.dart';
import 'package:dttube/provider/getmusicbycategoryprovider.dart';
import 'package:dttube/provider/getmusicbylanguageprovider.dart';
import 'package:dttube/provider/historyprovider.dart';
import 'package:dttube/provider/likevideosprovider.dart';
import 'package:dttube/provider/musicdetailprovider.dart';
import 'package:dttube/provider/notificationprovider.dart';
import 'package:dttube/provider/playerprovider.dart';
import 'package:dttube/provider/playlistcontentprovider.dart';
import 'package:dttube/provider/playlistprovider.dart';
import 'package:dttube/provider/postvideoprovider.dart';
import 'package:dttube/provider/rentprovider.dart';
import 'package:dttube/provider/seeallprovider.dart';
import 'package:dttube/provider/settingprovider.dart';
import 'package:dttube/provider/subscriptionprovider.dart';
import 'package:dttube/provider/videopreviewprovider.dart';
import 'package:dttube/provider/videorecordprovider.dart';
import 'package:dttube/provider/videoscreenprovider.dart';
import 'package:dttube/provider/watchlaterprovider.dart';
import 'package:dttube/utils/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:dttube/firebase_options.dart';
import 'package:dttube/pages/splash.dart';
import 'package:dttube/provider/detailsprovider.dart';
import 'package:dttube/provider/generalprovider.dart';
import 'package:dttube/provider/homeprovider.dart';
import 'package:dttube/provider/searchprovider.dart';
import 'package:dttube/provider/profileprovider.dart';
import 'package:dttube/provider/musicprovider.dart';
import 'package:dttube/provider/updateprofileprovider.dart';
import 'package:dttube/utils/color.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'provider/shortprovider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Just Audio Player Background Service Set
  if (Constant.isBuy != null ||
      Constant.isBuy != "0" ||
      Constant.userID != null ||
      Constant.isBuy == "1") {
    // await JustAudioBackground.init(
    //   androidNotificationChannelId: Constant.appPackageName,
    //   androidNotificationChannelName: Constant.appName,
    //   androidNotificationOngoing: true,
    // );
  }

  await Firebase.initializeApp();

  await Locales.init([
    'en',
    'hi',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DetailsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => ShortProvider()),
        ChangeNotifierProvider(create: (_) => VideoScreenProvider()),
        ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => WatchLaterProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => LikeVideosProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ContentDetailProvider()),
        ChangeNotifierProvider(create: (_) => SeeAllProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByCategoryProvider()),
        ChangeNotifierProvider(create: (_) => GetMusicByLanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => RentProvider()),
        ChangeNotifierProvider(create: (_) => AllContentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistContentProvider()),
        ChangeNotifierProvider(create: (_) => VideoRecordProvider()),
        ChangeNotifierProvider(create: (_) => VideoPreviewProvider()),
        ChangeNotifierProvider(create: (_) => PostVideoProvider()),
        ChangeNotifierProvider(create: (_) => GalleryVideoProvider()),
      ],
      child: const MyApp(),
    ));
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: black,
      statusBarColor: colorPrimary,
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        log("App detached");
        audioPlayer.stop();
        audioPlayer.dispose();
        break;
      case AppLifecycleState.inactive:
        if (Constant.isBuy == null ||
            Constant.isBuy == "0" ||
            Constant.userID == null) {
          log("App inactive");
          audioPlayer.pause();
        }
        break;
      case AppLifecycleState.paused:
        if (Constant.isBuy == null ||
            Constant.isBuy == "0" ||
            Constant.userID == null) {
          log("App paused");
          audioPlayer.pause();
        }
        break;
      case AppLifecycleState.resumed:
        log("App resumed");
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: colorPrimary,
          primaryColorDark: colorPrimaryDark,
          primaryColorLight: colorPrimary,
          scaffoldBackgroundColor: colorPrimaryDark,
        ),
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        home: const Splash(),
      ),
    );
  }
}
