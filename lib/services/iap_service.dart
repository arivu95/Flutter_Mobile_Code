// Singleton class to handle the in-app purchases
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:swarapp/app/locator.dart';
import 'package:swarapp/app/router.dart';
import 'package:swarapp/services/api_services.dart';
import 'package:swarapp/services/preferences_service.dart';
import 'package:swarapp/ui/dashboard/dashboard_view.dart';
import 'package:swarapp/ui/startup/terms_view.dart';

class IapService {
  final List<String> _productIds = ['com.kat.swarapp.monthly', 'com.kat.swarapp.yearly'];
  //
  late StreamSubscription<ConnectionResult> _connectionSubscription;
  late StreamSubscription<PurchasedItem?> _purchaseUpdatedSubscription;
  late StreamSubscription<PurchaseResult?> _purchaseErrorSubscription;

  List<IAPItem> _products = [];
  List<PurchasedItem> pastPurchases = [];
  //

  ObserverList<Function> _proStatusChangedListeners = new ObserverList<Function>();

  /// view of the app will subscribe to this to get errors of the purchase
  ObserverList<Function(String)> _errorListeners = new ObserverList<Function(String)>();

  PreferencesService preferencesService = locator<PreferencesService>();

  // void initConnection() async {
  //   await FlutterInappPurchase.instance.initConnection;
  //   _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {});

  //   _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);

  //   _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);

  //   _getItems();
  //   _getPastPurchases();
  //   //_getPastPurchasesHaveValidSubscription();
  // }
  void initConnection() async {
    await initializeIAP();
  }

  Future initializeIAP() async {
    await FlutterInappPurchase.instance.initConnection;
    _connectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {});
    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen(_handlePurchaseUpdate);
    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen(_handlePurchaseError);
    _getItems();
    _getPastPurchases();
    //_getPastPurchasesHaveValidSubscription();
  }

  void _handlePurchaseUpdate(PurchasedItem? productItem) async {
    if (Platform.isAndroid) {
      await _handlePurchaseUpdateAndroid(productItem!);
    } else {
      await _handlePurchaseUpdateIOS(productItem!);
    }
  }

  void _handlePurchaseError(PurchaseResult? purchaseError) {
    _callErrorListeners(purchaseError!.message!);
  }

  void _callProStatusChangedListeners() {
    _proStatusChangedListeners.forEach((Function callback) {
      callback();
    });
  }

  /// Call this method to notify all the subsctibers of _errorListeners
  void _callErrorListeners(String error) {
    _errorListeners.forEach((Function callback) {
      callback(error);
    });
  }

  Future<void> _handlePurchaseUpdateIOS(PurchasedItem purchasedItem) async {
    switch (purchasedItem.transactionStateIOS) {
      case TransactionState.deferred:
        // Edit: This was a bug that was pointed out here : https://github.com/dooboolab/flutter_inapp_purchase/issues/234
        // FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.failed:
        _callErrorListeners("Transaction Failed");
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      case TransactionState.purchased:
        await _verifyAndFinishTransaction(purchasedItem);
        break;
      case TransactionState.purchasing:
        break;
      case TransactionState.restored:
        FlutterInappPurchase.instance.finishTransaction(purchasedItem);
        break;
      default:
    }
  }

  /// three purchase state https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState
  /// 0 : UNSPECIFIED_STATE
  /// 1 : PURCHASED
  /// 2 : PENDING
  Future<void> _handlePurchaseUpdateAndroid(PurchasedItem purchasedItem) async {
    switch (purchasedItem.purchaseStateAndroid) {
      case PurchaseState.purchased:
        if (!purchasedItem.isAcknowledgedAndroid!) {
          await _verifyAndFinishTransaction(purchasedItem);
        }
        break;
      default:
        _callErrorListeners("Something went wrong");
    }
  }

  _verifyAndFinishTransaction(PurchasedItem purchasedItem) async {
    bool isValid = false;
    try {
      // Call API
      isValid = await _verifyPurchase(purchasedItem);
      // } on NoInternetException {
      //   _callErrorListeners("No Internet");
      //   return;
    } on Exception {
      _callErrorListeners("Something went wrong");
      return;
    }

    if (isValid) {
      FlutterInappPurchase.instance.finishTransaction(purchasedItem);
      // _isProUser = true;
      // save in sharedPreference here
      _callProStatusChangedListeners();
      // await locator<NavigationService>().clearStackAndShow(RoutePaths.Dashboard);
      pastPurchases.add(purchasedItem);
      //Get.back();
       Get.to(() => DashboardView());
    } else {
      _callErrorListeners("Varification failed");
    }
  }

  Future<bool> _verifyPurchase(PurchasedItem item) async {
    Jiffy transactionDate = Jiffy(item.transactionDate);
    String platform = "";
    if (Platform.isAndroid) {
      platform = "Android";
    } else {
      platform = "IOS";
    }
    Map<String, dynamic> postParams = {
      'productId': item.productId,
      // 'orderId': item.orderId,
      'purchaseTime': transactionDate.format('MM-dd-yyyy'),
      'token': item.purchaseToken,
      'active_flag': true,
      'platform': platform
    };
    print(postParams);
    String userId = preferencesService.userId;
    final response = await locator<ApiService>().updateSubscription(userId, postParams);
    print(response);
    if (response['subscription'] != null) {
      preferencesService.subscriptionStream.value = Map.from(response['subscription']);
    }
    return true;
  }

  Future<List<IAPItem>> get products async {
    if (_products == null) {
      await _getItems();
    }
    return _products;
  }

  //checkSubscribed
  void _getPastPurchasesHaveValidSubscription() async {
    List<PurchasedItem>? purchasedItems = await FlutterInappPurchase.instance.getAvailablePurchases();
    if (purchasedItems!.length > 0) {
      PurchasedItem latestItem = purchasedItems.first;
      bool isSubscribed = await FlutterInappPurchase.instance.checkSubscribed(sku: latestItem.productId!);
      print(isSubscribed);
    }
  }

  Future<void> _getItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getSubscriptions(_productIds);
    _products = [];
    for (var item in items) {
      this._products.add(item);
    }
  }

  void _getPastPurchases() async {
    // remove this if you want to restore past purchases in iOS
    // if (Platform.isIOS) {
    //   return;
    // }
    List<PurchasedItem>? purchasedItems = await FlutterInappPurchase.instance.getAvailablePurchases();

    for (var purchasedItem in purchasedItems!) {
      bool isValid = false;

      if (Platform.isAndroid) {
        Map map = json.decode(purchasedItem.transactionReceipt!);
        // if your app missed finishTransaction due to network or crash issue
        // finish transactins
        if (!map['acknowledged']) {
          isValid = await _verifyPurchase(purchasedItem);
          if (isValid) {
            FlutterInappPurchase.instance.finishTransaction(purchasedItem);
            // _isProUser = true;
            _callProStatusChangedListeners();
          }
        } else {
          // _isProUser = true;
          _callProStatusChangedListeners();
        }
      }
    }

    pastPurchases = [];
    pastPurchases.addAll(purchasedItems);
    // If past purchases are empty, then we need to take this user into basic plan
    if (purchasedItems.length == 0) {
      if (preferencesService.isSubscriptionMarkedInSwar()) {
        await switchCurrentUserToBasicPlan();
      }
    }
    // Checking if the subscription is active
    if (purchasedItems.length > 0) {
      PurchasedItem latestItem = purchasedItems.last;
      bool isSubscribed = await FlutterInappPurchase.instance.checkSubscribed(sku: latestItem.productId!);
      if (!isSubscribed) {
        await switchCurrentUserToBasicPlan();
      }
    }
  }

  // If the user subscription is not availabie, then the user is moved to the basic plan
  Future switchCurrentUserToBasicPlan() async {
    Jiffy transactionDate = Jiffy();
    Map<String, dynamic> postParams = {'productId': 'com.kat.swarapp.basic', 'orderId': '000', 'purchaseTime': transactionDate.format('MM-dd-yyyy'), 'token': '0', 'active_flag': true};
    print(postParams);
    String userId = preferencesService.userId;
    final response = await locator<ApiService>().updateSubscription(userId, postParams);
    if (response['subscription'] != null) {
      preferencesService.subscriptionStream.value = Map.from(response['subscription']);
    }
  }

  Future<Null> buyProduct(IAPItem item) async {
    print(item.productId);
    try {
      await FlutterInappPurchase.instance.requestSubscription(item.productId!);
    } catch (error) {
      print(error.toString());
    }
  }

  /// call when user close the app
  void dispose() {
    _connectionSubscription.cancel();
    _purchaseErrorSubscription.cancel();
    _purchaseUpdatedSubscription.cancel();
    FlutterInappPurchase.instance.endConnection;
  }
}
