import 'package:flutter/material.dart';
import 'package:gmpay/flutter_gmpay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  TextEditingController merchant = TextEditingController(text: "");
  TextEditingController amount = TextEditingController(text: "1000");
  TextEditingController phone = TextEditingController(text: "+256700000000");
  TextEditingController returnurl =
      TextEditingController(text: "https://www.google.com/");
  TextEditingController reference = TextEditingController(text: "ref-12-12-12");
  TextEditingController currency = TextEditingController(text: 'UGX');

  @override
  void initState() {
    Gmpay.instance.initialize("GMPAY-PUB-Ir9FZdMz3QWqrgP-23",
        secret: "GMPAY-SEC-bIlltnIXmcpAmYj-23");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeNeedTheNavigator(),
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
        GmpayCard(
          amount: 1000,
        ),
        ElevatedButton(
            onPressed: () {
              Gmpay.instance.presentPaymentSheet(
                context,
                amount: 3000,
                account: '702016859',
                reference: 'ref-12-12-12',
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
            child: Text("Show Bottomsheet"))
      ]),
    );
  }
}
