import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  // Keys of Stripe dashboard
  static String secretKey = "pk_test_51SzuZY0KRpwcO4zEHs47arkmOTryBOAhNWAgBo2nAHdd2bwvIkoaPhoHnTuJFMhj1B4aB6RqfMaIJkmBsL8R0ERW008fqqSwg4";
  static String publishableKey = "sk_test_51SzuZY0KRpwcO4zEbuz6z4MEGruVaqcuZ87SVJSfpjpduf687VTKS5KdJ7iJbx1gBCqCP8t63eZXsqY5vhafHCB8006irm2c5X";

  static Future<void> init() async {
    Stripe.publishableKey = publishableKey;
  }

}