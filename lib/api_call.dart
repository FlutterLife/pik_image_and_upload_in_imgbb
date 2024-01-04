import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> upload(File imageFile) async {
  var uri = Uri.parse(
      "https://api.imgbb.com/1/upload?expiration=600&key=53d5215971d73d4db16e5dfbf5925a69");
  var request = http.MultipartRequest("POST", uri);
  var multipartFile = http.MultipartFile.fromBytes(
    'image',
    imageFile.readAsBytesSync(),
    filename: "${DateTime.now().microsecondsSinceEpoch}.jpg",
    contentType: MediaType("image", "jpg"),
  );
  request.files.add(multipartFile);
  String myimage = "";

  try {
    var response = await request.send();
    print(response.statusCode);

    // Parse the response as JSON
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);

    // Extract the image URL from the JSON response
    myimage = jsonResponse['data']['display_url'];
  } catch (error) {
    print('Error uploading image: $error');
  }
  return myimage;
}
