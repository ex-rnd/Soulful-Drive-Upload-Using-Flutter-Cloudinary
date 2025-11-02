

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

  //
  //String? imagePath;



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Scaffold(
          // AppBar
          backgroundColor: Color(0xFFF3E8FF),
          //backgroundColor: Colors.black,// (0xFF6F00FF),
          appBar: AppBar(
            //backgroundColor: Color(0xFF6F00FF), // 0xFF6F00FF
            foregroundColor: Colors.white,
            centerTitle: true,
        
            title: ClipOval(
              child: Image.asset('assets/images/soulful_logo.png',
                //color: Colors.white,
                width: 50,
                height: 50,
        
                //fit: BoxFit.cover,
              ),
            ),
        
            actions: [],
          ),
        
        
          //
        
          // Body
          body:
          // Part 1
          Padding(
              padding: const EdgeInsets.all(24.0),
              child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            //mainAxisSize: MainAxisSize.min,
        
                              children: <Widget>[
                          //
                        const SizedBox(height: 10.0),
                                // Insert soulful logo
                                InkWell(
                                  // InkWell gives you a ripple effect over Material
                                  borderRadius: BorderRadius.circular(300),
                                  child: ClipOval(
                                    child:
                                        Image.asset('assets/images/soulful_logo.png',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
        
                                const SizedBox(height: 30.0),
                        //
                        // Old body
                                Expanded(
                                  // color: Color(0xFFF3E8FF), // 0xFFF3E8FF
                                  child: Form(
                                    key: formKey,
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * .9,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: const Text(
                                                    "Sign In",
                                                    style: TextStyle(
                                                      fontStyle: FontStyle.italic,
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
        
                                                const SizedBox(height: 10.0),
        
                                                Center(
                                                  child: const Text(
                                                    "And lets light a spot !",
                                                    style: TextStyle(
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                    ),
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
        
                                                SizedBox(height: 20,),
        
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
        
                                                SizedBox(height: 30,),
        
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
                                                                    style: TextStyle(
                                                                        color: Colors.white
                                                                    ),
                                                                  ),
                                                                    backgroundColor: Colors.green,
                                                                  )
                                                              );
        
                                                              Navigator.restorablePushNamedAndRemoveUntil(
                                                                  context,
                                                                  "/soulful",
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
                                                          color: Color(0xFF6F00FF),
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
                                ),
        
        
                        // Old body
        
        
        
        
                        ],
        
        
        
                          )
                      )
                  )
              )
          ),
        
        
        
        
        
        
        
          //
        
        
        
          // Part 2
        
        ),
      ),
    );
  }
}
