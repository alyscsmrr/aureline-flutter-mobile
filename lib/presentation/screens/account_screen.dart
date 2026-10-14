import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../common/widgets.dart';
import '../../services/account_store.dart';
import '../../services/auth_service.dart';
import 'sign_in_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  bool changingPassword = false;
  bool editingProfile = false;
  bool twoFactorEnabled = false;
  bool toggling2FA = false;
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passportController = TextEditingController();
  final TextEditingController twoFAPasswordController = TextEditingController();
  String passwordError = '';
  String twoFAPasswordError = '';
  String profileError = '';
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;
  bool obscureTwoFAPassword = true;
  bool? _pendingTwoFAValue; // tracks whether we're enabling or disabling

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passportController.dispose();
    twoFAPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    passwordError = '';
    if (AccountStore.instance.signedIn) {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final token = AccountStore.instance.token;
      if (token != null) {
        final data = await AuthService.getProfile(token);
        if (!mounted) return;
        setState(() {
          profile = data;
          twoFactorEnabled = data['twoFactorEnabled'] as bool? ?? false;
          // Populate edit controllers
          firstNameController.text = data['firstName'] as String? ?? '';
          lastNameController.text = data['lastName'] as String? ?? '';
          phoneController.text = data['phone'] as String? ?? '';
          addressController.text = data['address'] as String? ?? '';
          passportController.text = data['passport'] as String? ?? '';
        });
      }
    } catch (e) {
      if (mounted) showAppMessage(context, 'Failed to load profile: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AccountStore.instance.signedIn) return const SignInScreen(embedded: true);

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _ProfileHeader()),
                  if (profile != null) _ProfileContent() else _EmptyProfile(),
                ],
              ),
      ),
    );
  }

  Widget _ProfileHeader() {
    final name = AccountStore.instance.name ?? 'Guest';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: forest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'G',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AccountStore.instance.email ?? '',
                  style: const TextStyle(
                    color: Color(0xFFD4DCC8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ProfileContent() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileSection(
              title: 'Personal Information',
              children: [
                if (editingProfile) ...[
                  _EditTextField(
                    label: 'First Name',
                    controller: firstNameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']")),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  _EditTextField(
                    label: 'Last Name',
                    controller: lastNameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']")),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  _EditTextField(
                    label: 'Phone',
                    controller: phoneController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  _EditTextField(
                    label: 'Address',
                    controller: addressController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s#\-']")),
                      LengthLimitingTextInputFormatter(200),
                    ],
                  ),
                  _EditTextField(
                    label: 'ID / Passport',
                    controller: passportController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\-]")),
                      LengthLimitingTextInputFormatter(20),
                    ],
                  ),
                  if (profileError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        profileError,
                        style: const TextStyle(color: Color(0xFFF44336), fontSize: 12),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _saveProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: forest,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            editingProfile = false;
                            profileError = '';
                            // Reset controllers to original values
                            firstNameController.text = profile?['firstName'] ?? '';
                            lastNameController.text = profile?['lastName'] ?? '';
                            phoneController.text = profile?['phone'] ?? '';
                            addressController.text = profile?['address'] ?? '';
                            passportController.text = profile?['passport'] ?? '';
                          }),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: forest,
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _ProfileField(
                    label: 'First Name',
                    value: profile?['firstName'] ?? '',
                  ),
                  _ProfileField(
                    label: 'Last Name',
                    value: profile?['lastName'] ?? '',
                  ),
                  _ProfileField(
                    label: 'Email',
                    value: profile?['email'] ?? '',
                  ),
                  _ProfileField(
                    label: 'Phone',
                    value: profile?['phone'] ?? '',
                  ),
                  _ProfileField(
                    label: 'Address',
                    value: profile?['address'] ?? '',
                  ),
                  _ProfileField(
                    label: 'ID / Passport',
                    value: profile?['passport'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => editingProfile = true),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit profile'),
                      style: TextButton.styleFrom(foregroundColor: forest),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _SecuritySection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await AccountStore.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/hotel');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _EmptyProfile() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_outline, size: 64, color: muted),
            const SizedBox(height: 16),
            Text(
              'Profile not available',
              style: GoogleFonts.playfairDisplay(fontSize: 24, color: ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load your profile information.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await AccountStore.instance.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/hotel');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ProfileSection({required String title, required List<Widget> children}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _ProfileField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              fontSize: 14,
              color: value.isNotEmpty ? ink : muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _EditTextField({
    required String label,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: forest, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => profileError = '');
    
    if (firstNameController.text.trim().isEmpty) {
      setState(() => profileError = 'First name is required');
      return;
    }
    if (lastNameController.text.trim().isEmpty) {
      setState(() => profileError = 'Last name is required');
      return;
    }

    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        throw Exception('You must be logged in');
      }

      await AuthService.updateProfile(
        token: token,
        data: {
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'passport': passportController.text.trim(),
        },
      );

      if (mounted) {
        showAppMessage(context, 'Profile updated successfully');
        setState(() {
          editingProfile = false;
          profileError = '';
        });
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        setState(() => profileError = e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showOtpDialog({
    required String email,
    required String purpose,
    required Function(String) onVerified,
  }) {
    final otpController = TextEditingController();
    bool otpBusy = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Enter Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('We sent a 6-digit code to $email.'),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: otpBusy
                  ? null
                  : () {
                      Navigator.pop(context);
                      // Reset state if cancelled
                      setState(() {
                        toggling2FA = false;
                        changingPassword = false;
                        _pendingTwoFAValue = null;
                      });
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: otpBusy
                  ? null
                  : () async {
                      if (otpController.text.length != 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a 6-digit code')),
                        );
                        return;
                      }

                      setDialogState(() => otpBusy = true);
                      final error = await AccountStore.instance.verifyOtp(
                        email.trim().toLowerCase(),
                        otpController.text,
                      );

                      if (!mounted) return;
                      setDialogState(() => otpBusy = false);

                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error)),
                        );
                        return;
                      }

                      Navigator.pop(context);
                      onVerified(otpController.text);
                    },
              child: Text(otpBusy ? 'Verifying...' : 'Verify'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTwoFactor(bool enable) async {
    final password = twoFAPasswordController.text;

    if (password.isEmpty) {
      setState(() => twoFAPasswordError = 'Please enter your current password');
      return;
    }

    setState(() {
      toggling2FA = true;
      twoFAPasswordError = '';
    });

    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        throw Exception('You must be logged in');
      }

      // Verify password before changing 2FA state
      await AuthService.verifyPassword(
        currentPassword: password,
        token: token,
      );

      // Send OTP and show verification dialog
      final email = AccountStore.instance.email;
      if (email == null) {
        throw Exception('Email not found');
      }

      final error = await AccountStore.instance.sendOtp(email, enable ? 'Enable 2FA' : 'Disable 2FA');
      if (error != null) {
        throw Exception(error);
      }

      // Show OTP dialog
      if (mounted) {
        _showOtpDialog(
          email: email,
          purpose: enable ? 'Enable 2FA' : 'Disable 2FA',
          onVerified: (otp) async {
            try {
              // Update 2FA setting
              await AuthService.updateProfile(
                token: token,
                data: {'twoFactorEnabled': enable},
              );

              if (mounted) {
                setState(() {
                  twoFactorEnabled = enable;
                  _pendingTwoFAValue = null;
                  twoFAPasswordController.clear();
                });
                showAppMessage(
                  context,
                  enable ? 'Two-factor authentication enabled' : 'Two-factor authentication disabled',
                );
              }
            } catch (e) {
              if (mounted) {
                setState(() => twoFAPasswordError = e.toString().replaceAll('Exception: ', ''));
              }
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => twoFAPasswordError = e.toString().replaceAll('Exception: ', ''));
        setState(() => toggling2FA = false);
      }
    }
  }

  Widget _ChangePasswordSection() {
    final hasError = (passwordError as String?)?.isNotEmpty == true;
    
    return _ProfileSection(
      title: 'Change Password',
      children: [
        _PasswordField(
          label: 'Current Password',
          controller: currentPasswordController,
          obscure: !showCurrentPassword,
          showPassword: showCurrentPassword,
          onToggle: () => setState(() => showCurrentPassword = !showCurrentPassword),
        ),
        _PasswordField(
          label: 'New Password',
          controller: newPasswordController,
          obscure: !showNewPassword,
          showPassword: showNewPassword,
          onToggle: () => setState(() => showNewPassword = !showNewPassword),
          onChanged: (value) {
            setState(() {}); // Trigger rebuild to update strength indicator
          },
        ),
        if (newPasswordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _getStrengthColor(_calculatePasswordStrength(newPasswordController.text)),
                  ),
                  width: MediaQuery.of(context).size.width * (_calculatePasswordStrength(newPasswordController.text) / 5),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStrengthLabel(_calculatePasswordStrength(newPasswordController.text)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        _PasswordField(
          label: 'Confirm New Password',
          controller: confirmPasswordController,
          obscure: !showConfirmPassword,
          showPassword: showConfirmPassword,
          onToggle: () => setState(() => showConfirmPassword = !showConfirmPassword),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              (passwordError as String?) ?? '',
              style: const TextStyle(color: Color(0xFFF44336), fontSize: 12),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: changingPassword ? null : _changePassword,
            style: FilledButton.styleFrom(
              backgroundColor: forest,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: changingPassword
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Update Password'),
          ),
        ),
      ],
    );
  }

  Widget _SecuritySection() {
    return _ProfileSection(
      title: 'Security',
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Enable two-factor authentication',
              style: TextStyle(fontSize: 14, color: ink),
            ),
            Switch(
              value: twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  obscureTwoFAPassword = true;
                  _pendingTwoFAValue = value;
                  twoFAPasswordError = '';
                  twoFAPasswordController.clear();
                });
              },
              activeColor: forest,
            ),
          ],
        ),
        if (_pendingTwoFAValue != null) ...[
          const SizedBox(height: 16),
          _PasswordField(
            label: 'Current password (required to enable 2FA)',
            controller: twoFAPasswordController,
            obscure: obscureTwoFAPassword,
            showPassword: !obscureTwoFAPassword,
            onToggle: () => setState(() => obscureTwoFAPassword = !obscureTwoFAPassword),
            onChanged: (value) => setState(() {}),
          ),
          if (twoFAPasswordError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                twoFAPasswordError,
                style: const TextStyle(color: Color(0xFFF44336), fontSize: 12),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _pendingTwoFAValue = null;
                    twoFAPasswordController.clear();
                    twoFAPasswordError = '';
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: forest,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: twoFAPasswordController.text.isNotEmpty && !toggling2FA
                      ? () => _toggleTwoFactor(_pendingTwoFAValue ?? false)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: forest,
                    foregroundColor: Colors.white,
                  ),
                  child: toggling2FA
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Change your password below to keep your account secure.',
          style: TextStyle(fontSize: 12, color: muted),
        ),
        const SizedBox(height: 16),
        _ChangePasswordSection(),
      ],
    );
  }

  Widget _PasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required bool showPassword,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: forest, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(showPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() => passwordError = 'Please enter your current password');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => passwordError = 'New password must be at least 8 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => passwordError = 'New passwords do not match');
      return;
    }

    setState(() {
      changingPassword = true;
      passwordError = '';
    });

    try {
      final token = AccountStore.instance.token;
      if (token == null) {
        throw Exception('You must be logged in');
      }

      // Verify current password
      await AuthService.verifyPassword(
        currentPassword: currentPassword,
        token: token,
      );

      // Send OTP and show verification dialog
      final email = AccountStore.instance.email;
      if (email == null) {
        throw Exception('Email not found');
      }

      final error = await AccountStore.instance.sendOtp(email, 'Password Change');
      if (error != null) {
        throw Exception(error);
      }

      // Show OTP dialog
      if (mounted) {
        _showOtpDialog(
          email: email,
          purpose: 'Password Change',
          onVerified: (otp) async {
            try {
              // Change password
              await AuthService.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
                token: token,
              );

              if (mounted) {
                showAppMessage(context, 'Password updated successfully. Please sign in again.');

                // Clear password fields
                currentPasswordController.clear();
                newPasswordController.clear();
                confirmPasswordController.clear();

                // Sign out and navigate to home
                await AccountStore.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/hotel');
                }
              }
            } catch (e) {
              if (mounted) {
                setState(() => passwordError = e.toString().replaceAll('Exception: ', ''));
                setState(() => changingPassword = false);
              }
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => passwordError = e.toString().replaceAll('Exception: ', ''));
        setState(() => changingPassword = false);
      }
    }
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^a-zA-Z0-9]'))) strength++;
    return strength;
  }

  String _getStrengthLabel(int strength) {
    switch (strength) {
      case 0: return '';
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      case 5: return 'Very Strong';
      default: return '';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0: return const Color(0xFFE0E0E0);
      case 1: return const Color(0xFFFF4D4D);
      case 2: return const Color(0xFFFF7A45);
      case 3: return const Color(0xFFFFC53D);
      case 4: return const Color(0xFF73D13D);
      case 5: return const Color(0xFF52C41A);
      default: return const Color(0xFFE0E0E0);
    }
  }
}
