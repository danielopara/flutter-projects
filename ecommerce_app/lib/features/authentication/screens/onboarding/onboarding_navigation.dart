import 'package:ecommerce_app/features/authentication/controllers/onboarding_controller.dart';
import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:ecommerce_app/utils/device/device_utility.dart';
import 'package:ecommerce_app/utils/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingNavigation extends StatelessWidget {
  const OnboardingNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    final dark = CHelperFunctions.isDarkMode(context);
    return Positioned(
      bottom: CDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: CSizes.defaultSpace,

      child: SmoothPageIndicator(
        controller: controller.pageController,
        count: 3,
        onDotClicked: controller.dotNavigationClick,
        effect: ExpandingDotsEffect(
          activeDotColor: dark
              ? CColors.backgroundLight
              : CColors.backgroundDark,
          dotHeight: 6,
        ),
      ),
    );
  }
}
