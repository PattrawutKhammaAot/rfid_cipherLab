import 'package:flutter/material.dart';
import 'package:flutter_app_jar/models/datalistModel.dart';

import 'functionSdk/myflutterNative.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool isTrg = false;
  String value = '';
  TextEditingController controller = TextEditingController();
  List<DataList> dataList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RFID CIPHERLAB"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${dataList.length}"),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(future: MyNativeFunction.setTagScannedListener((epc) {
              isTrg = true;
              if (epc.isNotEmpty) {
                if (dataList.any((element) => element.tag == epc)) {
                  var dataItem =
                      dataList.firstWhere((element) => element.tag == epc);
                  dataItem.count = (dataItem.count ?? 0) + 1;
                } else {
                  dataList.add(DataList(tag: epc, count: 1));
                }
              }

              setState(() {});
            }), builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isTrg = false;
                  });
                });
              }
              return Expanded(
                child: ListView.builder(
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Tag:${dataList[index].tag} "),
                                  Text("Count:${dataList[index].count}")
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${isTrg ? "Scanning" : "Not Scan"}"),
                ElevatedButton(
                    onPressed: () {
                      dataList.clear();
                      setState(() {});
                    },
                    child: Text("Clear")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
