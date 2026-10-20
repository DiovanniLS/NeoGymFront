import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../view_model/auth_view_model.dart';
import '../view_model/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String Image;
  final String chatId;
  final VoidCallback? onViewProfile;

  const ChatScreen({
    super.key,
    required this.name,
    required this.Image,
    required this.chatId,
    this.onViewProfile,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  late Stream<List<MessageModel>> _messagesStream;
  XFile? _selectedImage;
  bool _sending = false;


  @override
  void initState() {
    super.initState();

    _messagesStream = context
        .read<ChatViewModel>()
        .getMessages(widget.chatId);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    final imagem = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (imagem == null || !mounted) return;

    setState(() {
      _selectedImage = imagem;
    });
  }

  Future<void> _removerImagemSelecionada() async {
    setState(() {
      _selectedImage = null;
    });
  }

  void _recarregarMensagens() {
    setState(() {
      _messagesStream = context
          .read<ChatViewModel>()
          .getMessages(widget.chatId);
    });
  }

  Future<void> sendMessage() async {
    final texto = controller.text.trim();
    final imagem = _selectedImage;

    if ((texto.isEmpty && imagem == null) || _sending) {
      return;
    }

    final user = context.read<AuthViewModel>().user;

    if (user == null) return;

    setState(() => _sending = true);

    try {
      final chatViewModel = context.read<ChatViewModel>();

      String? imageUrl;

      if (imagem != null) {
        imageUrl = await chatViewModel.uploadImage(
          chatId: widget.chatId,
          image: imagem,
        );
      }

      await chatViewModel.sendMessage(
        chatId: widget.chatId,
        message: texto,
        senderName: user.nome,
        senderEmail: user.email,
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      controller.clear();

      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao enviar mensagem: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _confirmarExclusao(
      MessageModel message,
      ) async {
    if (message.id.isEmpty) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir mensagem?'),
        content: const Text(
          'Esta mensagem será removida da conversa.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await context.read<ChatViewModel>().deleteMessage(
        chatId: widget.chatId,
        messageId: message.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem excluída.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível excluir a mensagem: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    return Scaffold(
      appBar: UniversalAppBar(
        title: widget.name,
        imageUrl: widget.Image,
        showAvatar: true,
        leadingIcon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                if (widget.onViewProfile != null) {
                  widget.onViewProfile!();
                } else {
                  Navigator.pop(context);
                }
              } else if (value == 'bloquear') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'A funcionalidade de bloquear ainda não foi implementada.',
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "perfil", child: Text("Ver perfil")),
              const PopupMenuItem(value: "bloquear", child: Text("Bloquear")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Não foi possível carregar as mensagens.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _recarregarMensagens,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 52,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma mensagem ainda',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Envie uma mensagem para iniciar a conversa.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final user = context.read<AuthViewModel>().user;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
                    final isMe = msg.senderId == firebaseUid;

                    return GestureDetector(
                      onLongPress: isMe
                          ? () => _confirmarExclusao(msg)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                msg.senderName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 290),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (msg.imageUrl != null &&
                                        msg.imageUrl!.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                              child: InteractiveViewer(
                                                child: Image.network(
                                                  msg.imageUrl!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            msg.imageUrl!,
                                            width: 250,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (
                                                context,
                                                child,
                                                progress,
                                                ) {
                                              if (progress == null) return child;

                                              return const SizedBox(
                                                width: 220,
                                                height: 150,
                                                child: Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                            const SizedBox(
                                              width: 220,
                                              height: 80,
                                              child: Center(
                                                child: Text('Erro ao carregar foto'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (msg.text.trim().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          msg.text,
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_selectedImage!.path),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Foto pronta para enviar'),
                  ),
                  IconButton(
                    tooltip: 'Remover foto',
                    onPressed: _sending
                        ? null
                        : _removerImagemSelecionada,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Selecionar foto',
                  onPressed: _sending ? null : _selecionarImagem,
                  icon: const Icon(Icons.image_outlined),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sending ? null : sendMessage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _sending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.send),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}
