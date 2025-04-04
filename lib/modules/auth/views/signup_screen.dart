import 'package:crud_authentication_task/modules/auth/views/signin_screen.dart';
import 'package:crud_authentication_task/modules/home/views/home_screen.dart';
import 'package:crud_authentication_task/widgets/common_signin_button.dart';
import 'package:crud_authentication_task/widgets/common_snackbar.dart';
import 'package:crud_authentication_task/widgets/common_textfiled.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } catch (e) {
        showSnackBar(message: e.toString());
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    try {
      await authProvider.signInWithGoogle();
      if (authProvider.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
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
        padding: EdgeInsets.all(20),
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
              CommonTextFiled(controller: _nameController, labelText: "Name"),
              SizedBox(height: 10),
              CommonTextFiled(controller: _emailController, labelText: "Email"),
              SizedBox(height: 10),
              CommonTextFiled(
                controller: _passwordController,
                isVisible: true,
                labelText: "Password",
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () => _handleSignup(authProvider),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed:
                        () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SigninScreen()),
                        ),
                    child: Text("Sign In"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("or continue with", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              authProvider.isLoading
                  ? CircularProgressIndicator(color: Colors.lightBlue)
                  : GoogleSignInButton(
                    onTap: () => _handleGoogleSignIn(authProvider),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
