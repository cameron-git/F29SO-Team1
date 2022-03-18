import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ivy/auth.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool reg = false;
  bool peekPw = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  final GlobalKey<FormFieldState> _emailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _repasswordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Widget header = LayoutBuilder(
      builder: (context, constraits) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: constraits.constrainWidth(200),
            height: constraits.constrainHeight(200),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset('assets/ivy-logo-3.png'),
            ),
          ),
        );
      },
    );

    Widget sider = Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            'assets/ivy-logo-3.png',
          ),
        ),
      ),
    );

    Widget login(bool vert) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reg ? 'Register' : 'Sign In',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Row(
                  children: [
                    Text(
                      reg
                          ? 'Already have an account?'
                          : "Don't have an account?",
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        reg = !reg;
                      }),
                      child: Text(
                        reg ? 'Sign In' : 'Register',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  key: _emailKey,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your email address';
                    } else if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                        .hasMatch(value)) {
                      return 'Invalid email address';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    _emailKey.currentState!.validate();
                  },
                  controller: emailController,
                  maxLength: 127,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    counterText: '',
                  ),
                ),
                SizedBox(
                  height: reg ? 8 : 0,
                ),
                reg
                    ? TextFormField(
                        key: _nameKey,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter a Username';
                          } else if (!RegExp(r'^[ \w\d]+$').hasMatch(value)) {
                            return 'Username must only consist of letters, numbers, spaces and underscores';
                          } else if (value.length < 3) {
                            return 'Username must be at least 3 characters long';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          _nameKey.currentState!.validate();
                        },
                        controller: nameController,
                        maxLength: 127,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          counterText: '',
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: reg ? 16 : 8,
                ),
                TextFormField(
                  key: _passwordKey,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return reg ? 'Enter a password' : 'Enter your password';
                    } else if (!RegExp(r"^(?=.*[a-z])").hasMatch(value)) {
                      return 'Password must be include a lowercase letter';
                    } else if (!RegExp(r"^(?=.*[A-Z])").hasMatch(value)) {
                      return 'Password must be include an upercase letter';
                    } else if (!RegExp(r"^(?=.*\d)").hasMatch(value)) {
                      return 'Password must be include a number';
                    } else if (!RegExp(r"^(?=.*[@$!%*?&])").hasMatch(value)) {
                      return 'Password must be include a special character';
                    } else if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    _passwordKey.currentState!.validate();
                  },
                  controller: passwordController,
                  maxLength: 127,
                  obscureText: !peekPw,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    counterText: '',
                    suffixIcon: reg
                        ? null
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                peekPw = !peekPw;
                              });
                            },
                            icon: Icon(
                              peekPw ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: reg ? 8 : 0,
                ),
                reg
                    ? TextFormField(
                        key: _repasswordKey,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          _repasswordKey.currentState!.validate();
                        },
                        controller: repasswordController,
                        maxLength: 127,
                        obscureText: !peekPw,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          counterText: '',
                          suffixIcon: !reg
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      peekPw = !peekPw;
                                    });
                                  },
                                  icon: Icon(
                                    peekPw
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                        ),
                      )
                    : Container(),
                const SizedBox(
                  height: 16,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (reg) {
                      await context.read<AuthService>().signUp(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                      final user = context.read<AuthService>().currentUser;
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .set(
                        {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'photoURL': null,
                          'admin': false,
                        },
                      );
                      await user?.updateDisplayName(nameController.text.trim());
                    } else {
                      await context.read<AuthService>().signIn(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                    }
                  },
                  child: SizedBox(
                    width: 500,
                    child: Text(
                      reg ? 'Register' : 'Sign In',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Terms and Conditions Apply',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Builder(
        builder: (context) {
          if (MediaQuery.of(context).size.width /
                  MediaQuery.of(context).size.height <
              0.7) {
            return SingleChildScrollView(
              child: SizedBox.fromSize(
                size: MediaQuery.of(context).size,
                child: SafeArea(
                  child: Column(
                    children: [
                      header,
                      Expanded(child: login(true)),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: SizedBox.fromSize(
                size: MediaQuery.of(context).size,
                child: Row(
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    Expanded(
                      child: sider,
                      flex: 2,
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    login(false),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}




// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SignInScreen(
//         actions: [
//           AuthStateChangeAction<SignedIn>(
//             (context, _) {
//               final user = FirebaseAuth.instance.currentUser;
//               FirebaseFirestore.instance.collection('users').doc(user?.uid).set(
//                 {
//                   'name': user?.displayName,
//                   'email': user?.email,
//                   'photoURL': user?.photoURL,
//                   'admin': false,
//                 },
//               );
//             },
//           ),
//         ],
//         providerConfigs: const [
//           EmailProviderConfiguration(),
//         ],
//         headerMaxExtent: 300,
//         headerBuilder: (context, constraints, _) => Padding(
//           padding: const EdgeInsets.all(20),
//           child: SizedBox(
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: Image.asset('assets/ivy-logo-3.png'),
//             ),
//           ),
//         ),
//         sideBuilder: (context, constraints) => Padding(
//           padding: const EdgeInsets.all(20),
//           child: SizedBox(
//             width: constraints.constrainWidth(540),
//             height: constraints.constrainHeight(540),
//             child: AspectRatio(
//               aspectRatio: 1,
//               child: Image.asset('assets/ivy-logo-3.png'),
//             ),
//           ),
//         ),
//         footerBuilder: (context, action) => const Padding(
//           padding: EdgeInsets.all(12),
//           child: Text('ToS applies!!!'),
//         ),
//       ),
//     );
//   }
// }