import 'package:flutter/material.dart';

import '../services/service_firebase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 120,
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Get started with your account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10,),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          validator: (value) =>
                          value!.isEmpty ? "Email can not be empty" : null,

                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      ),

                      SizedBox(height: 10,),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          validator: (value) =>
                          value!.length < 8 ? "Password must be >= 8 chars" : null,

                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                        )
                      ),

                      SizedBox(height: 10,),

                      SizedBox(
                        width: MediaQuery.of(context).size.width * .9,
                        child: ElevatedButton(
                            onPressed: () {

                              if (formKey.currentState!.validate()) {
                                // Call the sign-up function from your service
                                AuthService().loginWithEmail(
                                    _emailController.text,
                                    _passwordController.text)
                                    .then((value) {
                                  if (value == "Login successful") {
                                    // Navigate to home page or show success message
                                    // Navigator.pushReplacementNamed(context, "/home");
                                    ScaffoldMessenger.of(context).
                                    showSnackBar(
                                        const SnackBar(content: Text(
                                          "Login successful",
                                        ))
                                    );

                                    Navigator.restorablePushNamedAndRemoveUntil(
                                        context,
                                        "/home",
                                            (route) => false
                                    );
                                  } else {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          value,
                                          style: const TextStyle(
                                              color: Colors.white
                                          ),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                      ),
                                    );
                                  }
                                });

                              }

                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                        ),
                      ),

                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/signup");
                              } ,
                              child: const Text("Sign Up")
                          )
                        ],

                      )


                    ],
                ),
              ),




            ],
          ),
        ),
      ),
    );
  }
}
