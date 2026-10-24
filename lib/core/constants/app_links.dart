class AppLinks {
  const AppLinks._();

  static final repository = Uri.https('github.com', '/sanskarIN/PuzzleForge');
  static final creator = Uri.https('github.com', '/sanskarIN');
  static final website = Uri.https('sanskarin.github.io', '');
  static final buyMeACoffee = Uri.https('buymeacoffee.com', '/SanskarCodes');
  static final razorpay = Uri.https('razorpay.me', '/@SanskarCodes');
  static final paypal = Uri.https('paypal.me', '/SanskarCodes');
  static final mainEmail = Uri(
    scheme: 'mailto',
    path: 'sanskarcodes@gmail.com',
  );
  static final businessEmail = Uri(
    scheme: 'mailto',
    path: 'sanskar.businesswork@gmail.com',
  );

  static final destinations = Set<Uri>.unmodifiable(<Uri>{
    repository,
    creator,
    website,
    buyMeACoffee,
    razorpay,
    paypal,
    mainEmail,
    businessEmail,
  });
}
