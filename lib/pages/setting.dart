import 'package:dttube/pages/commonpage.dart';
import 'package:dttube/pages/history.dart';
import 'package:dttube/pages/likevideos.dart';
import 'package:dttube/pages/login.dart';
import 'package:dttube/pages/musicdetails.dart';
import 'package:dttube/pages/myplaylist.dart';
import 'package:dttube/pages/notificationpage.dart';
import 'package:dttube/pages/profile.dart';
import 'package:dttube/provider/generalprovider.dart';
import 'package:dttube/provider/profileprovider.dart';
import 'package:dttube/subscription/subscription.dart';
import 'package:dttube/provider/settingprovider.dart';
import 'package:dttube/utils/adhelper.dart';
import 'package:dttube/utils/constant.dart';
import 'package:dttube/utils/dimens.dart';
import 'package:dttube/utils/sharedpre.dart';
import 'package:dttube/utils/utils.dart';
import 'package:dttube/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:dttube/pages/rent.dart';
import 'package:dttube/pages/watchlater.dart';
import 'package:dttube/utils/color.dart';
import 'package:dttube/widget/myimage.dart';
import 'package:dttube/widget/mytext.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double? width, height;
  late SettingProvider settingProvider;
  late GeneralProvider generalProvider;
  String? userName, userType, userMobileNo;
  final playlistTitleController = TextEditingController();
  bool isPublic = false;
  bool isPrivate = false;
  String playlistType = "0";
  SharedPre sharedPref = SharedPre();
  final passwordController = TextEditingController();

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    getUserData();
    super.initState();
    getApi();
  }

  getApi() async {
    await settingProvider.getprofile(Constant.userID);
    await settingProvider.getPages();
  }

  getUserData() async {
    userName = await sharedPref.read("username");
    userType = await sharedPref.read("usertype");
    userMobileNo = await sharedPref.read("usermobile");
    debugPrint('getUserData userName ==> $userName');
    debugPrint('getUserData userType ==> $userType');
    debugPrint('getUserData userMobileNo ==> $userMobileNo');

    await settingProvider.getPages();

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        elevation: 0,
        centerTitle: false,
        title: MyText(
            color: white,
            text: "setting",
            multilanguage: true,
            textalign: TextAlign.center,
            fontsize: Dimens.textBig,
            inter: false,
            maxline: 1,
            fontwaight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Profile Page */
            settingItem("ic_user.png", "myprofile", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Profile(
                          isProfile: true,
                          channelUserid: "",
                          channelid: "",
                        );
                      },
                    ),
                  );
                }
              });
            }),
            /* history Page */
            settingItem("history.png", "history", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const History();
                      },
                    ),
                  );
                }
              });
            }),
            TextButton(
                onPressed: () {
                  _showPaymentMethodDialog(context);
                  // var uuid = Uuid();
                  // final uniqueTransRef = uuid.v4();

                  // PayWithPayStack().now(
                  //   context: context,
                  //   secretKey:
                  //       "sk_test_e3f5183a6c6215a055f53ed9582e95c6c12751e2",
                  //   customerEmail: "popekabu@gmail.com",
                  //   reference: uniqueTransRef,
                  //   currency: "GHS",
                  //   amount:
                  //       "20000", // Amount in smallest unit (e.g., 20000 kobo = 200 GHS)
                  //   callbackUrl: "https://google.com",
                  //   transactionCompleted: () {
                  //     // Handle transaction completion
                  //     debugPrint("Transaction completed successfully!");
                  //   },
                  //   transactionNotCompleted: () {
                  //     // Handle transaction failure
                  //     debugPrint("Transaction was not completed.");
                  //   },
                  // );
                },
                child: const Text(
                  "Pay With PayStack",
                  style: TextStyle(fontSize: 23),
                )),
            /* Notification Page */
            settingItem("notification.png", "notification", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const NotificationPage();
                      },
                    ),
                  );
                }
              });
            }),
            /* subscription Page */
            settingItem("ic_subscription.png", "subscription", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Subscription();
                    },
                  ),
                );
              });
            }),

            /* rent Page */
            settingItem("rent.png", "rent", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Rent();
                      },
                    ),
                  );
                }
              });
            }),
            /* myplaylist Page */
            settingItem("ic_playlisttitle.png", "myplaylist", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const MyPlayList();
                      },
                    ),
                  );
                }
              });
            }),
            /* watchlater Page */
            settingItem("ic_watchlater.png", "watchlater", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const WatchLater();
                      },
                    ),
                  );
                }
              });
            }),
            /* likevideos Page */
            settingItem("heart.png", "likevideos", false, () {
              AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
                if (Constant.userID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Login();
                      },
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LikeVideos();
                      },
                    ),
                  );
                }
              });
            }),
            /* Get Pages Api*/
            buildPages(),
            /* UserPanel Dilog Sheet */
            Consumer<SettingProvider>(
                builder: (context, profileprovider, child) {
              if (Constant.userID == null) {
                return const SizedBox.shrink();
              } else {
                if (profileprovider.loading) {
                  return const SizedBox.shrink();
                } else {
                  return settingItem("userpanel.png", "userpanel", false, () {
                    debugPrint("userpanal==>${Constant.userPanelStatus}");
                    if (Constant.userPanelStatus == "0" ||
                        Constant.userPanelStatus == "" ||
                        Constant.userPanelStatus == null) {
                      userPanelActiveDilog();
                    } else {
                      edituserPanelDilog();
                    }
                  });
                }
              }
            }),
            // /* chooselanguage Bottom Sheet */
            settingItem("ic_link.png", "chooselanguage", false, () {
              _languageChangeDialog();
            }),
            /* Login Logout */
            settingItem("ic_logout.png",
                Constant.userID != null ? "logout" : "login", false, () {
              Constant.userID != null
                  ? logoutConfirmDialog()
                  : Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
            }),

            Utils.miniPlayerSpace(),
          ],
        ),
      ),
    );
  }

  Widget buildPages() {
    return Consumer<SettingProvider>(
        builder: (context, settingprovider, child) {
      return ListView.builder(
          itemCount: settingprovider.getpagesModel.result?.length ?? 0,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return settingItem(
                settingprovider.getpagesModel.result?[index].icon.toString() ??
                    "",
                settingprovider.getpagesModel.result?[index].title.toString() ??
                    "",
                true, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Commonpage(
                      title: settingprovider.getpagesModel.result?[index].title
                              .toString() ??
                          "",
                      url: settingprovider.getpagesModel.result?[index].title
                                  .toString() ==
                              "Youth Page Website"
                          ? "https://youthpagenetwork.online/"
                          : settingprovider.getpagesModel.result?[index].title
                                      .toString() ==
                                  "Be Youth page investor"
                              ? "https://youthpagenetwork.online/investor.html"
                              : settingprovider
                                          .getpagesModel.result?[index].title
                                          .toString() ==
                                      "Work From Home"
                                  ? "https://youthpagenetwork.online/service.html"
                                  : settingprovider.getpagesModel.result?[index]
                                              .title
                                              .toString() ==
                                          "Contact Adminstrator"
                                      ? "https://youthpagenetwork.online/contact.html"
                                      : settingprovider
                                              .getpagesModel.result?[index].url
                                              .toString() ??
                                          "",
                    );
                  },
                ),
              );
            });
          });
    });
  }

  Widget settingItem(String imagepath, String title, bool isPages, onTap) {
    return InkWell(
      hoverColor: colorAccent,
      highlightColor: colorAccent,
      autofocus: true,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          children: [
            isPages == true
                ? MyNetworkImage(
                    width: 30,
                    height: 30,
                    imagePath: imagepath ==
                            "https://youthpagenetwork.online/admin/public/assets/imgs/no_img.png"
                        ? "https://i.ibb.co/pnndVKv/image-removebg-preview.png"
                        : imagepath,
                    color: white,
                    isPagesIcon: true,
                    fit: BoxFit.cover,
                  )
                : MyImage(
                    width: 30,
                    height: 30,
                    imagePath: imagepath ==
                            "https://youthpagenetwork.online/admin/public/assets/imgs/no_img.png"
                        ? "https://i.ibb.co/pnndVKv/image-removebg-preview.png"
                        : imagepath,
                    color: white,
                  ),
            const SizedBox(width: 15),
            MyText(
                color: white,
                text: title,
                textalign: TextAlign.left,
                fontsize: Dimens.textTitle,
                multilanguage: isPages == true ? false : true,
                inter: false,
                maxline: 2,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ],
        ),
      ),
    );
  }

  Widget languageItem(onTap, title) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        decoration: BoxDecoration(
          // color: colorAccent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(width: 1, color: colorAccent),
        ),
        alignment: Alignment.center,
        child: MyText(
            color: white,
            text: title,
            textalign: TextAlign.left,
            fontsize: 16,
            multilanguage: true,
            inter: false,
            maxline: 2,
            fontwaight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
    );
  }

  userPanelActiveDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 300,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorAccent.withOpacity(0.10),
            ),
            child: Consumer<SettingProvider>(
                builder: (context, settingprovider, child) {
              return Column(
                children: [
                  MyText(
                      color: white,
                      text: "userpanel",
                      textalign: TextAlign.center,
                      fontsize: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    obscureText: settingprovider.isPasswordVisible,
                    controller: passwordController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          color: white,
                          settingprovider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          settingprovider.passwordHideShow();
                        },
                      ),
                      hintText: "Give your User Panel Password",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      MyText(
                          color: white,
                          multilanguage: true,
                          text: "status",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 8),
                      MyText(
                          color: white,
                          multilanguage: false,
                          text: ":",
                          textalign: TextAlign.left,
                          fontsize: Dimens.textBig,
                          inter: true,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          settingprovider.selectUserPanel("on", true);
                          debugPrint("type==>${settingprovider.isActiveType}");
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: settingprovider.isUserpanelType == "on" &&
                                      settingprovider.isActive == true
                                  ? colorAccent
                                  : colorPrimaryDark,
                              shape: BoxShape.circle),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "on",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textTitle,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () {
                          settingprovider.selectUserPanel("off", true);
                          debugPrint("type==>${settingprovider.isActiveType}");
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: settingprovider.isUserpanelType == "off" &&
                                      settingprovider.isActive == true
                                  ? colorAccent
                                  : colorPrimaryDark,
                              shape: BoxShape.circle),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "off",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textTitle,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          settingprovider.clearUserPanel();
                          passwordController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textBig,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            if (passwordController.text.isEmpty) {
                              Utils.showSnackbar(
                                  context, "pleaseenteryourpassword");
                            } else if (passwordController.text.length != 6) {
                              Utils.showSnackbar(
                                  context, "passwordmustbesixcharecter");
                            } else if (settingprovider.isUserpanelType ==
                                "off") {
                              Utils.showSnackbar(
                                  context, "pleaseselectuserpanelstatus");
                            } else {
                              /* Userpanal Api */
                              await settingProvider.getActiveUserPanel(
                                  passwordController.text,
                                  settingprovider.isActiveType);
                              if (!mounted) return;
                              Navigator.pop(context);
                              settingprovider.clearUserPanel();
                              passwordController.clear();
                              Utils.showSnackbar(
                                  context, "userpanalactivesuccsessfully");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5,
                                )
                              ],
                            ),
                            child: MyText(
                                color: white,
                                multilanguage: true,
                                text: "active",
                                textalign: TextAlign.left,
                                fontsize: Dimens.textBig,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  edituserPanelDilog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorPrimaryDark,
          insetAnimationCurve: Curves.bounceInOut,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: MediaQuery.of(context).size.width * 0.90,
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorAccent.withOpacity(0.10),
            ),
            child: Consumer<SettingProvider>(
                builder: (context, settingprovider, child) {
              return Column(
                children: [
                  MyText(
                      color: white,
                      text: "changepassword",
                      textalign: TextAlign.center,
                      fontsize: Dimens.textExtraBig,
                      multilanguage: true,
                      inter: false,
                      maxline: 1,
                      fontwaight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal),
                  const SizedBox(height: 25),
                  TextField(
                    cursorColor: white,
                    obscureText: settingprovider.isPasswordVisible,
                    controller: passwordController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    style: Utils.googleFontStyle(1, Dimens.textBig,
                        FontStyle.normal, white, FontWeight.w500),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          color: white,
                          settingprovider.isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          settingprovider.passwordHideShow();
                        },
                      ),
                      hintText: "Give your User Panel Password",
                      hintStyle: Utils.googleFontStyle(1, Dimens.textBig,
                          FontStyle.normal, gray, FontWeight.w500),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: gray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        radius: 50,
                        autofocus: false,
                        onTap: () {
                          Navigator.pop(context);
                          passwordController.clear();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: colorAccent.withOpacity(0.40),
                                blurRadius: 10.0,
                                spreadRadius: 0.5, //New
                              )
                            ],
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "cancel",
                              textalign: TextAlign.left,
                              fontsize: Dimens.textBig,
                              inter: true,
                              maxline: 1,
                              fontwaight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            if (passwordController.text.isEmpty) {
                              Utils.showSnackbar(
                                  context, "pleaseenteryourpassword");
                            } else if (passwordController.text.length != 6) {
                              Utils.showSnackbar(
                                  context, "passwordmustbesixcharecter");
                            } else {
                              /* Userpanal Api */
                              await settingProvider.getActiveUserPanel(
                                  passwordController.text, "1");
                              if (!mounted) return;
                              Navigator.pop(context);
                              passwordController.clear();
                              Utils.showSnackbar(
                                  context, "passwordchangesuccsessfully");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAccent.withOpacity(0.40),
                                  blurRadius: 10.0,
                                  spreadRadius: 0.5,
                                )
                              ],
                            ),
                            child: MyText(
                                color: white,
                                multilanguage: true,
                                text: "edit",
                                textalign: TextAlign.left,
                                fontsize: Dimens.textBig,
                                inter: true,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  _languageChangeDialog() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: colorPrimaryDark,
                    padding: const EdgeInsets.all(23),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "selectlanguage",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsize: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),

                        /* English */
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "English",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('en');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Afrikaans */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Afrikaans",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('af');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Arabic */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Arabic",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('ar');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* German */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "German",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('de');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Spanish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Spanish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('es');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* French */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "French",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('fr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Gujarati */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Gujarati",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('gu');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Hindi */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Hindi",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('hi');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Indonesian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Indonesian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('id');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Dutch */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Dutch",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('nl');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Portuguese (Brazil) */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Portuguese (Brazil)",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('pt');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Albanian */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Albanian",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('sq');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Turkish */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Turkish",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('tr');
                                    Navigator.pop(context);
                                  },
                                ),

                                /* Vietnamese */
                                const SizedBox(height: 20),
                                _buildLanguage(
                                  langName: "Vietnamese",
                                  onClick: () {
                                    state(() {});
                                    LocaleNotifier.of(context)?.change('vi');
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguage({
    required String langName,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorAccent,
            width: .5,
          ),
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(5),
        ),
        child: MyText(
          color: white,
          text: langName,
          textalign: TextAlign.center,
          fontsize: Dimens.textTitle,
          multilanguage: false,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  logoutConfirmDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(0),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              color: colorPrimaryDark,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: "confirmsognout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsize: Dimens.textTitle,
                          fontwaight: FontWeight.bold,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 3),
                        MyText(
                          color: white,
                          text: "areyousurewanrtosignout",
                          multilanguage: true,
                          textalign: TextAlign.start,
                          fontsize: Dimens.textSmall,
                          fontwaight: FontWeight.w500,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildDialogBtn(
                          title: 'cancel',
                          isPositive: false,
                          isMultilang: true,
                          onClick: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 20),
                        _buildDialogBtn(
                          title: 'logout',
                          isPositive: true,
                          isMultilang: true,
                          onClick: () async {
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            await settingProvider.getLogout();
                            await profileProvider.clearProvider();
                            // Firebase Signout
                            await _auth.signOut();
                            await GoogleSignIn().signOut();
                            await Utils.setUserId(null);
                            audioPlayer.stop();
                            audioPlayer.pause();
                            if (!mounted) return;
                            // Utils.loadAds(context);
                            getUserData();
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((value) {
      if (!mounted) return;
      // Utils.loadAds(context);
      setState(() {});
    });
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isPositive ? colorAccent : transparent,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 0.5, color: white)),
        //  Utils.setBGWithBorder(
        //     isPositive ? primaryLight : transparentColor,
        //     isPositive ? transparentColor : otherColor,
        //     5,
        //     0.5),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsize: Dimens.textTitle,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Select Payment Method",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.payment, color: Colors.blue),
                  title: Text("Paystack"),
                  onTap: () {
                    Navigator.pop(context); // Close the dialog
                    _showPaystackDetailsDialog(context); // Show next dialog
                  },
                ),
              ),
              SizedBox(height: 8),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.credit_card, color: Colors.green),
                  title: Text("Skrill"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Other payment method selected"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showPaystackDetailsDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    String selectedCurrency = "GHS";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Enter Payment Details",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Currency Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCurrency,
                  decoration: InputDecoration(
                    labelText: "Currency",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: ["GHS", "NGN", "USD"]
                      .map((currency) => DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    selectedCurrency = value!;
                  },
                ),
                SizedBox(height: 16),

                // Email Input
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _processPaystackPayment(
                  context,
                  emailController.text,
                  selectedCurrency,
                );
              },
              child: Text("Proceed to Pay"),
            ),
          ],
        );
      },
    );
  }

  void _processPaystackPayment(
      BuildContext context, String email, String currency) {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email is required")));
      return;
    }

    var uuid = Uuid();
    final uniqueTransRef = uuid.v4();

    PayWithPayStack().now(
      context: context,
      secretKey: "sk_test_e3f5183a6c6215a055f53ed9582e95c6c12751e2",
      customerEmail: email,
      reference: uniqueTransRef,
      currency: currency,

      amount: "20000", // Amount in smallest unit (e.g., 20000 kobo = 200 GHS)
      callbackUrl: "https://google.com",
      transactionCompleted: () {
        debugPrint("Transaction completed!");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction completed successfully!")),
        );
      },
      transactionNotCompleted: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Transaction was not completed.")),
        );
      },
    );
  }
}
