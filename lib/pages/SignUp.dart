// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dttube/pages/login.dart';
import 'package:dttube/pages/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:dttube/pages/bottombar.dart';
import 'package:dttube/provider/generalprovider.dart';
import 'package:dttube/utils/color.dart';
import 'package:dttube/utils/constant.dart';
import 'package:dttube/utils/sharedpre.dart';
import 'package:dttube/utils/utils.dart';
import 'package:dttube/widget/myimage.dart';
import 'package:dttube/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final numberController = TextEditingController();
  String mobilenumber = "", countrycode = "";
  File? mProfileImg;
  bool isagreeCondition = false;
  String? strDeviceType, strDeviceToken;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final PasswordController = TextEditingController();
  final EmailController = TextEditingController();

  var loading=false;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
  }

   _login(String mobile,String email, String firebaseId) async {
    debugPrint("click on Submit mobile =====> $mobile");
    debugPrint("click on Submit firebaseId => $firebaseId");
    final generalProvider =
        Provider.of<GeneralProvider>(context, listen: false);
    // Utils.showProgress(context);
    await generalProvider.login(
        "1", email, mobile, strDeviceType ?? "", strDeviceToken ?? "");
    debugPrint('test');
    if (!generalProvider.loading) {
      if (!mounted) return;
      log('Loading');
      // Utils().hideProgress(context);
      debugPrint('test');
      if (generalProvider.loginModel.status == 200) {
        debugPrint(
            'loginRegisterModel ==>> ${generalProvider.loginModel.toString()}');
        debugPrint('Login Successfull!');
        /* Save Users Credentials */
        await sharedPre.save(
            "userid", generalProvider.loginModel.result?[0].id.toString());
        await sharedPre.save("channelid",
            generalProvider.loginModel.result?[0].channelId.toString());
        await sharedPre.save("channelname",
            generalProvider.loginModel.result?[0].channelName.toString());
        await sharedPre.save("fullname",
            generalProvider.loginModel.result?[0].fullName.toString());
        await sharedPre.save(
            "email", generalProvider.loginModel.result?[0].email.toString());
        await sharedPre.save("mobilenumber",
            generalProvider.loginModel.result?[0].mobileNumber.toString());
        await sharedPre.save(
            "image", generalProvider.loginModel.result?[0].image.toString());
        await sharedPre.save("coverimage",
            generalProvider.loginModel.result?[0].coverImg.toString());
        await sharedPre.save(
            "type", generalProvider.loginModel.result?[0].type.toString());
        await sharedPre.save("desciption",
            generalProvider.loginModel.result?[0].description.toString());
        await sharedPre.save("devicetype",
            generalProvider.loginModel.result?[0].deviceType.toString());
        await sharedPre.save("address",
            generalProvider.loginModel.result?[0].address.toString());
        await sharedPre.save("website",
            generalProvider.loginModel.result?[0].website.toString());
        await sharedPre.save("instagramUrl",
            generalProvider.loginModel.result?[0].instagramUrl.toString());
        await sharedPre.save("facebookUrl",
            generalProvider.loginModel.result?[0].facebookUrl.toString());
        await sharedPre.save("twitterUrl",
            generalProvider.loginModel.result?[0].twitterUrl.toString());
        await sharedPre.save("devicetoken",
            generalProvider.loginModel.result?[0].deviceToken.toString());
        await sharedPre.save(
            "status", generalProvider.loginModel.result?[0].status.toString());
        await sharedPre.save("createat",
            generalProvider.loginModel.result?[0].createdAt.toString());
        await sharedPre.save("updateat",
            generalProvider.loginModel.result?[0].updatedAt.toString());
        await sharedPre.save("userIsBuy",
            generalProvider.loginModel.result?[0].isBuy.toString());
        // Set UserID With Chennal ID for Next
        Constant.userID = generalProvider.loginModel.result?[0].id.toString();
        Constant.isBuy = generalProvider.loginModel.result?[0].isBuy.toString();
        Utils.updatePremium(
            generalProvider.loginModel.result?[0].isBuy.toString() ?? "");
        Constant.channelID =
            generalProvider.loginModel.result?[0].channelId.toString() ?? "";

        debugPrint('Constant userID ==>> ${Constant.userID}');
        debugPrint('Constant ChannelId ==>> ${Constant.channelID}');

          setState(() {
                                loading=false;
                              });

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottombar()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        log('error');
         setState(() {
                                loading=false;
                              });
        Utils.showSnackbar(context, "Error");
      }
    }
  }


  _getDeviceToken() async {
    try {
      if (Platform.isAndroid) {
        strDeviceType = "1";
        strDeviceToken = await FirebaseMessaging.instance.getToken();
      } else {
        strDeviceType = "2";
        strDeviceToken = OneSignal.User.pushSubscription.id.toString();
      }
    } catch (e) {
      debugPrint("_getDeviceToken Exception ===> $e");
    }
    debugPrint("===>strDeviceToken $strDeviceToken");
    debugPrint("===>strDeviceType $strDeviceType");
  }

  Future<void> signUp() async {
    String email = EmailController.text.trim();
    String password = PasswordController.text.trim();
    String phoneNumber = numberController.text.trim();

    try {
      // Check if the email already exists
      var emailSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Check if the phone number already exists
      var phoneSnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (emailSnapshot.docs.isNotEmpty) {
        showMessage('The email is already registered.');
          setState(() {
                                loading=false;
                              });
        return;
      }

      if (phoneSnapshot.docs.isNotEmpty) {
        showMessage('The phone number is already registered.');
            setState(() {
                                loading=false;
                              });
        return;
      }

      // Create a new user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'phoneNumber': phoneNumber,
        'uid': userCredential.user!.uid,
        'createdAt': Timestamp.now(),
      });

      showMessage('Sign up successful!');
         _login(
          phoneNumber, email,userCredential.user?.uid.toString() ?? "");
        
    } catch (e) {

      showMessage('Error: ${e.toString()}');
          setState(() {
                                loading=false;
                              });
    }
  }

  void showMessage(String message) {
   

     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorAccent,
        content: MyText(
          text: message,
          multilanguage: false,
          fontsize: 14,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal,
          fontwaight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: colorPrimary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
                      alignment: Alignment.bottomCenter,
                      child: MyImage(
                          width: MediaQuery.of(context).size.width * 0.60,
                          height: MediaQuery.of(context).size.height * 0.25,
                          imagePath: "ic_appicon.png"),
                    ),
                    Positioned.fill(
                      top: 35,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: MyImage(
                                width: 30,
                                height: 30,
                                imagePath: "ic_roundback.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.90,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: colorPrimaryDark,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                            color: white,
                            text: "Welcome",
                            textalign: TextAlign.center,
                            fontsize: 20,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        MyText(
                            color: white,
                            text: "Create a Account",
                            textalign: TextAlign.center,
                            fontsize: 16,
                            multilanguage: false,
                            inter: false,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: TextFormField(
                  controller: EmailController,
                  autovalidateMode: AutovalidateMode.disabled,
                  style: Utils.googleFontStyle(
                    4, 16, FontStyle.normal, white, FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                                 keyboardType: TextInputType.text,

                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorPrimaryDark,
                    border: InputBorder.none,
                    hintStyle: Utils.googleFontStyle(
                      4, 14, FontStyle.normal, white, FontWeight.w500,
                    ),
                    hintText: "Email Address",
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                  ),
                  
                                ),
                              ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                                  SizedBox(
                                height: MediaQuery.of(context).size.height * 0.07,
                                child: TextFormField(
                  controller: PasswordController,
                  autovalidateMode: AutovalidateMode.disabled,
                  style: Utils.googleFontStyle(
                    4, 16, FontStyle.normal, white, FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                 keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorPrimaryDark,
                    border: InputBorder.none,
                    hintStyle: Utils.googleFontStyle(
                      4, 14, FontStyle.normal, white, FontWeight.w500,
                    ),
                    hintText: "Password ",
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                  ),
                  
                                ),
                              ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        /* Send OTP Continue Button Text  */
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: IntlPhoneField(
                            disableLengthCheck: true,
                            textAlignVertical: TextAlignVertical.center,
                            autovalidateMode: AutovalidateMode.disabled,
                            controller: numberController,
                            style: Utils.googleFontStyle(
                                4, 16, FontStyle.normal, white, FontWeight.w500),
                            showCountryFlag: false,
                            showDropdownIcon: false,
                            initialCountryCode: "IN",
                            dropdownTextStyle: Utils.googleFontStyle(
                                4, 16, FontStyle.normal, white, FontWeight.w500),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colorPrimaryDark,
                              border: InputBorder.none,
                              hintStyle: Utils.googleFontStyle(
                                  4, 14, FontStyle.normal, white, FontWeight.w500),
                              hintText: "Mobile Number",
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: white, width: 1),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: white, width: 1),
                              ),
                            ),
                            onChanged: (phone) {
                              mobilenumber = phone.completeNumber;
                              log('mobile number===>mobileNumber $mobilenumber');
                            },
                            onCountryChanged: (country) {
                              countrycode = "+${country.dialCode.toString()}";
                              log('countrycode===> $countrycode');
                            },
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        /* Send OTP Continue Button Text  */

                        loading==true?
                        Center(
      child: SizedBox(
        width: 40,
        height: 40,
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return SweepGradient(
              colors: [
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.red,
              ],
              stops: [0.2, 0.4, 0.6, 0.8],
            ).createShader(bounds);
          },
          child: CircularProgressIndicator(
            strokeWidth: 4.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    ):
                        InkWell(
                          onTap: () {
                             if (EmailController.text.toString().isEmpty) {
                             showMessage('The Email is not Empty.');
                            }
                            else if (PasswordController.text.toString().isEmpty) {
                                                        showMessage('The Password is not Empty.');

                            }
                           else if (numberController.text.toString().isEmpty) {
                              Utils.showSnackbar(
                                  context, "pleaseenteryourmobilenumber");
                            } else if (isagreeCondition != true) {
                              Utils.showSnackbar(
                                  context, "pleaseaccepttermsandcondition");
                            } else {
                              // Navigator.of(context).push(
                              //   MaterialPageRoute(
                              //     builder: (context) => Otp(number: mobilenumber),
                              //   ),
                              // );
                              setState(() {
                                loading=true;
                              });
                              signUp();
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.06,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MyText(
                                color: white,
                                text: "continue",
                                textalign: TextAlign.center,
                                fontsize: 16,
                                inter: false,
                                maxline: 1,
                                multilanguage: true,
                                fontwaight: FontWeight.w400,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        /* Accept Terms & Consition */
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Theme(
                              data: ThemeData(
                                unselectedWidgetColor: white,
                              ),
                              child: Checkbox(
                                value: isagreeCondition,
                                activeColor: colorAccent,
                                checkColor: white,
                                onChanged: (bool? isagreeCondition) {
                                  setState(() {
                                    this.isagreeCondition = isagreeCondition!;
                                  });
                                  log("value== $isagreeCondition");
                                },
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    MyText(
                                        color: white,
                                        text: "termconditionfirst",
                                        textalign: TextAlign.center,
                                        fontsize: 12,
                                        multilanguage: true,
                                        inter: false,
                                        maxline: 1,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    MyText(
                                        color: colorAccent,
                                        text: "terms",
                                        textalign: TextAlign.center,
                                        fontsize: 12,
                                        multilanguage: true,
                                        inter: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                    MyText(
                                        color: colorAccent,
                                        text: "condition",
                                        textalign: TextAlign.center,
                                        fontsize: 12,
                                        multilanguage: true,
                                        inter: false,
                                        maxline: 2,
                                        fontwaight: FontWeight.w400,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal),
                                  ],
                                ),
                                MyText(
                                    color: colorAccent,
                                    text: "privacy_policy",
                                    textalign: TextAlign.left,
                                    fontsize: 12,
                                    multilanguage: true,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        /* OR Text  */
                        Align(
                          alignment: Alignment.center,
                          child: MyText(
                              color: white,
                              text: "or",
                              textalign: TextAlign.center,
                              fontsize: 16,
                              inter: false,
                              multilanguage: true,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /* Google Signin Button */
                            InkWell(
                              onTap: () {
                                if (isagreeCondition == true) {
                                  gmailLogin();
                                  log("Gmail login ======>>>>>");
                                } else {
                                  Utils.showSnackbar(
                                      context, "pleaseaccepttermsandcondition");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: black),
                                child: MyImage(
                                    width: 27,
                                    height: 27,
                                    imagePath: "ic_google.png"),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.05),
                            /* Apple Signin Button */
                            Platform.isIOS
                                ? InkWell(
                                    onTap: () {
                                      if (isagreeCondition == true) {
                                        signInWithApple();
                                      } else {
                                        Utils.showSnackbar(context,
                                            "pleaseaccepttermsandcondition");
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle, color: black),
                                      child: MyImage(
                                          width: 27,
                                          height: 27,
                                          imagePath: "ic_apple.png"),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                         SizedBox(height:20),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                    color: Colors.red,
                                    text: "Already have an Account?",
                                    textalign: TextAlign.left,
                                    fontsize: 12,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.01),
                                MyText(
                                    color: white,
                                    text: "Login",
                                    textalign: TextAlign.left,
                                    fontsize: 12,
                                    multilanguage: false,
                                    inter: false,
                                    maxline: 1,
                                    fontwaight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Login With Google
  Future<void> gmailLogin() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    GoogleSignInAccount user = googleUser;

    debugPrint('GoogleSignIn ===> id : ${user.id}');
    debugPrint('GoogleSignIn ===> email : ${user.email}');
    debugPrint('GoogleSignIn ===> displayName : ${user.displayName}');
    debugPrint('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

    if (!mounted) return;
    Utils.showProgress(context);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      debugPrint("User Name: ${userCredential.user?.displayName}");
      debugPrint("User Email ${userCredential.user?.email}");
      debugPrint("User photoUrl ${userCredential.user?.photoURL}");
      debugPrint("uid ===> ${userCredential.user?.uid}");
      String firebasedid = userCredential.user?.uid ?? "";
      debugPrint('firebasedid :===> $firebasedid');
      // Call Login Api
      if (!mounted) return;
      Utils.showProgress(context);
      checkAndNavigate(user.email, user.displayName ?? "", "", "", "2");
    } on FirebaseAuthException catch (e) {
      debugPrint('===>Exp${e.code.toString()}');
      debugPrint('===>Exp${e.message.toString()}');
      Utils().hideProgress(context);
    }
  }

  // Signin With Apple
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    debugPrint("Click Apple");
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      debugPrint(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      final displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';

      final firebaseUser = authResult.user;
      debugPrint("=================");

      final userEmail = '${firebaseUser?.email}';
      debugPrint("userEmail =====> $userEmail");
      debugPrint(firebaseUser?.email.toString());
      debugPrint(firebaseUser?.displayName.toString());
      debugPrint(firebaseUser?.photoURL.toString());
      debugPrint(firebaseUser?.uid);
      debugPrint("=================");

      final firebasedId = firebaseUser?.uid;
      debugPrint("firebasedId ===> $firebasedId");

      checkAndNavigate(userEmail, displayName.toString(), "", "", "3");
    } catch (exception) {
      debugPrint("Apple Login exception =====> $exception");
    }
    return null;
  }

  checkAndNavigate(
    String email,
    String userName,
    String profileImg,
    String password,
    String type,
  ) async {
    final loginItem = Provider.of<GeneralProvider>(context, listen: false);
    Utils.showProgress(
      context,
    );
    File? userProfileImg = await Utils.saveImageInStorage(profileImg);
    debugPrint("userProfileImg ===========> $userProfileImg");

    await loginItem.login(
        type, email, "", strDeviceType ?? "", strDeviceToken ?? "");

    debugPrint('checkAndNavigate loading ==>> ${loginItem.loading}');

    if (loginItem.loading) {
      if (!mounted) return;
      Utils.showProgress(context);
    } else {
      if (loginItem.loginModel.status == 200 &&
          loginItem.loginModel.result!.isNotEmpty) {
        await sharedPre.save(
            "userid", loginItem.loginModel.result?[0].id.toString());
        await sharedPre.save(
            "channelid", loginItem.loginModel.result?[0].channelId.toString());
        await sharedPre.save("channelname",
            loginItem.loginModel.result?[0].channelName.toString());
        await sharedPre.save(
            "fullname", loginItem.loginModel.result?[0].fullName.toString());
        await sharedPre.save(
            "email", loginItem.loginModel.result?[0].email.toString());
        await sharedPre.save("mobilenumber",
            loginItem.loginModel.result?[0].mobileNumber.toString());
        await sharedPre.save(
            "image", loginItem.loginModel.result?[0].image.toString());
        await sharedPre.save(
            "coverimage", loginItem.loginModel.result?[0].coverImg.toString());
        await sharedPre.save(
            "type", loginItem.loginModel.result?[0].type.toString());
        await sharedPre.save("desciption",
            loginItem.loginModel.result?[0].description.toString());
        await sharedPre.save("devicetype",
            loginItem.loginModel.result?[0].deviceType.toString());
        await sharedPre.save(
            "address", loginItem.loginModel.result?[0].address.toString());
        await sharedPre.save(
            "website", loginItem.loginModel.result?[0].website.toString());
        await sharedPre.save("instagramUrl",
            loginItem.loginModel.result?[0].instagramUrl.toString());
        await sharedPre.save("facebookUrl",
            loginItem.loginModel.result?[0].facebookUrl.toString());
        await sharedPre.save("twitterUrl",
            loginItem.loginModel.result?[0].twitterUrl.toString());
        await sharedPre.save("devicetoken",
            loginItem.loginModel.result?[0].deviceToken.toString());
        await sharedPre.save(
            "status", loginItem.loginModel.result?[0].status.toString());
        await sharedPre.save(
            "createat", loginItem.loginModel.result?[0].createdAt.toString());
        await sharedPre.save(
            "updateat", loginItem.loginModel.result?[0].updatedAt.toString());
        await sharedPre.save(
            "userIsBuy", loginItem.loginModel.result?[0].isBuy.toString());
        if (!mounted) return;

        // Set UserID With Chennal ID for Next
        Constant.userID = loginItem.loginModel.result?[0].id.toString() ?? "";
        Constant.isBuy = loginItem.loginModel.result?[0].isBuy.toString() ?? "";
        Utils.updatePremium(
            loginItem.loginModel.result?[0].isBuy.toString() ?? "");
        Constant.channelID =
            loginItem.loginModel.result?[0].channelId.toString() ?? "";
        debugPrint('Constant userID ===============>> ${Constant.userID}');
        debugPrint('ChannelID ===============>> ${Constant.channelID}');

        Utils().hideProgress(context);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Bottombar()),
            (Route route) => false);
      } else {
        if (!mounted) return;
        Utils().hideProgress(context);
      }
    }
  }
}
