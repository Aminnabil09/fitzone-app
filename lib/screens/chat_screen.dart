import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../api_keys.dart';

import '../services/cart_service.dart';
import '../services/chat_service.dart';
import '../services/locale_service.dart';
import '../services/product_service.dart';
import '../services/theme_service.dart';
import '../widgets/animated_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiKeys.geminiApiKey,
      systemInstruction: Content.system('''
You are the "FitZone Elite Concierge" - an advanced, highly intelligent luxury sales assistant for FitZone store.

MULTILINGUAL RULES:
1. Detect language. Reply ONLY in English, Arabic, or Central Kurdish (Sorani).
2. ENGLISH: ALL words MUST be UPPERCASE.
3. Arabic/Kurdish: Use formal luxury vocabulary.

MANDATORY BACKEND TOKEN - NON-NEGOTIABLE:
- After your text, embed a silent machine-readable token. App strips it automatically. User never sees it.
- You are NOT displaying. Flutter UI handles that. You pass a backend signal only.
- Whenever a user mentions, wants, or asks about any product - embed the token at the very END of your reply.
- Token formats: [PRODUCT|ID|Size|Color] or [PRODUCT|ID|Size] or [PRODUCT|ID]
- NEVER say you cannot display. NEVER explain the token. Just emit it.
- Example: "AN EXCELLENT CHOICE! WHAT COLOR? [PRODUCT|3|M]"

SALES RULES:
- End every reply with a forward-moving question.
- Never say cheap - say ENTRY-LEVEL PREMIUM OPTION.
- FitZone topics only.

FULL PRODUCT CATALOG (use exact IDs):
FOOTBALL: ID1=Liverpool Kit(S-XXXL,Red/Teal/Cream) ID2=ManCity Kit(S-XXL,Blue/White) ID3=RealMadrid Kit(S-XXXL,White/Gold) ID4=Barcelona Kit(S-XXL,Blue/Red) ID5=Chelsea Kit(S-XXL,Blue/White) ID6=Arsenal Kit(S-XXL,Red/White) ID7=ManUnited Kit(S-XXXL,Red/White) ID8=Bayern Kit(S-XXL,Red/White) ID9=FootballBoots(40-45,Black/White/Blue)
BASKETBALL: ID10=Basketball Jersey(S-XL,Red/Blue/Black) ID11=Basketball Shoes(40-45,Black/White/Red) ID12=Basketball(Size7,Orange)
RUNNING: ID13=Running Shoes(40-45,Black/White/Blue) ID14=Running Shorts(S-XL,Black/Grey/Blue) ID15=Running Watch(OneSize,Black/White)
GYM: ID16=Gym Shorts(S-XL,Black/Grey/Blue) ID17=Dumbbells Set(5kg-25kg,Black) ID18=Resistance Bands(Set5,Multi)
CLOTHING: ID35=Athletic T-Shirt(S-XXL,Black/White/Grey/Blue) ID36=Sports Jacket(S-XL,Black/Navy/Grey)
SHOES: ID37=Training Shoes(40-45,Black/White/Grey) ID38=Walking Shoes(40-45,Black/White/Brown)
ACCESSORIES: ID39=Sports Watch(OneSize,Black/Silver) ID40=Gym Bag(OneSize,Black/Grey/Blue) ID41=Water Bottle(750ml,Black/White/Blue/Pink)
EQUIPMENT: ID42=Yoga Mat(Standard,Purple/Blue/Pink/Black) ID43=Jump Rope(OneSize,Black/Red/Blue) ID44=Kettlebell(8-20kg,Black)
NUTRITION: ID23=Protein Powder(2.3kg/5kg,Black) ID24=Creatine(300g-1kg,White) ID25=BCAA(400g/800g,White) ID26=Multivitamin(60/120tabs,Multi) ID27=VitaminD3(60/120caps,Clear) ID28=VitaminC(60/120tabs,Orange) ID29=Omega3(60/120caps,Clear) ID30=Pre-Workout(400g/800g,Multi) ID31=Post-Workout(500g/1kg,Multi) ID32=Energy Bars(12Pack,Multi) ID33=Zinc Supplement(60/120tabs,White) ID34=Magnesium(60/120tabs,White)
OUTDOOR: ID45=Hiking Backpack(30L,Black/Green/Blue) ID46=Camping Tent(2Person,Green/Blue)
YOGA: ID47=Yoga Block(Standard,Purple/Blue/Pink) ID48=Meditation Cushion(Standard,Purple/Blue/Beige)
KIDS: ID49=Kids Football Kit(XS-M,Red/Blue/Green) ID50=Kids Basketball(Size5,Orange)
BOXING: ID51=Boxing Gloves(12oz-16oz,Red/Black/Blue) ID52=Punching Bag(50kg/70kg,Black/Red)
DEALS: ID53=Sports Bundle Pack(M-XL,Multi) ID54=Fitness Starter Kit(StarterKit,Multi)

Returns: support@fitzone.com. 30-day return policy.
'''),
    );

    _chatSession = _model.startChat();
    _loadChatHistory();
  }

  String get _documentId => AuthService().currentNumericId ?? '';
  CollectionReference get _chatRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_documentId)
      .collection('chat_history');

  Future<void> _loadChatHistory() async {
    if (_documentId.isEmpty) return;
    final snap =
        await _chatRef.orderBy('timestamp', descending: false).limit(50).get();
    if (snap.docs.isEmpty) return;
    final allProducts = ProductService().products;
    final history = <ChatMessage>[];
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Restore user message
      history.add(ChatMessage(text: data['user_message'] ?? '', isUser: true));
      // Restore AI response
      final productId = data['product_id'] as String?;
      final matchedProduct = productId != null
          ? allProducts.indexWhere((p) => p.id == productId)
          : -1;
      history.add(ChatMessage(
        text: data['ai_response'] ?? '',
        isUser: false,
        productId: productId,
        size: data['size'] as String?,
        color: data['color'] as String?,
      ));
      // Also feed history back to the Gemini session so context is restored
      if (matchedProduct != -1) {
        _chatSession
            .sendMessage(Content.text(data['user_message'] ?? ''))
            .ignore();
      }
    }
    // Replace greeting with real history if we have history
    ChatService().messages.length == 1 && history.isNotEmpty
        ? ChatService().replaceWithHistory(history)
        : null;
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      ChatService().addMessage(ChatMessage(text: messageText, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response =
          await _chatSession.sendMessage(Content.text(messageText));
      if (mounted) {
        String rawText =
            response.text ?? 'I APOLOGIZE, BUT I AM CURRENTLY UNAVAILABLE.';
        String? extractedProductId;
        String? extractedSize;
        String? extractedColor;

        final regExpFull = RegExp(r'\[PRODUCT\|(.*?)\|(.*?)\|(.*?)\]');
        final matchFull = regExpFull.firstMatch(rawText);
        if (matchFull != null) {
          extractedProductId = matchFull.group(1);
          extractedSize = matchFull.group(2);
          extractedColor = matchFull.group(3);
          rawText = rawText.replaceAll(regExpFull, '').trim();
        } else {
          final regExpPartial = RegExp(r'\[PRODUCT\|(.*?)\]');
          final matchPartial = regExpPartial.firstMatch(rawText);
          if (matchPartial != null) {
            extractedProductId = matchPartial.group(1);
            rawText = rawText.replaceAll(regExpPartial, '').trim();
          }
        }

        final cleanedAiText = rawText.toUpperCase();

        // 🔥 SAVE TO FIREBASE FIRESTORE (per user) 🔥
        if (_documentId.isNotEmpty) {
          _chatRef.add({
            'user_message': messageText,
            'ai_response': cleanedAiText,
            'product_id': extractedProductId,
            'size': extractedSize,
            'color': extractedColor,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        setState(() {
          _isTyping = false;
          ChatService().addMessage(ChatMessage(
            text: cleanedAiText,
            isUser: false,
            productId: extractedProductId,
            size: extractedSize,
            color: extractedColor,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          ChatService()
              .addMessage(ChatMessage(text: 'SYSTEM ERROR: $e', isUser: false));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([LocaleService(), ThemeService(), ChatService()]),
      builder: (context, child) {
        final messages = ChatService().messages;
        return Scaffold(
          body: AnimatedBackground(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(messages[index]);
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon:
            Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            LocaleService().translate('CONCIERGE'),
            style: LocaleService().getTextStyle(
              baseStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w200,
                letterSpacing: 8,
                fontSize: 18,
                color: AppTheme.textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleService().translate('ONLINE • ALWAYS HERE'),
            style: GoogleFonts.outfit(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              fontSize: 8,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline,
              color: AppTheme.textColor.withValues(alpha: 0.4), size: 20),
          tooltip: 'Clear History',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.backgroundColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                title: Text('CLEAR HISTORY',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor,
                        letterSpacing: 2,
                        fontSize: 14)),
                content: Text('This will erase the entire conversation.',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor.withValues(alpha: 0.5),
                        fontSize: 12)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('CANCEL',
                          style: GoogleFonts.outfit(
                              color:
                                  AppTheme.textColor.withValues(alpha: 0.4)))),
                  TextButton(
                    onPressed: () {
                      ChatService().clearHistory();
                      Navigator.pop(ctx);
                    },
                    child: Text('CLEAR',
                        style: GoogleFonts.outfit(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: message.isUser ? 64 : 0,
            right: message.isUser ? 0 : 64,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: message.isUser
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.textColor.withValues(alpha: 0.02),
            border: Border.all(
              color: message.isUser
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : AppTheme.textColor.withValues(alpha: 0.05),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: GoogleFonts.outfit(
                  color: message.isUser
                      ? AppTheme.primaryColor
                      : AppTheme.textColor.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                  letterSpacing: 1,
                ),
              ),
              _buildInlineProductCard(message),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInlineProductCard(ChatMessage message) {
    if (message.productId == null) return const SizedBox.shrink();

    final allProducts = ProductService().products;
    final productIndex =
        allProducts.indexWhere((p) => p.id == message.productId);
    if (productIndex == -1) return const SizedBox.shrink();

    final product = allProducts[productIndex];
    final size =
        message.size?.isNotEmpty == true ? message.size! : product.sizes.first;
    final color = message.color?.isNotEmpty == true
        ? message.color!
        : product.colors.first;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(product.imageUrl), fit: BoxFit.cover),
                border: Border.all(
                    color: AppTheme.textColor.withValues(alpha: 0.1),
                    width: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor,
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold),
                      maxLines: 1),
                  const SizedBox(height: 4),
                  Text('SIZE: $size • COLOR: $color'.toUpperCase(),
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.6),
                          fontSize: 8,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor, fontSize: 10)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                CartService().addToCart(product, size, color);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'ADDED TO CART: ${product.name.toUpperCase()} ($size)',
                        style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    backgroundColor: AppTheme.primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(color: AppTheme.primaryColor),
                child: Text('ADD',
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.02),
            border: Border.all(
                color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '...',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
            top: BorderSide(
                color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.textColor.withValues(alpha: 0.03),
                border: Border.all(
                    color: AppTheme.textColor.withValues(alpha: 0.1),
                    width: 0.5),
              ),
              child: TextField(
                controller: _messageController,
                style:
                    GoogleFonts.inter(color: AppTheme.textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'TYPE YOUR INQUIRY...',
                  hintStyle: GoogleFonts.inter(
                      color: AppTheme.textColor.withValues(alpha: 0.24),
                      fontSize: 12,
                      letterSpacing: 1),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _isTyping ? null : _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isTyping
                    ? AppTheme.primaryColor.withValues(alpha: 0.5)
                    : AppTheme.primaryColor,
                border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
