import 'package:ecommerce_app/features/authentication/controllers/onboarding_controller.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/widgets/onboarding_navigation.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:ecommerce_app/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:ecommerce_app/utils/constants/image_strings.dart';
import 'package:ecommerce_app/utils/constants/text_strings.dart';
import 'package:get/get.dart';
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
