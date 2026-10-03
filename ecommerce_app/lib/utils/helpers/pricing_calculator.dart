class TPricingCalculator {
  /// -- Calculate price based on tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }

  /// -- Calculate shipping cost
  static String calculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// -- Calculate tax
  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  /// -- Tax rate per location
  static double getTaxRateForLocation(String location) {
    return switch (location.trim().toLowerCase()) {
      'lagos' => 0.075,
      'abuja' => 0.07,
      'kano' => 0.05,
      _ => 0.0,
    };
  }

  /// -- Shipping cost per location
  static double getShippingCost(String location) {
    return switch (location.trim().toLowerCase()) {
      'lagos' => 1500.0,
      'abuja' => 2500.0,
      'kano' => 3000.0,
      _ => 3500.0,
    };
  }
}
