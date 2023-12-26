import 'package:flutter/material.dart';

var shadowDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(10)),
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.grey.withOpacity(0.5),
      spreadRadius: 2,
      blurRadius: 3,
      offset: const Offset(0, 3),
    ),
  ],
);

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(fontSize: 25),),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create a new MyNet account.',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'First name',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Last name',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Address',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: shadowDecoration,
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Repeat password',
                      filled: true,
                      fillColor: Colors.white,
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Perform registration logic
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                child: const Text('Create new account'),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the login page
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black, // Set the default text color
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Login here.',
                        style: TextStyle(
                          decoration: TextDecoration.underline, // Add underline
                          color: Colors.blue, // Set text color to blue
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
