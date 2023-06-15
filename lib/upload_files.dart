import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadFilesPage extends StatefulWidget {
  const UploadFilesPage({
    Key? key,
  }) : super(key: key);

  @override
  _UploadFilesPageState createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: ${urlDownload}');
    setState(() {
      uploadTask = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Upload Files'),
      ),
      body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Expanded(
                child: Container(
                  color: Colors.blue[100],
                  //display preview file
                  child: Image.file(
                    File(pickedFile!.path!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  //display name of selected file
                  // child: Center(
                  //   child: Text(pickedFile!.name),
                  // ))
                ),
              ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: selectFile,
            child: const Text('Select File'),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: uploadFile,
            child: const Text('Upload File'),
          ),
          buildProgress(),
        ],
      )));

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: Colors.green,
                  ),
                  Center(
                      child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ))
                ],
              ));
        } else {
          return const SizedBox(height: 50);
        }
      });
}
