import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/foundation.dart';
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
  final ChatUser currentUser = ChatUser(
    id: '0',
    firstName: 'User',
    profileImage: 'https://i.pravatar.cc/1000?img=65',
  );
  final ChatUser geminiUser = ChatUser(
    id: '1',
    firstName: 'Gemini',
    profileImage: 'assets/gemi.png',
  );
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.cyan

        ,
        title: const Text(
          'Chat with the support team',
          style: TextStyle(fontSize: 20),
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
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
          )
        ],
      ),
      onSend: _handleSend,
      messages: messages,
    );
  }

  // Function to handle sending both text and images
  void _handleSend(ChatMessage chatMessage) {
    if (_selectedImage != null) {
      _sendMediaMessage(chatMessage.text, _selectedImage!);
      _selectedImage = null;  // Reset after sending
    } else {
      _sendTextMessage(chatMessage);
    }
  }

  // Function to pick an image and then let the user input a description
  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    _selectedImage = await picker.pickImage(source: ImageSource.camera);
  }

  // Function to send text-only messages
  void _sendTextMessage(ChatMessage chatMessage) {
    _addMessage(chatMessage);
    _processMessage(chatMessage.text);
  }

  // Function to send text with images
  void _sendMediaMessage(String text, XFile file) {
    final ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: text.isNotEmpty ? text : "[Image]",
      medias: [
        ChatMedia(
          url: file.path,
          fileName: "",
          type: MediaType.image,
        ),
      ],
    );
    _addMessage(chatMessage);
    _processMessage(text, file);
  }

  // Function to add a message to the chat
  void _addMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
  }

  // Function to process the message, optionally with an image
  void _processMessage(String text, [XFile? file]) async {
    try {
      String question = text.isNotEmpty ? text : "Image attached";
      List<Uint8List>? images;

      if (file != null) {
        images = [File(file.path).readAsBytesSync()];
      }

      // Listening to the response continuously (streaming)
      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;

        String response = event.content?.parts
            ?.fold("", (previous, current) => "$previous ${current.text}") ??
            "";

        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          final ChatMessage message = ChatMessage(
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
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
