import 'package:circle_wallet/circle_wallet.dart';
import 'package:circle_wallet_example/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platformName;
  bool _isLoading = false;

  Future<void> _getPlatformName() async {
    setState(() => _isLoading = true);
    try {
      final result = await getPlatformName();
      if (!mounted) return;
      setState(() => _platformName = result);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('$error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildPlatformCard(),
              const Spacer(),
              _buildExecuteNavButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(26),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withAlpha(60),
            ),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.accent,
            size: 26,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Ribh Wallet',
          style: TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.primaryText,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'SDK Example App',
          style: TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.secondaryText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.secondaryText,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Platform Info',
                  style: TextStyle(
                    fontFamily: 'OpenRunde',
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_platformName != null) ...[
              Text(
                _platformName!,
                style: const TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
            ] else
              Text(
                'Not fetched yet',
                style: TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.secondaryText.withAlpha(150),
                  fontSize: 15,
                ),
              ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _getPlatformName,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.buttonText,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  _isLoading ? 'Fetching...' : 'Get Platform Name',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecuteNavButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/execute'),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Execute Challenge'),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
