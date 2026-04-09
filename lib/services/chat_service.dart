import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? productId;
  final String? size;
  final String? color;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.productId,
    this.size,
    this.color,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'HELLO! I AM YOUR FITZONE VIRTUAL ASSISTANT. HOW CAN I ELEVATE YOUR JOURNEY TODAY?',
      isUser: false,
    ),
  ];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get hasHistory => _messages.length > 1;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: 'HELLO! I AM YOUR FITZONE VIRTUAL ASSISTANT. HOW CAN I ELEVATE YOUR JOURNEY TODAY?',
      isUser: false,
    ));
    notifyListeners();
  }

  void replaceWithHistory(List<ChatMessage> history) {
    _messages.clear();
    _messages.addAll(history);
    notifyListeners();
  }
}
