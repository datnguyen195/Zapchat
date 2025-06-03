import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Header section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chat_bubble_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chào mừng đến với ZapChat',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để kết nối với bạn bè',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Login form
                const LoginForm(),
                const SizedBox(height: 32),
                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Chưa có tài khoản?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to register page
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.labelMedium,
                        ),
                        child: const Text('Đăng ký ngay'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Style riêng cho LoginPage
class _LoginPageStyles {
  static const double logoSize = 80.0;
  static const double logoBorderRadius = 20.0;
  static const EdgeInsets pageePadding = EdgeInsets.all(24.0);
  static const double headerSpacing = 60.0;
  static const double formSpacing = 48.0;
  static const double footerSpacing = 32.0;

  static BoxDecoration get logoDecoration => BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(logoBorderRadius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
