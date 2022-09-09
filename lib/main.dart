import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MyApp());
}

MaterialColor orange = const MaterialColor(
  0xFFF26600,
  <int, Color>{
    50: Color(0xFFF26600),
    100: Color(0xFFF26600),
    200: Color(0xFFF26600),
    300: Color(0xFFF26600),
    400: Color(0xFFF26600),
    500: Color(0xFFF26600),
    600: Color(0xFFF26600),
    700: Color(0xFFF26600),
    800: Color(0xFFF26600),
    900: Color(0xFFF26600),
  },
);

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClubPetro Sorteios',
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController controller = ScrollController();
  List<List<dynamic>> tableAux = [];
  int posQTD = 13;
  int page = 0;
  List<DataColumn>? listDataColumn;
  List<DataRow>? listDataRow;
  bool isLoading = false;

  void resetValues() {
    posQTD = 13;
    page = 0;
    tableAux = [];
    isLoading = true;
  }

  Future<void> pickCsvFile() async {
    resetValues();
    setState(() {});
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['csv'], type: FileType.custom);
    if (result != null) {
      const codec = Windows1252Codec(allowInvalid: false);
      late List csv;
      if (kIsWeb) {
        final bytes = codec.decode(result.files.first.bytes!);
        csv = const CsvToListConverter(fieldDelimiter: ';', eol: '\n')
            .convert(bytes);
      } else {
        var file = File(result.files.single.path!).openRead();
        csv = await file
            .transform(codec.decoder)
            .transform(const CsvToListConverter(fieldDelimiter: ';', eol: '\n'))
            .toList();
      }
      for (int i = 0; i < csv.length; i++) {
        tableAux.add(csv[i]);
        if (i != 0) {
          for (int j = 1; j < int.parse(csv[i][posQTD].toString()); j++) {
            tableAux.add(csv[i]);
          }
        }
      }
    }
    returnColuns();
    returnRows();
    setState(() {
      isLoading = false;
    });
  }

  void returnColuns() {
    List<DataColumn> listDataColumnAux = [];
    if (tableAux.isNotEmpty) {
      listDataColumnAux.add(const DataColumn(
          label: Text('ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));
      for (int i = 0; i < tableAux[0].length; i++) {
        if (tableAux[0][i].toString() == "QTD") {
          posQTD = i;
        }
        listDataColumnAux.add(DataColumn(
            label: Text(tableAux[0][i].toString(),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold))));
      }
    }
    listDataColumn = listDataColumnAux;
  }

  void returnRows() {
    List<DataRow> listDataRowAux = [];

    for (int i = page * 50 + 1;
        i < tableAux.length && i <= page * 50 + 50;
        i++) {
      List<DataCell> listDataCell = [];
      listDataCell.add(
        DataCell(Text(i.toString())),
      );
      listDataRowAux.add(
        DataRow(
          cells: returnCells(i, listDataCell),
        ),
      );
    }
    listDataRow = listDataRowAux;
  }

  List<DataCell> returnCells(int i, List<DataCell> listDataCell) {
    for (int j = 0; j < tableAux[i].length; j++) {
      if (j == posQTD) {
        listDataCell.add(
          const DataCell(Text("1")),
        );
      } else {
        listDataCell.add(
          DataCell(Text(tableAux[i][j].toString())),
        );
      }
    }
    return listDataCell;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ClubPetro Sorteios"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tableAux.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: MediaQuery.of(context).size.width),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .3,
                      width: MediaQuery.of(context).size.width * .8,
                      child: SvgPicture.asset(
                        "assets/images/searching.svg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * .05),
                    const Text(
                      "Selecione um arquivo CSV!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 40,
                        color: Color(0xFFF26600),
                      ),
                    ),
                  ],
                )
              : ListView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: listDataColumn!,
                        rows: listDataRow!,
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Container(
        height: tableAux.isEmpty
            ? MediaQuery.of(context).size.height * .1
            : MediaQuery.of(context).size.height * .2,
        padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: MediaQuery.of(context).size.height * .0175),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(
                0,
                -5.0,
              ),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: tableAux.isEmpty
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        pickCsvFile();
                      },
                      child: const SizedBox(
                        height: double.maxFinite,
                        child: Center(
                          child: Text(
                            "Importar arquivo CSV",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (page > 0) {
                                  page--;
                                  returnColuns();
                                  returnRows();
                                  setState(() {});
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      page > 0
                                          ? const Color(0xFFF26600)
                                          : Colors.grey)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(height: 4),
                                  Icon(Icons.arrow_back),
                                  Text("Página anterior"),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 48,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (tableAux.length > (page + 1) * 50) {
                                  page++;
                                  returnColuns();
                                  returnRows();
                                  setState(() {});
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      tableAux.length > (page + 1) * 50
                                          ? const Color(0xFFF26600)
                                          : Colors.grey)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  SizedBox(height: 4),
                                  Icon(Icons.arrow_forward),
                                  Text("Próxima página"),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              pickCsvFile();
                            },
                            child: const SizedBox(
                              height: double.maxFinite,
                              child: Center(
                                child: Text(
                                  "Importar novamente",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              var rng = Random();
                              int index = 0;
                              while (index == 0) {
                                index = rng.nextInt(tableAux.length);
                              }
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return FutureBuilder(
                                      future: Future.delayed(
                                          const Duration(seconds: 2)),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return AlertDialog(
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                CircularProgressIndicator(),
                                                SizedBox(
                                                  height: 64,
                                                ),
                                                Text(
                                                  "Sorteando o cliente...",
                                                  style: TextStyle(
                                                    color: Color(0xFFF26600),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return AlertDialog(
                                            title: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  "O número sorteado foi o:",
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                Text(
                                                  index < 10
                                                      ? "0" + index.toString()
                                                      : index.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 60,
                                                    color: Color(0xFFF26600),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: SvgPicture.asset(
                                                      'assets/images/balloon.svg'),
                                                ),
                                                const SizedBox(
                                                  height: 16,
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: "Nome: ",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: tableAux[index]
                                                                  [2]
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: "Cartão: ",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: tableAux[index]
                                                                  [3]
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    text: "Prêmio: ",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                        fontSize: 20),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: tableAux[index]
                                                                  [8]
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("Fechar"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                      });
                                },
                              );
                            },
                            child: const SizedBox(
                              height: double.maxFinite,
                              child: Center(
                                child: Text(
                                  "Sortear prêmio",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
