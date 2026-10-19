import 'package:ecommerce_app/utils/constants/sizes.dart' show CSizes;
import 'package:flutter/widgets.dart';

class CSpacingStyle {
  static const EdgeInsets paddingWithAppBarHeight = EdgeInsets.only(
    top: CSizes.appBarHeight,
    bottom: CSizes.defaultSpace,
    right: CSizes.defaultSpace,
    left: CSizes.defaultSpace,
  );
}
