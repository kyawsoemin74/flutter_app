import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/apihelp.dart';
import '../constent.dart';
import '../model/News/news.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> latestNews = [];
  List<NewsModel> transferNews = [];
  List<NewsModel> tipsNews = [];
  List<NewsModel> forYouNews = [];
  bool isLoading = false;
  String error = '';

  Future<void> fetchLatestNews() async {
    try {
      final response = await ApiHelp.get(ENDPOINTURL: AppConfig.newsLatestEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        latestNews = jsonList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        latestNews = [];
      }
    } catch (e) {
      error = 'Failed to load latest news';
      latestNews = [];
    }
    notifyListeners();
  }

  Future<void> fetchTransferNews() async {
    try {
      final response = await ApiHelp.get(ENDPOINTURL: AppConfig.newsTransfersEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        transferNews = jsonList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        transferNews = [];
      }
    } catch (e) {
      error = 'Failed to load transfer news';
      transferNews = [];
    }
    notifyListeners();
  }

  Future<void> fetchTipsNews() async {
    try {
      final response = await ApiHelp.get(ENDPOINTURL: AppConfig.newsTipsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        tipsNews = jsonList.map((json) => NewsModel.fromJson(json)).toList();
      } else {
        tipsNews = [];
      }
    } catch (e) {
      error = 'Failed to load tips news';
      tipsNews = [];
    }
    notifyListeners();
  }

  Future<void> fetchForYouNews() async {
    isLoading = true;
    error = '';
    notifyListeners();
    await fetchLatestNews();
    await fetchTransferNews();
    // Merge and sort by date, newest first
    forYouNews = [...latestNews, ...transferNews];
    forYouNews.sort((a, b) => b.date.compareTo(a.date));
    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await fetchForYouNews();
    await fetchTipsNews();
  }
}