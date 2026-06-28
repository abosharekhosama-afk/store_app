import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2_ecom/data/repositories/Wallet/WalletRepository.dart';
import 'package:untitled2_ecom/data/repositories/repositories.authentication/authentication_repository.dart';
import 'package:untitled2_ecom/features/personalization/models/TransactionModel.dart';

class WalletController extends GetxController {
  final repository = Get.put(WalletRepository());
  final ScrollController scrollController = ScrollController();

  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // متغيرات الـ Pagination
  DocumentSnapshot? _lastDocument;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final int _pageSize = 20;

  // متغير الفلترة
  final Rx<TransactionType?> selectedFilter = Rx<TransactionType?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchInitialTransactions();
    listenToBalance();

    // إعداد مستشعر التمرير
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.9) {
        fetchMoreTransactions();
      }
    });
  }

  void listenToBalance() {
    String userId = AuthenticationRepository.instance.authUser!.uid;
    repository
        .getWalletBalance(userId)
        .listen((newBalance) => balance.value = newBalance);
  }

  // جلب أول مجموعة
  Future<void> fetchInitialTransactions() async {
    _lastDocument = null;
    hasMoreData.value = true;
    transactions.clear();
    await fetchMoreTransactions();
  }

  // جلب المزيد (Pagination)
  Future<void> fetchMoreTransactions() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    isLoadingMore.value = true;
    String userId = AuthenticationRepository.instance.authUser!.uid;

    try {
      final snapshot = await repository.getTransactionsPaged(
        userId: userId,
        limit: _pageSize,
        lastDocument: _lastDocument,
        typeFilter: selectedFilter.value,
      );

      if (snapshot.docs.length < _pageSize) {
        hasMoreData.value = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        transactions.addAll(
          snapshot.docs
              .map((doc) => TransactionModel.fromSnapshot(doc))
              .toList(),
        );
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  // تغيير الفلتر
  void applyFilter(TransactionType? type) {
    selectedFilter.value = type;
    fetchInitialTransactions(); // إعادة الجلب من الصفر بالفلتر الجديد
  }
}









/*
class WalletController extends GetxController {
  final repository = Get.put(WalletRepository());
  final RxDouble balance = 0.0.obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToWallet();
  }

  void listenToWallet() {
    String userId = AuthenticationRepository.instance.authUser!.uid;

    // مراقبة الرصيد
    repository.getWalletBalance(userId).listen((userModel) {
      var newBalance = userModel.walletBalance;
      balance.value = newBalance;
    });

    // مراقبة العمليات
    repository.getTransactions(userId).listen((newTransactions) {
      transactions.assignAll(newTransactions);
    });
  }
}
*/