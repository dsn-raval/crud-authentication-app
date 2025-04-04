import 'package:crud_authentication_task/modules/auth/providers/auth_provider.dart';
import 'package:crud_authentication_task/modules/auth/views/signup_screen.dart';
import 'package:crud_authentication_task/modules/home/views/home_screen.dart';
import 'package:crud_authentication_task/widgets/common_signin_button.dart';
import 'package:crud_authentication_task/widgets/common_snackbar.dart';
import 'package:crud_authentication_task/widgets/common_textfiled.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        showSnackBar(message: e.toString());
      }
    }
  }

  Future<void> _handleGoogleLogin(AuthProvider authProvider) async {
    try {
      await authProvider.signInWithGoogle();
      if (authProvider.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      showSnackBar(message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "What's your email address?",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CommonTextFiled(
                controller: _emailController,
                labelText: "Email ",
              ),
              SizedBox(height: 10),
              CommonTextFiled(
                controller: _passwordController,
                isVisible: true,
                labelText: "Password",
              ),
              SizedBox(height: 20),
              authProvider.isLoading
                  ? CircularProgressIndicator(color: Colors.lightBlue)
                  : Column(
                    children: [
                      InkWell(
                        onTap: () => _handleLogin(authProvider),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => SignupScreen()),
                            ),
                        child: Text("Create an account"),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "or continue with",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      GoogleSignInButton(
                        onTap: () => _handleGoogleLogin(authProvider),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
