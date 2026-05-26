import 'package:flutter/foundation.dart';
import 'inventory_provider.dart';
import 'dashboard_provider.dart';

enum SenderType { user, aiAssistant }

class AiMessage {
  final String id;
  final String text;
  final SenderType sender;
  final DateTime timestamp;

  AiMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

class AiMessagingProvider extends ChangeNotifier {
  final InventoryProvider inventory;
  final DashboardProvider dashboard;
  
  AiMessagingProvider({required this.inventory, required this.dashboard}) {
    // Seed system prompt context / greeting
    _messages.add(AiMessage(
      id: 'msg_0',
      text: '¡Hola! Soy tu asistente de operaciones CETI. Puedo analizar tu inventario, ventas y alertarte sobre insumos bajos. ¿En qué te puedo ayudar hoy?',
      sender: SenderType.aiAssistant,
      timestamp: DateTime.now(),
    ));
  }

  final List<AiMessage> _messages = [];
  bool _isProcessing = false;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;

  Future<void> sendMessageToAi(String prompt) async {
    if (prompt.trim().isEmpty) return;

    // 1. Optimistically append user message
    final userMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt.trim(),
      sender: SenderType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    
    _isProcessing = true;
    notifyListeners();

    // 2. Simulate AI Processing Network Request
    await Future.delayed(const Duration(seconds: 2));

    // 3. Poka-Yoke Contextual Operations Analysis
    String aiResponseText = _analyzePromptContext(prompt.trim().toLowerCase());

    final aiMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: aiResponseText,
      sender: SenderType.aiAssistant,
      timestamp: DateTime.now(),
    );

    _messages.add(aiMsg);
    _isProcessing = false;
    notifyListeners();
  }

  String _analyzePromptContext(String lowerPrompt) {
    // Simulate AI LLM logic matching intents
    if (lowerPrompt.contains('insumo') || lowerPrompt.contains('bajo') || lowerPrompt.contains('inventario')) {
      final criticals = inventory.criticalSupplies;
      if (criticals.isEmpty) {
        return 'Tu inventario está en niveles óptimos. No hay insumos críticos en este momento. ✅';
      }
      final listStr = criticals.map((s) => '- ${s.name}: ${s.stockActual} ${s.unit}').join('\n');
      return '¡Atención! Tienes los siguientes insumos bajo el nivel mínimo:\n$listStr\n\n¿Deseas que prepare una orden de compra?';
    } 
    
    if (lowerPrompt.contains('venta') || lowerPrompt.contains('resumen') || lowerPrompt.contains('hoy')) {
      final sales = dashboard.todaySales;
      final completed = dashboard.completedOrders;
      return 'Hoy has cerrado $completed órdenes con un total de \$${sales.toStringAsFixed(2)} en ventas. ¡Excelente trabajo! 📈';
    }

    return 'Entendido. Estoy procesando tu solicitud para optimizar las operaciones. (Simulación de API Text-Gen completada)';
  }
}
