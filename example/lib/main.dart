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

  @override
  void initState() {
    Gmpay.instance.initialize("GMPAY-PUB-xx-xx", secret: "GMPAY-SEC-xxx-xx");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
        const GmpayCard(
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
            child: const Text("Show Bottomsheet"))
      ]),
    );
  }
}
