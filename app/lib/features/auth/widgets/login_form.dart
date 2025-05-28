import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(decoration: InputDecoration(labelText: 'Email')),
        TextField(decoration: InputDecoration(labelText: 'Password')),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          child: Text('Login'),
        )
      ],
    );
  }
}
