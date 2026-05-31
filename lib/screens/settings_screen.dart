import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = '₱';
  String _themeMode = 'system';

  static const _currencies = [
    _CurrencyOption(symbol: '₱', name: 'Philippine Peso'),
    _CurrencyOption(symbol: '\$', name: 'US Dollar'),
    _CurrencyOption(symbol: '€', name: 'Euro'),
    _CurrencyOption(symbol: '£', name: 'British Pound'),
    _CurrencyOption(symbol: '¥', name: 'Japanese Yen'),
    _CurrencyOption(symbol: '₩', name: 'Korean Won'),
    _CurrencyOption(symbol: '₹', name: 'Indian Rupee'),
  ];

  static const _themes = [
    _ThemeOption(
      value: 'light',
      label: 'Light',
      icon: Icons.light_mode_rounded,
    ),
    _ThemeOption(value: 'dark', label: 'Dark', icon: Icons.dark_mode_rounded),
    _ThemeOption(
      value: 'system',
      label: 'System',
      icon: Icons.settings_brightness_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currency = await DatabaseService.getSetting('currency');
    final theme = await DatabaseService.getSetting('themeMode');
    if (!mounted) return;
    setState(() {
      _currency = currency ?? '₱';
      _themeMode = theme ?? 'system';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCurrencySection(),
            const SizedBox(height: 20),
            _buildThemeSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection() {
    final selected = _currencies.firstWhere(
      (c) => c.symbol == _currency,
      orElse: () => _currencies.first,
    );

    return Container(
      decoration: AppDecorations.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.attach_money_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Currency',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text(
              'Selected: ${selected.symbol} ${selected.name}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_currencies.length, (index) {
            final currency = _currencies[index];
            final isSelected = _currency == currency.symbol;
            return InkWell(
              onTap: () async {
                setState(() => _currency = currency.symbol);
                await DatabaseService.setSetting('currency', currency.symbol);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          currency.symbol,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        currency.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: _themes.map((theme) {
              final isSelected = _themeMode == theme.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    setState(() => _themeMode = theme.value);
                    await DatabaseService.setSetting('themeMode', theme.value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: theme.value != 'system' ? 10 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          theme.icon,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey[500],
                          size: 26,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          theme.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CurrencyOption {
  final String symbol;
  final String name;

  const _CurrencyOption({required this.symbol, required this.name});
}

class _ThemeOption {
  final String value;
  final String label;
  final IconData icon;

  const _ThemeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}
