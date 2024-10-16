import 'package:dttube/model/addremovecontenttoplaylistmodel.dart';
import 'package:dttube/model/addremovewatchlatermodel.dart';
import 'package:dttube/model/getcontentbychannelmodel.dart' as playlist;
import 'package:dttube/model/getcontentbychannelmodel.dart';
import 'package:dttube/model/getmusicbycategorymodel.dart' as music;
import 'package:dttube/model/getmusicbycategorymodel.dart';
import 'package:dttube/model/successmodel.dart';
import 'package:flutter/material.dart';
import 'package:dttube/webservice/apiservice.dart';

class GetMusicByCategoryProvider extends ChangeNotifier {
  GetMusicByCategoryModel getMusicByCategoryModel = GetMusicByCategoryModel();
  AddremoveWatchlaterModel addremoveWatchlaterModel =
      AddremoveWatchlaterModel();

  GetContentbyChannelModel getContentbyChannelModel =
      GetContentbyChannelModel();

  AddremoveContentToPlaylistModel addremoveContentToPlaylistModel =
      AddremoveContentToPlaylistModel();
  SuccessModel createPlaylistModel = SuccessModel();
  bool loading = false;

/* Music By category Field */
  List<music.Result>? musicList = [];
  bool loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  /* Get PlayList Field */
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistmorePage;
  List<playlist.Result>? playlistData = [];
  bool playlistLoading = false, playlistLoadmore = false;
  String playlistId = "";
  int? playlistPosition;
  bool isSelectPlaylist = false;
  int isType = 0;

  Future<void> getMusicbyCategory(categoryId, pageNo) async {
    loading = true;
    getMusicByCategoryModel =
        await ApiService().getMusicbyCategory(categoryId, pageNo);
    if (getMusicByCategoryModel.status == 200) {
      setPaginationData(
          getMusicByCategoryModel.totalRows,
          getMusicByCategoryModel.totalPage,
          getMusicByCategoryModel.currentPage,
          getMusicByCategoryModel.morePage);
      if (getMusicByCategoryModel.result != null &&
          (getMusicByCategoryModel.result?.length ?? 0) > 0) {
        debugPrint(
            "followingModel length :==> ${(getMusicByCategoryModel.result?.length ?? 0)}");
        debugPrint('Now on page ==========> $currentPage');
        if (getMusicByCategoryModel.result != null &&
            (getMusicByCategoryModel.result?.length ?? 0) > 0) {
          debugPrint(
              "followingModel length :==> ${(getMusicByCategoryModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (getMusicByCategoryModel.result?.length ?? 0);
              i++) {
            musicList
                ?.add(getMusicByCategoryModel.result?[i] ?? music.Result());
          }
          final Map<int, music.Result> postMap = {};
          musicList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          musicList = postMap.values.toList();
          debugPrint(
              "followFollowingList length :==> ${(musicList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  /* Watch Later */
  addremoveWatchLater(contenttype, contentid, episodeid, type) async {
    loading = true;
    addremoveWatchlaterModel = await ApiService()
        .addremoveWatchLater(contenttype, contentid, episodeid, type);
    loading = false;
    notifyListeners();
  }

/* Get Playlist Created By Perticular User Start */

  Future<void> getcontentbyChannel(
      userid, chennelId, contenttype, pageNo) async {
    debugPrint("Playlist Position :==> $playlistPosition");
    debugPrint("getPostList pageNo :==> $pageNo");
    playlistLoading = true;
    getContentbyChannelModel = await ApiService()
        .contentbyChannel(userid, chennelId, contenttype, pageNo);
    debugPrint(
        "getPlaylistList status :===> ${getContentbyChannelModel.status}");
    debugPrint(
        "getPlaylistList message :==> ${getContentbyChannelModel.message}");
    if (getContentbyChannelModel.status == 200) {
      setPlaylistPaginationData(
          getContentbyChannelModel.totalRows,
          getContentbyChannelModel.totalPage,
          getContentbyChannelModel.currentPage,
          getContentbyChannelModel.morePage);
      if (getContentbyChannelModel.result != null &&
          (getContentbyChannelModel.result?.length ?? 0) > 0) {
        debugPrint(
            "Playlist length first:==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        debugPrint(
            "Playlist length :==> ${(getContentbyChannelModel.result?.length ?? 0)}");

        for (var i = 0;
            i < (getContentbyChannelModel.result?.length ?? 0);
            i++) {
          playlistData
              ?.add(getContentbyChannelModel.result?[i] ?? playlist.Result());
        }
        final Map<int, playlist.Result> postMap = {};
        playlistData?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        playlistData = postMap.values.toList();
        debugPrint("Playlist length :==> ${(playlistData?.length ?? 0)}");
        setPlaylistLoadMore(false);
      }
    }
    playlistLoading = false;
    notifyListeners();
  }

  setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
      int? playlistcurrentPage, bool? playlistmorePage) {
    this.playlistcurrentPage = playlistcurrentPage;
    this.playlisttotalRows = playlisttotalRows;
    this.playlisttotalPage = playlisttotalPage;
    playlistmorePage = playlistmorePage;
    notifyListeners();
  }

  setPlaylistLoadMore(playlistLoadmore) {
    this.playlistLoadmore = playlistLoadmore;
    notifyListeners();
  }

  selectPlaylist(int index, isPlaylistId, isSelect) {
    playlistPosition = index;
    playlistId = isPlaylistId;
    isSelectPlaylist = isSelect;
    debugPrint("reasonId===> $playlistId");
    notifyListeners();
  }

  /* isType == 1 ==>  Public Playlist */
  /* isType == 2 ==>  Private Playlist */
  selectPrivacy({required int type}) {
    isType = type;
    notifyListeners();
  }

  getcreatePlayList(chennelId, title, playlistType) async {
    loading = true;
    createPlaylistModel =
        await ApiService().createPlayList(chennelId, title, playlistType);
    loading = false;
  }

/* Get Playlist Created By Perticular User End */

/* Add Remove Playlist */
  addremoveContentToPlaylist(
      chennelId, playlistId, contenttype, contentid, episodeid, type) async {
    loading = true;
    addremoveContentToPlaylistModel = await ApiService()
        .addremoveContenttoPlaylist(
            chennelId, playlistId, contenttype, contentid, episodeid, type);
    loading = false;
    notifyListeners();
  }

  clearPlaylistData() {
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistData?.clear();
    playlistLoading = false;
    playlistLoadmore = false;
    isSelectPlaylist = false;
    playlistId = "";
    playlistPosition;
    isType = 0;
  }

  clearProvider() {
    getMusicByCategoryModel = GetMusicByCategoryModel();
    addremoveWatchlaterModel = AddremoveWatchlaterModel();
    getContentbyChannelModel = GetContentbyChannelModel();
    addremoveContentToPlaylistModel = AddremoveContentToPlaylistModel();
    createPlaylistModel = SuccessModel();
    loading = false;
    /* Music By category Field */
    musicList = [];
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    /* Get PlayList Field */
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistmorePage;
    playlistData = [];
    playlistLoading = false;
    playlistLoadmore = false;
    playlistId = "";
    playlistPosition;
    isSelectPlaylist = false;
    isType = 0;
  }
}