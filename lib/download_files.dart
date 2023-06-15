import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class DownloadFilesPage extends StatefulWidget {
  const DownloadFilesPage({
    Key? key,
  }) : super(key: key);

  @override
  _DownloadFilesPageState createState() => _DownloadFilesPageState();
}

class _DownloadFilesPageState extends State<DownloadFilesPage> {
  late Future<ListResult> futureFiles;
  Map<int,double> downloadProgress = {};

  @override
  void initState() {
    super.initState();

    futureFiles = FirebaseStorage.instance.ref('/files').listAll();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(
            title: const Text('Download Files'),
          ),
          body: FutureBuilder<ListResult>(
              future: futureFiles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final files = snapshot.data!.items;

                  return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                          final file = files[index];
                          double? progress = downloadProgress[index];

                          return ListTile(
                            title: Text(file.name),
                            subtitle: progress != null
                              ? LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.black26,
                                )
                              : null,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Colors.black,
                              ),
                              onPressed: () => downloadFile(index, file),
                            )
                          );
                  });
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              }
          )
      );

  Future downloadFile(int index, Reference ref) async {
    final url = await ref.getDownloadURL();
    
    //Visible to User inside Gallery on device
    final tempdir = await getTemporaryDirectory();
    final path = '${tempdir.path}/${ref.name}';
    await Dio().download(
        url,
        path,
        onReceiveProgress: (received, total) {
          double progress = received / total; //display percentage of progress bar

          setState(() {
            downloadProgress[index] = progress;
          });
        },
    );

    //Not visible for user, only this app can access file
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File("${dir.path}/${ref.name}");
    //
    // await ref.writeToFile(file);

    //toDcim: true -> file will be moved to DCIM dir isntead of device's external storage
    if(url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true, albumName: 'My Flutter Images');
    };

    Fluttertoast.showToast(
      msg: 'Downloaded ${ref.name}',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.lightGreen,
      textColor: Colors.white,
    );

  }
}
