import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/ai_messaging_provider.dart';
import '../../../core/widgets/glass_card.dart';

class AiAssistantDrawer extends StatefulWidget {
  const AiAssistantDrawer({super.key});

  @override
  State<AiAssistantDrawer> createState() => _AiAssistantDrawerState();
}

class _AiAssistantDrawerState extends State<AiAssistantDrawer> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, // Extra padding
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(AiMessagingProvider aiProvider, String text) {
    if (text.trim().isEmpty) return;
    aiProvider.sendMessageToAi(text);
    _textController.clear();
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AiMessagingProvider>();
    
    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // Large Drawer
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        borderRadius: 0,
        color: AppColors.background.withValues(alpha: 0.95), // Solid frost
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CETI Assistant',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Especialista en Operaciones',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // QUICK ACTIONS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildActionChip(context, aiProvider, '¿Qué insumos están bajos?'),
                    const SizedBox(width: 8),
                    _buildActionChip(context, aiProvider, 'Resumen de ventas de hoy'),
                  ],
                ),
              ),

              // CHAT STREAM
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: aiProvider.messages.length + (aiProvider.isProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == aiProvider.messages.length) {
                      return _buildShimmerLoading();
                    }
                    final msg = aiProvider.messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              // INPUT AREA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Escribe tu consulta...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (val) => _sendMessage(aiProvider, val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: () => _sendMessage(aiProvider, _textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, AiMessagingProvider provider, String text) {
    return ActionChip(
      label: Text(text, style: GoogleFonts.inter(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primaryDim,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () => _sendMessage(provider, text),
    );
  }

  Widget _buildMessageBubble(AiMessage msg) {
    final isUser = msg.sender == SenderType.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          color: isUser ? AppColors.textPrimary : AppColors.primaryDim,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.inter(
            color: isUser ? Colors.white : AppColors.primary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Shimmer.fromColors(
        baseColor: AppColors.primaryDim,
        highlightColor: Colors.white,
        child: Container(
          width: 80,
          height: 40,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryDim,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
