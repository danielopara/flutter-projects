import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = CHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(CSizes.defaultSpace),
          child: Column(
            children: [
              //title
              Text(
                CTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: CSizes.spaceBetweenSections),

              //form
              Form(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            expands: false,
                            decoration: InputDecoration(
                              labelText: CTexts.firstName,

                              prefixIcon: Icon(Iconsax.user),
                            ),
                          ),
                        ),
                        const SizedBox(width: CSizes.spaceBetweenInputFields),
                        Expanded(
                          child: TextFormField(
                            expands: false,
                            decoration: InputDecoration(
                              labelText: CTexts.lastName,

                              prefixIcon: Icon(Iconsax.user),
                            ),
                          ),
                        ),
                        // TextFormField(),
                      ],
                    ),

                    const SizedBox(height: CSizes.spaceBetweenItems),

                    //username
                    TextFormField(
                      expands: false,
                      decoration: InputDecoration(
                        labelText: CTexts.username,

                        prefixIcon: Icon(Iconsax.user_edit),
                      ),
                    ),

                    const SizedBox(height: CSizes.spaceBetweenInputFields),

                    //email
                    TextFormField(
                      expands: false,
                      decoration: InputDecoration(
                        labelText: CTexts.email,

                        prefixIcon: Icon(Iconsax.direct),
                      ),
                    ),

                    //phone number
                    const SizedBox(height: CSizes.spaceBetweenInputFields),
                    TextFormField(
                      expands: false,
                      decoration: InputDecoration(
                        labelText: CTexts.phoneNo,

                        prefixIcon: Icon(Iconsax.call),
                      ),
                    ),

                    //password
                    const SizedBox(height: CSizes.spaceBetweenInputFields),
                    TextFormField(
                      expands: false,
                      decoration: InputDecoration(
                        labelText: CTexts.password,

                        prefixIcon: Icon(Iconsax.password_check),
                        suffixIcon: Icon(Iconsax.eye_slash),
                      ),
                    ),

                    //confirm password
                    // const SizedBox(height: CSizes.spaceBetweenInputFields),
                    // TextFormField(
                    //   expands: false,
                    //   decoration: InputDecoration(
                    //     labelText: CTexts.password,

                    //     prefixIcon: Icon(Iconsax.password_check),
                    //     suffixIcon: Icon(Iconsax.eye_slash),
                    //   ),
                    // ),
                    const SizedBox(height: CSizes.spaceBetweenSections),

                    //check box
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(value: true, onChanged: (value) {}),
                        ),
                        const SizedBox(width: CSizes.spaceBetweenItems),

                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${CTexts.iAgreeTo} ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              TextSpan(
                                text: '${CTexts.privacyPolicy} ',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .apply(
                                      color: dark
                                          ? CColors.white
                                          : CColors.primaryColor,
                                    ),
                              ),
                              TextSpan(
                                text: 'and ',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              TextSpan(
                                text: '${CTexts.termsOfUse} ',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .apply(
                                      color: dark
                                          ? CColors.white
                                          : CColors.primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CSizes.spaceBetweenSections),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        label: Text(CTexts.createAccount),
                      ),
                    ),
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
