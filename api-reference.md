## `initialize` Method

The `initialize` method is used to configure and initialize the GMPay Flutter Plugin with your GMPay account credentials. This method should be called before any other GMPay-related operations to ensure that the plugin is properly configured.

### Method Signature:

```dart
Gmpay.instance.initialize(String pubKey, {String? secret})
```

### Parameters:

- `pubKey` (String, required): Your GMPay public key, which is associated with your GMPay account. This key is used for secure communication with GMPay's servers.

- `secret` (String, optional): Your GMPay secret key, which is also associated with your GMPay account. This key is used for cryptographic operations and authentication. It is optional but recommended for enhanced security.

### Return Value:

- `Future<void>`

### Example:

```dart
Gmpay.instance.initialize(
  "GMPAY-PUB-XXXXXXXXXXXXXX-YY",
  secret: "GMPAY-SEC-XXXXXXXXXXXXXX-YY",
);
```

### Usage:

Before initiating any payment transactions or interacting with GMPay services, you should call the `initialize` method with your GMPay public key and secret key. This step is crucial to ensure secure and successful communication with GMPay's servers.

### Note:

- Ensure that you replace the `pubKey` and `secret` values in the example with your actual GMPay account credentials.

- The `initialize` method should be called at the beginning of your application's execution, preferably during initialization or setup.

- Keep your GMPay secret key secure and never expose it in client-side code or public repositories, as it is a sensitive credential.

- Make sure that you've added the GMPay Flutter Plugin as a dependency in your `pubspec.yaml` file and performed the necessary installation steps before using the `initialize` method.

This method should be called once per application session to configure the GMPay Flutter Plugin for your GMPay account.


---

## `presentPaymentSheet` Method

The `presentPaymentSheet` method is used to present a payment sheet to the user, allowing them to make a payment using GMPay. This method initiates a payment transaction and provides callbacks to handle the transaction's result and the approval URL.

### Method Signature:

```dart
Gmpay.instance.presentPaymentSheet(
  BuildContext context,
  {
    double? amount,
    String? account,
    String? reference,
    bool? waitForConfirmation,
    void Function(String?)? approvalUrlHandler,
    void Function(TransactionInfo?)? callback
  }
)
```

### Parameters:

- `context` (BuildContext, required): The `BuildContext` of the widget that triggers the payment sheet presentation. It is required to properly display the payment sheet.

- `amount` (double?, optional): The amount to be paid in the smallest unit of your currency (e.g., cents). This parameter is required and should be an integer representing the payment amount.

- `account` (String?, optional): The account or beneficiary details to whom the payment is to be made. This could be an account number, username, or any other relevant identifier.

- `reference` (String?, optional): A reference identifier for the payment transaction. This parameter is optional and can be used to associate additional information with the transaction.

- `approvalUrlHandler` (Function(String?)?, optional): A callback function that handles the approval URL for the transaction. It takes one argument, a `String?`, which represents the approval URL. This parameter is optional and is typically used for specific transaction handling.

- `callback` (Function(TransactionInfo?)?, optional): A callback function that will be called when the payment transaction is completed. The callback function takes one argument, a `TransactionInfo?`, which contains transaction details or may be `null` if the transaction was canceled or failed. This parameter is optional and can be used to handle the transaction result.

- `waitForConfirmation` (bool, optional): A boolean value that specifies whether to wait for confirmation of the payment. Set to true to wait for confirmation or false to proceed without waiting. This parameter is optional and controls whether to wait for payment confirmation.

### Example:

```dart
Gmpay.instance.presentPaymentSheet(
  context,
  amount: 3000,
  account: '7020XXXXX',
  reference: 'ref-XX-XX-XX',
  approvalUrlHandler: (approvalUrl) {
    print(approvalUrl);
  },
  callback: (transactionInfo) {
    if (transactionInfo == null) {
      print("Transaction cancelled");
    } else {
      print(transactionInfo);
    }
  },
);
```

### Usage:

1. Call the `presentPaymentSheet` method to initiate the payment process.

2. Provide the `context` of the widget where you want to display the payment sheet.

3. Specify the `amount` to be paid, `account` details, and optionally, a `reference`, an `approvalUrlHandler`, and a `callback` function to handle the transaction result and approval URL.

4. The `approvalUrlHandler` function is called to handle the approval URL, typically for specific transaction handling.

5. The `callback` function is called when the transaction is completed, providing transaction details or indicating cancellation or failure.

### Note:

- The `amount` parameter should be specified in the smallest unit of your currency (e.g., cents) as an integer.

- The `approvalUrlHandler` and `callback` functions handle specific aspects of the transaction. `callback` receives `TransactionInfo` for transaction details.

- Ensure that you've initialized the GMPay Flutter Plugin using the `initialize` method before using the `presentPaymentSheet` method.

- This method triggers the presentation of a payment sheet to the user, allowing them to complete the payment transaction.
