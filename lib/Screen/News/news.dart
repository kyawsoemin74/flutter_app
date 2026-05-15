import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:football_xt_latest/constent.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../Provider/news.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewsProvider>(context, listen: false);
      provider.fetchForYouNews();
      provider.fetchTipsNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: AppConfig.scaffoldBgColor,
        title: Text(
          'News'.tr,
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'For you'.tr),
            Tab(text: 'Latest'.tr),
            Tab(text: 'Transfers'.tr),
            Tab(text: 'Tips'.tr),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final provider = Provider.of<NewsProvider>(context, listen: false);
          await provider.refreshAll();
        },
        child: Consumer<NewsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            if (provider.error.isNotEmpty) {
              return Center(
                child: Text(
                  provider.error,
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _buildNewsList(provider.forYouNews),
                _buildNewsList(provider.latestNews),
                _buildNewsList(provider.transferNews),
                _buildNewsList(provider.tipsNews),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsList(List<dynamic> newsList) {
    if (newsList.isEmpty) {
      return Center(
        child: Text(
          'No news available',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      );
    }
    return ListView.builder(
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return ListTile(
          leading: news.image.isNotEmpty
              ? Image.network(
                  news.image,
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                )
              : Icon(
                  Icons.article,
                  color: Colors.white,
                  size: 50.sp,
                ),
          title: Text(
            news.title,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          subtitle: Text(
            news.description,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            news.date,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10.sp),
          ),
        );
      },
    );
  }
}