import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget_service.dart';

class BillingService extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  // Replace with your actual product ID from Google Play Console
  final String _premiumProductId = 'aqua_premium_lifetime'; 

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
    );

    _isAvailable = await _inAppPurchase.isAvailable();
    if (_isAvailable) {
      await _fetchProducts();
    }
    notifyListeners();
  }

  Future<void> _fetchProducts() async {
    final Set<String> ids = {_premiumProductId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    notifyListeners();
  }

  void buyPremium() {
    if (_products.isNotEmpty) {
      final product = _products.firstWhere((p) => p.id == _premiumProductId);
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
       // Just for testing/debugging
       debugPrint('No products loaded to buy from Google Play.');
    }
  }

  void restorePurchases() {
    _inAppPurchase.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending status
        debugPrint('Purchase pending...');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          _grantPremium();
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _grantPremium() async {
    if (!_isPremium) {
      _isPremium = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPremium', true);
      
      // Update widgets immediately to unlock and populate them
      await WidgetService.syncFullWidgetData();
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
