import 'package:ecommerce_app/features/authentication/controllers/onboarding_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding_navigation.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding_page.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/onboarding_skip.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:ecommerce_app/utils/helpers/helpers.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnboardingPage(
                title: CTexts.onBoardingTitle1,
                image: CImages.onBoardingImage1,
                subtitle: CTexts.onBoardingSubTitle1,
              ),
              OnboardingPage(
                title: CTexts.onBoardingTitle2,
                image: CImages.onBoardingImage2,
                subtitle: CTexts.onBoardingSubTitle2,
              ),
              OnboardingPage(
                title: CTexts.onBoardingTitle3,
                image: CImages.onBoardingImage3,
                subtitle: CTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          const OnboardingSkip(),

          const OnboardingNavigation(),

          const OnboardingNextButton(),
        ],
      ),
    );
  }
}

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = CHelperFunctions.isDarkMode(context);
    return Positioned(
      right: CSizes.defaultSpace,
      bottom: CDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnboardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: dark ? CColors.primaryBackground : Colors.black,
        ),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}
