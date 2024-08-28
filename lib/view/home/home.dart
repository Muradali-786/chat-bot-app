import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [];
  final gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(
    id: '0',
    firstName: 'user',
    profileImage: 'https://i.pravatar.cc/1000?img=65',
  );
  ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'gemini',
    profileImage: 'assets/gemi.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'ChatBot',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return DashChat(
      currentUser: currentUser,
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sentMediaMessage,
            icon: const Icon(Icons.image),
          )
        ],
      ),
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      //getting only text from chatmessage
      String question = chatMessage.text;

      // this is for getting images its optional field
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      //listening to response continuously (streaming)
      //here images is optional if you dont sent it will not count it
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        //checking if last message is from gemini is not null then we are continuously
        //in the previous message
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, element) => "$previous ${element.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  //for picking media pictures

  void _sentMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: '',
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );

      _sendMessage(chatMessage);
    }
  }
}

// ElevatedButton(
// onPressed: () async {
// try {
// await getResponse().then((e) {
// print('here is the response that you printed');
// print(e.toString());
// });
// } catch (e) {
// print('here is the error i am getting ');
// print(e.toString());
// }
// },
// child: const Text('Generate'),
// ),
