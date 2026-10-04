import 'package:ecommerce_app/common/styles/spacing_style.dart';
import 'package:ecommerce_app/common/widgets/login_signup/form_divider.dart';
import 'package:ecommerce_app/common/widgets/login_signup/social_buttons.dart';
import 'package:ecommerce_app/features/authentication/screens/login/widgets/login_form.dart';
import 'package:ecommerce_app/features/authentication/screens/login/widgets/login_header.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: CSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              const LoginHeader(),

              const SizedBox(height: CSizes.spaceBetweenItems),

              const LoginForm(),

              FormDivider(dividerText: CTexts.orSignInWith.capitalize!),

              const SizedBox(height: CSizes.spaceBetweenSections),

              //footer
              const SocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
