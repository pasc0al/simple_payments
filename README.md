# Simple Payments

This plugin is to help make payments easy again in Flutter.

## Usage
To use this plugin, add `simple_payments` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).
### Example
```dart
import 'package:flutter/material.dart';
import 'package:simple_payments/simple_payments.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
      child: RaisedButton(
        onPressed: _payEasy,
        child: Text('Pay Easy'),
        ),
      ),
    ),
  ));
}

_payEasy() async {
  try {
    var response = await SimplePayments.payWithStripe(map: {"body": {"amount": 10.0, "desc": "Some description optional", "more": "data to pass"}, "url": "The API for Stripe charges", "stripePub": "The Pub key of Stripe"});
  } on TimeoutException {
    print("Timeout");
  } on DeferredLoadException {
    print("Library fails to load");
  }
}
```
### Notes
Your API should expect to receive the following in the POST body:
* tokenStripe;
* Your data that is in the **body** map (you can also add more) shown in the example above.

Also this plugin is using [Stripe](https://stripe.com/docs/charges) for payments, in the near future will have PayPal, M-Pesa, etc.