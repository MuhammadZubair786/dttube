import 'dart:developer';
import 'dart:io';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:dttube/pages/bottombar.dart';
import 'package:dttube/provider/homeprovider.dart';
import 'package:dttube/provider/postvideoprovider.dart';
import 'package:dttube/utils/color.dart';
import 'package:dttube/utils/dimens.dart';
import 'package:dttube/utils/sharedpre.dart';
import 'package:dttube/utils/utils.dart';
import 'package:dttube/webservice/apiservice.dart';
import 'package:dttube/widget/myimage.dart';
import 'package:dttube/widget/mynetworkimg.dart';
import 'package:dttube/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class PostVideoChannel extends StatefulWidget {
  final String? vDuration, soundId, contestId, hashtagName, hashtagId;
  final File videoFile;
  const PostVideoChannel(
      {required this.videoFile,
      required this.vDuration,
      required this.soundId,
      required this.contestId,
      required this.hashtagName,
      required this.hashtagId,
      super.key});

  @override
  State<PostVideoChannel> createState() => _PostVideoChannelState();
}

class _PostVideoChannelState extends State<PostVideoChannel> {
  late PostVideoProvider postVideoProvider;
  SharedPre sharePref = SharedPre();
  File? finalVideoFile;
  late ProgressDialog prDialog;
  String? imageFromVideo, userProfile;
  final mCommentController = TextEditingController();
  HomeProvider? homeProvider;
  int? selectedId;
  var categorydataList = [];

  @override
  void initState() {
    postVideoProvider = Provider.of<PostVideoProvider>(context, listen: false);
    finalVideoFile = widget.videoFile;
    prDialog = ProgressDialog(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
      getCategoryList();
    });
    super.initState();
  }

  _getData() async {
    userProfile = await sharePref.read("image");
    debugPrint("_getData userProfile ===> $userProfile");
    debugPrint("_getData videoFile ===> ${finalVideoFile?.path ?? ""}");
    await postVideoProvider.getThumbnailCovers(finalVideoFile);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  getCategoryList() async {
    var categorymodel = await ApiService().videoCategory(1);
    if (categorymodel.status == 200) {
      if (categorymodel.result != null &&
          (categorymodel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(categorymodel.result?.length ?? 0)}");
        if (categorymodel.result != null &&
            (categorymodel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(categorymodel.result?.length ?? 0)}");
          for (var i = 0; i < (categorymodel.result?.length ?? 0); i++) {
            categorydataList.add(categorymodel.result?[i]);
          }
          //   final Map<int, cat.Result> postMap = {};
          //   categorydataList?.forEach((item) {
          //     postMap[item.id ?? 0] = item;
          //   });
          //   categorydataList = postMap.values.toList();
          //   debugPrint("categoryList length :==> ${(categorydataList?.length ?? 0)}");
          //   setCategoryLoadMore(false);
          // }
        }
      }
    }
    setState(() {});
    categorydataList;
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.hashtagName ?? "").isNotEmpty) {
      if (mCommentController.text.toString().isEmpty) {
        mCommentController.text = (widget.hashtagName ?? "").contains("#")
            ? (widget.hashtagName ?? "")
            : "#${(widget.hashtagName ?? "")}";
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: colorPrimary,
        ),
        elevation: 0,
        centerTitle: false,
        leading: InkWell(
          onTap: () {
            // Navigator.pop(context);
            Navigator.of(context).pop(false);
            debugPrint("Back Click");
          },
          child: Align(
              alignment: Alignment.center,
              child: MyImage(
                  width: 30, height: 30, imagePath: "ic_roundback.png")),
        ),
        title: MyText(
            color: white,
            text: "Youth Channel Video Upload",
            textalign: TextAlign.left,
            fontsize: Dimens.textBig,
            multilanguage: false,
            inter: false,
            maxline: 2,
            fontwaight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* Profile Image & Video description */
                  _buildUserVideoDesc(),
                  const SizedBox(height: 40),

                  /* Select Cover */
                  MyText(
                    multilanguage: true,
                    color: white,
                    text: "selectcover",
                    fontsize: 15,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontwaight: FontWeight.w500,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(height: 12),
                  _buildCovers(),

                  /* Comment ON/OFF */
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   constraints: const BoxConstraints(
                  //     minHeight: 45,
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       MyText(
                  //         multilanguage: true,
                  //         color: white,
                  //         text: "comment_off",
                  //         fontsize: 15,
                  //         maxline: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         fontwaight: FontWeight.w500,
                  //         textalign: TextAlign.center,
                  //         fontstyle: FontStyle.normal,
                  //       ),
                  //       const SizedBox(width: 15),
                  //       Consumer<PostVideoProvider>(
                  //         builder: (context, postVideoProvider, child) {
                  //           return Switch(
                  //             activeColor: colorPrimary,
                  //             activeTrackColor: white,
                  //             inactiveTrackColor: gray,
                  //             value: postVideoProvider.isComment,
                  //             onChanged: postVideoProvider.toggleComment,
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Text(
                    "Select Category",
                    style: TextStyle(color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.black, // Background color
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      border: Border.all(
                          color: Colors.white, width: 1.5), // White border
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 8), // Padding for better UI
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        dropdownColor:
                            Colors.black, // Background color of dropdown menu
                        hint: Text(
                          "Select Category",
                          style: TextStyle(color: Colors.white), // White text
                        ),
                        value: selectedId,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedId = newValue;
                          });
                        },
                        icon: Icon(Icons.arrow_drop_down,
                            color: Colors.white), // White arrow icon
                        items: categorydataList.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: SizedBox(
                              width: 150, // Prevent text overflow
                              child: Text(
                                category.name,
                                overflow: TextOverflow
                                    .ellipsis, // Ellipsis for long text
                                softWrap: false,
                                style: TextStyle(
                                    color: Colors.white), // White text
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  /* Save Gallery ON/OFF */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(
                      minHeight: 45,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          multilanguage: true,
                          color: white,
                          text: "save_to_gallery",
                          fontsize: 15,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(width: 15),
                        Consumer<PostVideoProvider>(
                          builder: (context, postVideoProvider, child) {
                            return Switch(
                              activeColor: colorPrimary,
                              activeTrackColor: white,
                              inactiveTrackColor: gray,
                              value: postVideoProvider.isSaveGallery,
                              onChanged: postVideoProvider.toggleGallery,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          /* Post Video Button */
          Container(
            margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
            alignment: Alignment.bottomCenter,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                // getCategoryList();
                //  log(data.result..toString());
                validateAndUpload();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyImage(
                      width: 25,
                      height: 20,
                      imagePath: "ic_upload.png",
                      fit: BoxFit.cover,
                      color: black,
                    ),
                    const SizedBox(width: 8),
                    MyText(
                      multilanguage: true,
                      color: black,
                      text: "postvideo",
                      fontsize: 17,
                      fontwaight: FontWeight.w700,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      textalign: TextAlign.center,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(width: 15),
                    Consumer<PostVideoProvider>(
                        builder: (context, postvideoprovider, child) {
                      if (postvideoprovider.uploadLoading) {
                        return SizedBox(
                          width: 25,
                          height: 25,
                          child: Utils.pageLoader(context),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserVideoDesc() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints(
        minHeight: 100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: white, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: MyNetworkImage(
                width: 55,
                height: 55,
                imagePath: userProfile ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 130,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                // decoration: Utils.r10BGWithBorder(),
                child: DetectableTextField(
                  detectionRegExp: detectionRegExp(
                          hashtag: true, atSign: false, url: false) ??
                      RegExp(""),
                  controller: mCommentController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "title",
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      color: gray,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                    border: InputBorder.none,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: white, width: 1),
                    ),
                  ),
                  decoratedStyle: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: colorPrimary,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  basicStyle: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: white,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCovers() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      child: Consumer<PostVideoProvider>(
        builder: (context, postVideoProvider, child) {
          if (postVideoProvider.loading) {
            return Utils.pageLoader(context);
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick1");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail1 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick1"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick2");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail2 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick2"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.passthrough,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          await postVideoProvider.setCoverTick("tick3");
                        },
                        child: _buildCoverItem(
                            thumbnail: postVideoProvider.thumbnail3 ?? ""),
                      ),
                      postVideoProvider.coverTick == "tick3"
                          ? _buildTick()
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCoverItem({required String thumbnail}) {
    debugPrint("thumbnail ---------------> $thumbnail");
    if (thumbnail != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(thumbnail),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: MyNetworkImage(
          fit: BoxFit.cover,
          imagePath: '',
        ),
      );
    }
  }

  Widget _buildTick() {
    return SizedBox(
      width: 25,
      height: 25,
      child: MyImage(
        imagePath: "true.png",
        fit: BoxFit.contain,
        height: 20,
        width: 20,
      ),
    );
  }

  validateAndUpload() async {
    String videoDesc = mCommentController.text.toString().trim();
    File? finalThumbnail;
    debugPrint("videoDesc ==> $videoDesc");
    if (videoDesc.isEmpty) {
      Utils.showSnackbar(context, "pleaseentervideotitle");
      return;
    }
    if (postVideoProvider.coverTick == "tick1") {
      finalThumbnail = File(postVideoProvider.thumbnail1 ?? "");
    } else if (postVideoProvider.coverTick == "tick2") {
      finalThumbnail = File(postVideoProvider.thumbnail2 ?? "");
    } else if (postVideoProvider.coverTick == "tick3") {
      finalThumbnail = File(postVideoProvider.thumbnail3 ?? "");
    }

    debugPrint("videoFile ==> ${finalVideoFile?.path}");
    if (postVideoProvider.isSaveGallery) {
      postVideoProvider.saveInGallery(finalVideoFile?.path ?? "");
    }
    debugPrint("finalThumbnail ===> ${finalThumbnail?.path ?? ""}");
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: colorAccent,
          content: MyText(
            text: "Select Video Category",
            multilanguage: false,
            fontsize: 14,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            fontstyle: FontStyle.normal,
            fontwaight: FontWeight.w500,
            color: white,
            textalign: TextAlign.center,
          ),
        ),
      );
      return;
    }
    await postVideoProvider.uploadNewVideoChannel(
        videoDesc, finalVideoFile, finalThumbnail, selectedId);
    if (!mounted) return;

    if (postVideoProvider.successModel.status == 200) {
      Utils.showSnackbar(context, "videouploadsuccsessfully");
    } else {
      Utils.showSnackbar(
        context,
        "videouploadfail",
      );
    }
    postVideoProvider.clearProvider();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const Bottombar(),
      ),
      (Route<dynamic> route) => false,
    );
  }
}
