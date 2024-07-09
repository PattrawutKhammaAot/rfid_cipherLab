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
  late String scanMode = '';
  TextEditingController controller = TextEditingController();
  List<DataList> dataList = [];
  var mode = ["Alternate", 'Single', 'Continuous'];

  @override
  void initState() {
    MyNativeFunction.GetScanMode().then((value) => scanMode = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RFID CIPHERLAB"),
        actions: [
          IconButton(
              onPressed: () async {
                _dialogBuilder(context);
                setState(() {});
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: MyNativeFunction.GetConnection(),
          builder: (context, snapshot) {
            return snapshot.data == true
                ? Column(
                    children: [
                      FutureBuilder(
                          future: MyNativeFunction.setTagScannedListener((epc) {
                        isTrg = true;
                        if (epc.isNotEmpty) {
                          if (dataList.any((element) => element.tag == epc)) {
                            var dataItem = dataList
                                .firstWhere((element) => element.tag == epc);
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
                                            Text(
                                                "Count:${dataList[index].count}")
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
                          ElevatedButton(
                              onPressed: () {
                                if (!isTrg) {
                                  MyNativeFunction.SetTrgMode(true);
                                  isTrg = true;
                                } else {
                                  MyNativeFunction.SetTrgMode(false);
                                  isTrg = false;
                                }
                                setState(() {});
                              },
                              child: Text("${isTrg ? "Stop" : "Scan"}")),
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
                  )
                : Center(
                    child: Text("Please Connection Reader"),
                  );
          },
        ),
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(// ใช้ StatefulBuilder ที่นี่
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Setting Mode'),
            content: Column(
              children: [
                DropdownButton(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    value: scanMode,
                    items: mode.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      print(newValue);
                      setState(() {
                        // ตอนนี้ setState จะทำงานใน scope ของ StatefulBuilder
                        scanMode = newValue!;
                      });
                      print(scanMode);
                    })
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Disable'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Enable'),
                onPressed: () async {
                  await MyNativeFunction.SetScanMode(scanMode);
                  await MyNativeFunction.GetScanMode()
                      .then((value) => scanMode = value);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}
