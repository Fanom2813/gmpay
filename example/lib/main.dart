import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gmpay/flutter_gmpay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _platformVersion = 'Unknown';
  // final _gmpayPlugin = Gmpay();

  @override
  void initState() {
    // Gmpay.instance.initialize(
    //     key: dotenv.env['APIKEY']!, secret: dotenv.env['APISECRET']!);
    Gmpay.instance.initialize(packageName: "com.gmpayapp.webplugin");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WeNeedTheNavigator(),
      themeMode: ThemeMode.dark,
    );
  }
}

class WeNeedTheNavigator extends StatelessWidget {
  const WeNeedTheNavigator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GMPAY PLUGIN TEST'),
        centerTitle: true,
      ),
      body: ListView(children: [
        //  GmpayCard(
        //   amount: 1000,
        // ),
        ElevatedButton(
            onPressed: () {
              Gmpay.instance.presentPaymentSheet(
                context,
                amount: 3000,
                account: dotenv.env['PHONE']!,
                metadata: {
                  "callback_url": "https://example.com/callback",
                },
                waitForConfirmation: true,
                approvalUrlHandler: (p0) {
                  print(p0);
                },
                callback: (p1) {
                  if (p1 == null) {
                    print("Transaction cancelled");
                  } else {
                    print(p1);
                  }
                },
              );
            },
            child: const Text("Show Bottomsheet")),
        ElevatedButton(
            onPressed: () {
              Gmpay.instance.presentWithdrawSheet(
                context,
                amount: 3000,
                account: dotenv.env['PHONE']!,
                waitForConfirmation: true,
                callback: (p1) {
                  if (p1 == null) {
                    print("Transaction cancelled");
                  } else {
                    print(p1);
                  }
                },
              );
            },
            child: const Text("Show W Bottomsheet")),

        ElevatedButton(
            onPressed: () {
              Gmpay.instance.presentVerificationSheet(
                context,
                reference: "1X4BJYKO6E8D",
                callback: (p1) {
                  if (p1 == null) {
                    print("Transaction cancelled");
                  } else {
                    print(p1);
                  }
                },
              );
            },
            child: const Text("Check transaction status")),
      ]),
    );
  }
}
