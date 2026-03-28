import 'dart:async';

import 'package:circle_wallet/circle_wallet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand Tokens
// ─────────────────────────────────────────────────────────────────────────────

abstract final class AppColors {
  static const background = Color(0xFF0D0F11);
  static const surface = Color(0xFF161A1E);
  static const surfaceVariant = Color(0xFF1C2126);
  static const border = Color(0xFF252A30);
  static const accent = Color(0xFF6172F3);
  static const Color primaryText = Colors.white;
  static const secondaryText = Color(0xFF9E9FA0);
  static const buttonBg = Color(0xFFFCFCFD);
  static const buttonText = Color(0xFF000000);
  static const error = Color(0xFFFF6584);
  static const success = Color(0xFF3CBA8B);
}

// ─────────────────────────────────────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/execute', builder: (context, state) => const ExecutePage()),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// App
// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Ribh Wallet SDK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          error: AppColors.error,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'OpenRunde',
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'OpenRunde',
          bodyColor: AppColors.primaryText,
          displayColor: AppColors.primaryText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.primaryText),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5),
          ),
          labelStyle: const TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.secondaryText.withAlpha(150),
            fontSize: 14,
          ),
          prefixIconColor: AppColors.secondaryText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBg,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: 'OpenRunde',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceVariant,
          contentTextStyle: const TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.primaryText,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(const MyApp());

// ─────────────────────────────────────────────────────────────────────────────
// Home Page
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// Execute Page
// ─────────────────────────────────────────────────────────────────────────────

class ExecutePage extends StatefulWidget {
  const ExecutePage({super.key});

  @override
  State<ExecutePage> createState() => _ExecutePageState();
}

class _ExecutePageState extends State<ExecutePage> {
  final _formKey = GlobalKey<FormState>();
  final _appIdController = TextEditingController();
  final _userTokenController = TextEditingController();
  final _encryptionKeyController = TextEditingController();
  final _challengeIdController = TextEditingController();

  bool _isExecuting = false;
  Map<String, dynamic>? _result;

  StreamSubscription<void>? _forgotPinSub;

  @override
  void initState() {
    super.initState();
    // Listen for "Forgot PIN?" events pushed from the native SDK.
    _forgotPinSub = forgotPinStream.listen((_) {
      if (!mounted) return;
      unawaited(_showRestorePinSheet());
    });
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _userTokenController.dispose();
    _encryptionKeyController.dispose();
    _challengeIdController.dispose();
    _forgotPinSub?.cancel();
    super.dispose();
  }

  // ── Forgot PIN restore flow ─────────────────────────────────────────────
  // Called when the user taps "Forgot PIN?" inside the SDK UI.
  // The app must:
  //  1. Call backend POST /user/pin/restore → get a restore challengeId.
  //  2. Invoke execute() again with that challengeId.

  Future<void> _showRestorePinSheet() async {
    final restoreChallengeController = TextEditingController();

    final challengeId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 28,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Restore PIN',
                style: TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Call your backend POST /user/pin/restore to obtain a restore challenge ID, then paste it below.',
                style: TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: restoreChallengeController,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.primaryText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: 'Restore Challenge ID',
                  hintText: 'e.g. restore-challenge-uuid',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final id = restoreChallengeController.text.trim();
                    if (id.isNotEmpty) Navigator.of(ctx).pop(id);
                  },
                  child: const Text('Restore PIN'),
                ),
              ),
            ],
          ),
        );
      },
    );

    restoreChallengeController.dispose();

    if (challengeId == null || challengeId.isEmpty) return;
    if (!mounted) return;

    // Re-execute with the restore challengeId.
    setState(() {
      _isExecuting = true;
      _result = null;
    });
    try {
      final result = await execute(
        appId: _appIdController.text.trim(),
        userToken: _userTokenController.text.trim(),
        encryptionKey: _encryptionKeyController.text.trim(),
        challengeId: challengeId,
      );
      if (!mounted) return;
      setState(() => _result = result);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Restore failed: $error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  Future<void> _onExecute() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isExecuting = true;
      _result = null;
    });
    try {
      final result = await execute(
        appId: _appIdController.text.trim(),
        userToken: _userTokenController.text.trim(),
        encryptionKey: _encryptionKeyController.text.trim(),
        challengeId: _challengeIdController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _result = result);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('$error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 24),
                      _buildExecuteButton(),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        _buildResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 4),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Execute Challenge',
                style: TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Fill in the fields to proceed',
                style: TextStyle(
                  fontFamily: 'OpenRunde',
                  color: AppColors.secondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(
              icon: Icons.apps_rounded,
              label: 'Application',
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _appIdController,
              label: 'App ID',
              hint: 'e.g. your-app-id',
              icon: Icons.fingerprint_rounded,
            ),
            const SizedBox(height: 24),
            const _SectionLabel(
              icon: Icons.lock_person_rounded,
              label: 'Authentication',
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _userTokenController,
              label: 'User Token',
              hint: 'Bearer token...',
              icon: Icons.badge_rounded,
              obscure: true,
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _encryptionKeyController,
              label: 'Encryption Key',
              hint: 'Base64 key...',
              icon: Icons.key_rounded,
              obscure: true,
            ),
            const SizedBox(height: 24),
            const _SectionLabel(
              icon: Icons.task_alt_rounded,
              label: 'Challenge',
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _challengeIdController,
              label: 'Challenge ID',
              hint: 'e.g. challenge-uuid',
              icon: Icons.tag_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecuteButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isExecuting ? null : _onExecute,
        child: _isExecuting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.buttonText,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Executing...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 22),
                  SizedBox(width: 8),
                  Text('Execute'),
                ],
              ),
      ),
    );
  }

  Widget _buildResultCard() {
    final entries = _result!.entries.toList();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.success),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Result',
                  style: TextStyle(
                    fontFamily: 'OpenRunde',
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${e.key}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.secondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      '  ·  ',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.border,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${e.value}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: AppColors.primaryText,
                          fontSize: 12,
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.secondaryText),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'OpenRunde',
            color: AppColors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatefulWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      style: const TextStyle(
        fontFamily: 'OpenRunde',
        color: AppColors.primaryText,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
      validator: (value) => (value == null || value.trim().isEmpty)
          ? '${widget.label} is required'
          : null,
    );
  }
}
