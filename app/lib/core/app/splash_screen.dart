import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String? message;
  final bool showProgress;

  const SplashScreen({super.key, this.message, this.showProgress = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              const Text(
                'ZapChat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Lightning Fast Messaging',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 48),

              // Progress Indicator
              if (showProgress) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Status Message
              if (message != null)
                Text(
                  message!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
