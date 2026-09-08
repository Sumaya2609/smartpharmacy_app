import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/flutter_sslcommerz.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

typedef PaymentResultCallback = void Function(PaymentResult result);

class PaymentResult {
  final bool isSuccess;
  final String message;
  final String? tranId;
  final String? status;
  final String? failedReason;
  final double? amount;

  PaymentResult({
    required this.isSuccess,
    required this.message,
    this.tranId,
    this.status,
    this.failedReason,
    this.amount,
  });
}

class SSLCommerzService {
  static const String _storeId = "c4ute696557b58cb7c";
  static const String _storePassword = "c4ute696557b58cb7c@ssl";
  //static const String _ipnUrl = "https://smart-pharmacy-test.local/ipn";
  static const String _productCategory = "Ecommerce";

  static Future<void> initiatePayment({
    required BuildContext context,
    required double amount,
    required Map<String, String> customer,
    PaymentResultCallback? onResult,
  }) async {
    try {
      final String tranId = _generateUniqueTranId();

      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          // ✅ ALL CORRECT PROPERTY NAMES (Android Studio approved)
          //ipn_url: _ipnUrl,
          multi_card_name: "",  // Empty = bKash + Nagad + Cards
          currency: SSLCurrencyType.BDT,
          product_category: _productCategory,
          sdkType: SSLCSdkType.TESTBOX,
          store_id: _storeId,
          store_passwd: _storePassword,
          total_amount: amount,
          tran_id: tranId,
        ),
      );

      sslcommerz.addCustomerInfoInitializer(
        customerInfoInitializer: SSLCCustomerInfoInitializer(
          customerName: customer['name'] ?? "Customer",
          customerEmail: customer['email'] ?? "customer@example.com",
          customerPhone: customer['phone'] ?? "01xxxxxxxxx",
          customerAddress1: customer['address'] ?? "Dhaka",
          customerCity: customer['city'] ?? "Dhaka",
          customerCountry: customer['country'] ?? "Bangladesh",
          customerPostCode: customer['postcode'] ?? "1200",
          customerState: customer['state'] ?? "Dhaka",
        ),
      );

      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      _handlePaymentResult(result, amount, onResult);

    } catch (e) {
      debugPrint("SSLCommerz Error: $e");
      onResult?.call(PaymentResult(isSuccess: false, message: "Error: $e"));
    }
  }

  static String _generateUniqueTranId() {
    final random = Random().nextInt(900000) + 100000;
    return "pharmacy_${DateTime.now().millisecondsSinceEpoch}_$random";
  }

  static void _handlePaymentResult(
      SSLCTransactionInfoModel result,
      double amount,
      PaymentResultCallback? onResult,
      ) {
    debugPrint("Status: ${result.status}");
    debugPrint("Tran ID: ${result.tranId}");
    debugPrint("Card Type: ${result.cardType}");

    bool isSuccess = result.status?.toLowerCase() == "success";
    String failedReason = result.cardType ?? "Cancelled";

    onResult?.call(PaymentResult(
      isSuccess: isSuccess,
      message: isSuccess ? "Payment Success!" : "Payment Failed: $failedReason",
      tranId: result.tranId,
      status: result.status,
      failedReason: failedReason,
      amount: amount,
    ));
  }
}
