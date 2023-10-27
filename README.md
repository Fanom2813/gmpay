# GMPay Flutter Plugin Documentation

GMPay is a modern payment platform designed to facilitate secure and convenient transactions for businesses and individuals. The GMPay Flutter Plugin allows you to integrate GMPay into your Flutter applications seamlessly.

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [API Reference](#api-reference)
6. [Examples](#examples)
7. [FAQ](#faq)
8. [License](#license)

## Introduction

GMPay is a comprehensive payment solution that offers a range of features and services to streamline the payment process and enhance the overall user experience. This Flutter plugin enables you to harness the power of GMPay in your Flutter applications.

## Installation

To get started with the GMPay Flutter Plugin, you need to install it in your Flutter project. You can do this by adding it as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  gmpay:
```

After adding the dependency, run `flutter pub get` to install the package.

## Configuration

Before using the GMPay Flutter Plugin, you need to configure it with your GMPay account details and credentials. Here's how you can set up the configuration:

### `initialize` Method

The `initialize` method is used to configure and initialize the GMPay Flutter Plugin with your GMPay account credentials. This method should be called before any other GMPay-related operations to ensure that the plugin is properly configured.

#### Parameters:

- `pubKey` (String, required): Your GMPay public key, which is associated with your GMPay account. This key is used for secure communication with GMPay's servers.

- `secret` (String, required): Your GMPay secret key, which is also associated with your GMPay account. This key is used for cryptographic operations and authentication.

#### Example:

```dart
Gmpay.instance.initialize(
  "GMPAY-PUB-XXXXXXXXXXXXX-YY",
  secret: "GMPAY-SEC-XXXXXXXXXXXXXXX-YY",
);
```

#### Usage:

Before initiating any payment transactions or interacting with GMPay services, you should call the `initialize` method with your GMPay public key and secret key. This step is crucial to ensure secure and successful communication with GMPay's servers.

#### Note:

- Ensure that you replace the `pubKey` and `secret` values in the example with your actual GMPay account credentials.

- The `initialize` method should be called at the beginning of your application's execution, preferably during initialization or setup.

- Keep your GMPay secret key secure and never expose it in client-side code or public repositories, as it is a sensitive credential.

- Make sure that you've added the GMPay Flutter Plugin as a dependency in your `pubspec.yaml` file and performed the necessary installation steps before using the `initialize` method.

This method should be called once per application session to configure the GMPay Flutter Plugin for your GMPay account.


## API Reference

For detailed information on available methods and options, refer to the [API Reference](api-reference.md).

## Examples

Explore our [example](examples/) directory for sample Flutter applications that demonstrate how to use the GMPay Flutter Plugin in different scenarios.

## FAQ

Check out our [FAQ](faq.md) for answers to common questions about the GMPay Flutter Plugin.

## License

The GMPay Flutter Plugin is licensed under the [MIT License](LICENSE.md). Make sure to review the license terms before using the plugin in your projects.