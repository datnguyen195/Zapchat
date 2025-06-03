import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate login process
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    // Navigate to home page
    if (mounted) {
      context.pushReplacement('/home');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Nhập email của bạn',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: _LoginFormStyles.fieldSpacing),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _isObscured,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _login(),
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              hintText: 'Nhập mật khẩu của bạn',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: _LoginFormStyles.smallSpacing),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password page
              },
              style: _LoginFormStyles.forgotPasswordButtonStyle,
              child: Text(
                'Quên mật khẩu?',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: _LoginFormStyles.buttonSpacing),

          // Login button
          SizedBox(
            height: _LoginFormStyles.buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text('Đăng nhập', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: _LoginFormStyles.dividerSpacing),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'hoặc',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: _LoginFormStyles.dividerSpacing),

          // Google login button
          SizedBox(
            height: _LoginFormStyles.buttonHeight,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement Google login
              },
              style: _LoginFormStyles.googleButtonStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.g_mobiledata,
                    size: 24,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng nhập với Google',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Style riêng cho LoginForm
class _LoginFormStyles {
  static const double fieldSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double buttonSpacing = 24.0;
  static const double dividerSpacing = 24.0;
  static const double buttonHeight = 52.0;

  static ButtonStyle get forgotPasswordButtonStyle => TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: EdgeInsets.zero,
  );

  static ButtonStyle get googleButtonStyle => OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
