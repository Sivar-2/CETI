import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/loyalty_provider.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rewardController;
  bool _showRewardOverlay = false;

  @override
  void initState() {
    super.initState();
    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _rewardController.dispose();
    super.dispose();
  }

  void triggerRewardAnimation() {
    setState(() => _showRewardOverlay = true);
    _rewardController.forward(from: 0.0).then((_) {
      setState(() => _showRewardOverlay = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loyaltyProv = Provider.of<LoyaltyProvider>(context);
    final customer = loyaltyProv.selectedCustomer;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Section 1: Static QR Code to distribute Apple/Google Wallet links
                Card(
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          "Registro de Clientes (Apple/Google Wallet)",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Muestra este código al cliente para auto-registro de datos (Nombre, Correo, Cumpleaños) e instalación de pase nativo.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        QrImageView(
                          data: loyaltyProv.generateWalletRegistrationUrl("ceti_store_01"),
                          version: QrVersions.auto,
                          size: 180.0,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Scanning Terminal Gate
                ElevatedButton.icon(
                  onPressed: () async {
                    // Simulated camera scanner implementation intercepting Apple/Google Wallet pass data
                    bool success = await loyaltyProv.loadCustomerFromWalletPass("WP_SIM_99218");
                    if (success) triggerRewardAnimation();
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: AppColors.textPrimary),
                  label: const Text("ESCANEAR PASAPORTE WALLET (CÁMARA)", style: TextStyle(color: AppColors.textPrimary)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                ),
                const SizedBox(height: 16),

                // Section 3: Active Profile View with Wallet Badges
                if (customer != null)
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${customer.firstName} ${customer.lastName}",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              Chip(
                                label: Text(customer.tier),
                                backgroundColor: AppColors.primaryDim,
                                labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 8),
                          _buildProfileRow(Icons.email, "Correo", customer.email),
                          _buildProfileRow(Icons.cake, "Cumpleaños", "${customer.birthDate.day}/${customer.birthDate.month}/${customer.birthDate.year}"),
                          _buildProfileRow(Icons.star, "Puntos Acumulados", "${customer.points} PTS"),
                          if (customer.customFields.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text("Datos Personalizados", style: Theme.of(context).textTheme.labelSmall),
                            ...customer.customFields.entries.map((entry) => _buildProfileRow(Icons.add_box, entry.key, entry.value.toString())),
                          ],
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => loyaltyProv.clearSelection(),
                            child: const Center(child: Text("CERRAR CLIENTE")),
                          )
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // High Fidelity Premium Reward Gratification Layer
          if (_showRewardOverlay)
            AnimatedBuilder(
              animation: _rewardController,
              builder: (context, child) {
                return Container(
                  color: AppColors.primary.withValues(alpha: 0.3 * _rewardController.value),
                  child: Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(parent: _rewardController, curve: Curves.elasticOut),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wallet_membership, size: 80, color: AppColors.accent),
                            SizedBox(height: 16),
                            Text(
                              "¡Pase Sincronizado!",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 8),
                            Text("Cliente cargado y puntos validados", style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
