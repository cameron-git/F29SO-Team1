import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ivy/auth.dart';
import 'package:ivy/main.dart';
import 'package:provider/provider.dart';

// The login page, all the fields are validated with regex.
// Layout is responsive to different screen shapes and sizes
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool reg = false;
  bool peekPw = false;
  bool submitError = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();
  final GlobalKey<FormFieldState> _emailKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _passwordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _repasswordKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  submit() async {
    if (!_formKey.currentState!.validate()) return;
    User? user;
    if (reg) {
      submitError = !await context.read<AuthService>().signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      if (submitError) {
        setState(() {});
        return;
      }
      user = context.read<AuthService>().currentUser;
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set(
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'photoURL': null,
          'ownedPosts': ['']
        },
      );
      await user?.updateDisplayName(nameController.text.trim());
      await firebaseAnalytics.logSignUp(signUpMethod: 'signUpMethod');
    } else {
      submitError = !await context.read<AuthService>().signIn(
            email: emailController.text,
            password: passwordController.text,
          );
      if (submitError) {
        setState(() {});
        return;
      }
      user = context.read<AuthService>().currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get()
          .then((value) async {
        if (!value.exists) {
          await user?.delete();
          await context.read<AuthService>().signOut();
        }
      });
    }
  }

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
                SizedBox(
                  width: 500,
                  child: Row(
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
                ),
                const SizedBox(
                  height: 8,
                ),
                SizedBox(
                  width: 500,
                  child: TextFormField(
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
                    decoration: InputDecoration(
                      labelText: 'Email',
                      counterText: '',
                      errorText: (submitError && reg)
                          ? 'The email address is already in use by another account'
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: reg ? 8 : 0,
                ),
                reg
                    ? SizedBox(
                        width: 500,
                        child: TextFormField(
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
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: reg ? 16 : 8,
                ),
                SizedBox(
                  width: 500,
                  child: TextFormField(
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
                      } else if (!RegExp(r"^(?=.*[@$!%*?&£])")
                          .hasMatch(value)) {
                        return 'Password must be include a special character';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                    onChanged: (_) {
                      _passwordKey.currentState!.validate();
                    },
                    onFieldSubmitted: (_) {
                      !reg ? submit() : null;
                    },
                    controller: passwordController,
                    maxLength: 127,
                    obscureText: !peekPw,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      counterText: '',
                      errorText: (submitError && !reg)
                          ? 'Wrong Email or Password'
                          : null,
                      suffixIcon: reg
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
                  ),
                ),
                SizedBox(
                  height: reg ? 8 : 0,
                ),
                reg
                    ? SizedBox(
                        width: 500,
                        child: TextFormField(
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
                          onFieldSubmitted: (_) {
                            submit();
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
                        ),
                      )
                    : Container(),
                if (!reg)
                  TextButton(
                      onPressed: () async {
                        await context
                            .read<AuthService>()
                            .sendPasswordResetEmail(
                                email: emailController.text);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    const Text('Password Reset Email Sent To:'),
                                content: Text(emailController.text),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Ok'),
                                  ),
                                ],
                              );
                            });
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )),
                SizedBox(
                  height: reg ? 16 : 8,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () async {
                    submit();
                  },
                  child: SizedBox(
                    width: 150,
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
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text(
                              'By using Ivy you agree to the Terms and Conditions and that your data will be processed in accordance with GDPR Legislation\n\nUsers are not permitted to post any sexually explicit, abusive, or harmful content. Users are also not permitted to use any communication features such as the in-post text chat or the voice channel to spread sexually explicit, abusive or harmful content. Failure to comply with these guidelines will result in the user account being terminated and the removal of any offensive posts. Ivys user guidelines are in place to ensure Ivy remains a safe and welcoming space for users to learn, create and collaborate.'),
                        );
                      },
                    );
                  },
                  child: const Text(
                    'Terms and Conditions Apply',
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                  ),
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
              0.8) {
            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    header,
                    login(true),
                  ],
                ),
              ),
            );
          } else {
            return SafeArea(
              child: SizedBox.expand(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: SizedBox(),
                    ),
                    SizedBox.fromSize(
                      size: MediaQuery.of(context).size / 3,
                      child: sider,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: login(false),
                      ),
                      flex: 3,
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