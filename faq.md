# Frequently Asked Questions (FAQ)

## General Questions

### Q1: What is the GMPay Flutter Plugin?

A1: The GMPay Flutter Plugin is a Flutter package that allows developers to integrate the GMPay payment platform into their Flutter applications. It provides a seamless way to facilitate secure and convenient payment transactions for businesses and individuals.

### Q2: How do I obtain API keys for GMPay?

A2: To obtain API keys for GMPay, follow these steps:

1. Sign up for a GMPay account on the GMPay app.

2. Once logged in, navigate to services then press on the merchant icon.

3. You'll find an option to create API keys. Click on it and follow the instructions to generate your public and secret keys.

4. Make sure to keep your secret key secure and never expose it in client-side code or public repositories, as it is a sensitive credential.

## Installation and Setup

### Q3: How do I install the GMPay Flutter Plugin in my Flutter project?

A3: To install the GMPay Flutter Plugin, follow these steps:

1. Open your Flutter project.

2. Add the following dependency to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     gmpay: ^1.0.0
   ```

3. Run `flutter pub get` to install the package.

4. You're now ready to use the GMPay Flutter Plugin in your project.

### Q4: How do I configure the GMPay Flutter Plugin with my API keys?

A4: You should configure the GMPay Flutter Plugin with your API keys before using it. Here's how:

```dart
import 'package:gmpay_flutter/gmpay_flutter.dart';

void configureGMPay() {
  GMPayFlutter.configure(
    apiKey: 'your_api_key',
    secret: 'your_secret_key',
  );
}
```

Replace `'your_api_key'` and `'your_secret_key'` with your actual GMPay API keys.

## Payment Transactions

### Q5: How can I initiate a payment transaction using the GMPay Flutter Plugin?

A5: To initiate a payment transaction, you can use the `initiatePayment` method. Here's an example:

```dart
import 'package:gmpay_flutter/gmpay_flutter.dart';

void initiatePayment() {
  GMPayFlutter.initiatePayment(
    amount: 100.00,  // Replace with the actual payment amount
    description: 'Payment for Product X',
    // Add other payment parameters as needed
  );
}
```

Replace the `amount` and `description` with the specific details of your payment.

### Q6: How do I handle the result of a payment transaction?

A6: You can handle the result of a payment transaction by providing a callback function when calling the payment method. The callback function will be invoked with the transaction details or a null value if the transaction was canceled or failed.

Example:

```dart
GMPayFlutter.initiatePayment(
  // ...
  callback: (transactionResult) {
    if (transactionResult == null) {
      print("Transaction canceled");
    } else {
      print(transactionResult);
    }
  },
);
```

## Troubleshooting

### Q7: My payment transactions are failing. What should I check?

A7: If your payment transactions are failing, consider the following:

- Ensure that you've configured the GMPay Flutter Plugin with the correct API keys using the `configure` method.

- Check your internet connection, as a stable internet connection is required to communicate with GMPay's servers.

- Verify that the payment details, such as the amount and account, are correctly specified in your payment requests.

- If you receive error messages, consult the GMPay documentation or contact GMPay support for specific error resolution.