import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {

  static String secretKey = "sk_test_51SzuZY0KRpwcO4zEbuz6z4MEGruVaqcuZ87SVJSfpjpduf687VTKS5KdJ7iJbx1gBCqCP8t63eZXsqY5vhafHCB8006irm2c5X";
  static String publishableKey = "pk_test_51SzuZY0KRpwcO4zEHs47arkmOTryBOAhNWAgBo2nAHdd2bwvIkoaPhoHnTuJFMhj1B4aB6RqfMaIJkmBsL8R0ERW008fqqSwg4";

  static Future<void> init() async {
    Stripe.publishableKey = publishableKey;
  }

  // 1. Create a Payment Intent
  static Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': _calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('Error creating payment intent: $err');
      return null;
    }
  }

  // 2. Display the Payment Sheet
  static Future<void> makePayment(BuildContext context, String amount, VoidCallback onSuccess) async {
    try {
      // Step A: Create Intent
      var paymentIntent = await createPaymentIntent(amount, 'LKR');
      if (paymentIntent == null) return;

      // Step B: Initialize the Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'MUC Digital',
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFFE67E22),
            ),
          ),
        ),
      );

      // Step C: Display the Sheet
      await Stripe.instance.presentPaymentSheet();

      // If we get here, payment was successful!
      onSuccess();

      // Check if the screen is still active before showing SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful!")),
        );
      }

    } on StripeException catch (e) {
      if (context.mounted) {
        if (e.error.code == FailureCode.Canceled) {
          // User cancelled, mostly harmless
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Failed: ${e.error.localizedMessage}")),
          );
        }
      }
    } catch (e) {
      debugPrint("Generic Error: $e");
    }
  }

  static String _calculateAmount(String amount) {
    // Remove "LKR", commas, and spaces
    final cleanPrice = amount.replaceAll(RegExp(r'[^0-9]'), '');
    // If the string is empty (e.g. error), default to 0 to avoid crash
    if (cleanPrice.isEmpty) return "0";
    final priceInt = int.parse(cleanPrice);
    return (priceInt * 100).toString();
  }
}