import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/providers/inventory_provider.dart';
import '../../core/models/product_model.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _currency = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = inventory.catalog;

    return Container(
      color: AppColors.background, // Warm Slate #F9F8F6
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Escandallo',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary, // Deep Slate #1E1B24
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      'Motor BOM',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GoldOutlineButton(
                    label: '+ Producto',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final product = products[i];
                return _ProductEscandalloCard(product: product, currency: _currency, inventory: inventory)
                    .animate(delay: (i * 60).ms)
                    .fadeIn()
                    .slideX(begin: -0.1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BOM Product Card ────────────────────────────────────────────────────────

class _ProductEscandalloCard extends StatelessWidget {
  const _ProductEscandalloCard({
    required this.product, 
    required this.currency,
    required this.inventory,
  });

  final Product product;
  final NumberFormat currency;
  final InventoryProvider inventory;

  @override
  Widget build(BuildContext context) {
    // Check if the product has sufficient stock using Poka-Yoke check
    final isAvailable = inventory.hasSufficientStock(product, 1);
    
    // Dynamic recalculation of BOM
    double dynamicTotalCost = 0;
    for (var comp in product.recipe) {
      final supply = inventory.supplies[comp.supplyId];
      if (supply != null) {
        dynamicTotalCost += supply.costPerUnit * comp.quantityRequired;
      }
    }
    
    final margin = product.price > 0 
        ? ((product.price - dynamicTotalCost) / product.price) * 100 
        : 0.0;
        
    final isLowMargin = margin < 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Clean White #FFFFFF
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAvailable ? AppColors.border : AppColors.secondary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(product.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary, // Deep Slate #1E1B24
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(label: 'Venta: ${currency.format(product.price)}', color: AppColors.success),
                          if (!isAvailable) ...[
                            const SizedBox(width: 8),
                            _InfoChip(label: 'Stock Insuficiente', color: AppColors.secondary), // Soft Terracotta
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 16),
                    
                    // Financial Indicators
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Costo Base Total',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11), // Muted Taupe #6E6A75
                              ),
                              Text(
                                currency.format(dynamicTotalCost),
                                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Margen de Ganancia',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              Text(
                                '${margin.toStringAsFixed(1)}%',
                                style: GoogleFonts.inter(
                                  color: isLowMargin ? AppColors.secondary : AppColors.success, 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w800
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Panel de Escandallo (Insumos)',
                      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    
                    // Breakdown List
                    ...product.recipe.map((comp) {
                      final supply = inventory.supplies[comp.supplyId];
                      final bool isLowStock = supply?.isCritical ?? true;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${comp.quantityRequired} ${comp.unit} de ${comp.supplyName}',
                                style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13), // Muted Taupe
                              ),
                            ),
                            if (isLowStock)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Bajo (${supply?.stockActual.toStringAsFixed(1) ?? 0})',
                                  style: GoogleFonts.inter(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            Text(
                              currency.format(comp.quantityRequired * (supply?.costPerUnit ?? 0)),
                              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color, 
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
