import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pik_image_and_upload_in_imgbb/api_call.dart';

FilePickerResult? result;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> requestPermission() async {
    const permission = Permission.manageExternalStorage;
    if (await permission.isDenied) {
      final result = await permission.request();
      if (result.isGranted) {
        print("Permission is granted");
        // Permission is granted
      } else if (result.isDenied) {
        print("Permission is denied");
        // Permission is denied
      } else if (result.isPermanentlyDenied) {
        print("Permission is permanently denied");
        // Permission is permanently denied
      }
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              result = await FilePicker.platform.pickFiles(allowMultiple: true);

              setState(() {});
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Card(
                    child: Container(
                      alignment: Alignment.center,
                      height: 70,
                      width: double.infinity,
                      child: const Text("Add File"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          result == null || result!.files.isEmpty
              ? const SizedBox()
              : GestureDetector(
                  onTap: () {
                    result!.files.clear();
                    setState(() {});
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.close), Text("Delete All")],
                  ),
                ),
          Expanded(
            child: result == null || result!.files.isEmpty
                ? const Center(
                    child: Text("plz Add File"),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: result!.files.length,
                    itemBuilder: (context, index) {
                      final file = result!.files[index];
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          buildFile(file),
                          IconButton(
                            onPressed: () {
                              upload(File(result!.files[0].path.toString()));
                              // ApiHelper.apiHelper
                              //     .callApi(File(file.path.toString()));
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void openFile(PlatformFile file) {
    OpenFile.open(file.path!);
  }

  Widget buildFile(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${mb.toStringAsFixed(2)} KB';
    final extension = file.extension ?? 'none';
    return InkWell(
      onTap: () => openFile(file),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: extension == 'jpg' || extension == 'jpeg'
                  ? Container(
                      alignment: Alignment.center,
                      // width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        image: DecorationImage(
                            image: FileImage(
                              File(
                                file.path.toString(),
                              ),
                            ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: extension == 'mp3'
                            ? Colors.red
                            : extension == 'mp4'
                                ? Colors.pink
                                : extension == 'txt'
                                    ? Colors.purple
                                    : extension == 'jpeg'
                                        ? Colors.greenAccent
                                        : extension == 'xlsx'
                                            ? Colors.grey
                                            : extension == 'pdf'
                                                ? Colors.indigo
                                                : Colors.yellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '.$extension',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              file.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              fileSize,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
