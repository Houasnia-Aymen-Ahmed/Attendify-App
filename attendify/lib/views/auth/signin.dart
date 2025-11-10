import 'dart:ui';
import 'package:attendify/views/auth/signin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../../shared/constants.dart';

class SignIn extends ConsumerWidget {
  final Function toggleView;
  const SignIn({
    super.key,
    required this.toggleView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInControllerProvider);
    final signInController = ref.read(signInControllerProvider.notifier);

    ref.listen<SignInState>(signInControllerProvider, (previous, next) {
      if (next == SignInState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signInController.error ?? "An unknown error occurred."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Container(
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue[700]!,
                      Colors.blue[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    width: 2,
                    color: Colors.transparent,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 0.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        "Sign in",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      if (signInState == SignInState.loading)
                        const CircularProgressIndicator()
                      else
                        Transform.scale(
                          scale: 1.25,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 50),
                            child: SignInButton(
                              Buttons.google,
                              padding: const EdgeInsets.all(5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              text: "Sign in with HNS-RE2SD",
                              onPressed: () => signInController.signIn(),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "You don't have an account?",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                            onPressed: () => toggleView(),
                            child: Text(
                              "Create one",
                              style: txt().copyWith(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
