class L10n {
  final String lang;

  const L10n(this.lang);

  bool get isAr => lang == 'ar';

  // Auth
  String get welcomeCapt => isAr ? 'مرحباً كابتن' : 'Welcome Captain,';

  String get signInSubtitle => isAr
      ? 'تسجيل الدخول لحساب رحلاتك'
      : 'Sign in to start your journey and calculate your earnings.';

  String get email => isAr ? 'البريد الإلكتروني' : 'Email';

  String get password => isAr ? 'كلمة المرور' : 'Password';

  String get signIn => isAr ? 'تسجيل الدخول' : 'Sign In';

  String get forgotPassword => isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?';

  String get signUp => isAr ? 'إنشاء حساب' : 'Sign Up';

  String get orSignUpWith => isAr ? 'أو التسجيل بـ' : 'Or Sign up with';

  String get continueWithGoogle =>
      isAr ? 'الاستمرار بجوجل' : 'Continue with Google';

  String get useAccountBelow => isAr
      ? 'استخدم الحساب أدناه لتسجيل الدخول.'
      : 'Use the account below to sign in.';

  String get createAccount => isAr ? 'إنشاء حساب جديد' : 'Create an account';

  String get createAccountSubtitle => isAr
      ? 'أدخل بياناتك للبدء في حساب تكلفة مشاوريك.'
      : "Let's get started by filling out the form below.";

  String get fullName => isAr ? 'الاسم الكامل' : 'Full Name';

  String get phoneNumber => isAr ? 'رقم الجوال' : 'Phone Number';

  String get confirmPassword => isAr ? 'تأكيد كلمة المرور' : 'Confirm Password';

  String get createAccountBtn => isAr ? 'إنشاء الحساب' : 'Create Account';

  String get forgotPasswordTitle =>
      isAr ? 'نسيت كلمة المرور' : 'Forgot Password';

  String get forgotPasswordSubtitle => isAr
      ? 'سنرسل لك بريداً إلكترونياً لإعادة تعيين كلمة المرور.'
      : 'We will send you an email with a link to reset your password, please enter the email associated with your account below.';

  String get sendLink => isAr ? 'إرسال الرابط' : 'Send Link';

  String get yourEmailAddress =>
      isAr ? 'عنوان بريدك الإلكتروني' : 'Your email address...';

  String get enterYourEmail =>
      isAr ? 'أدخل بريدك الإلكتروني...' : 'Enter your email...';

  String get back => isAr ? 'رجوع' : 'Back';

  // Dashboard
  String get goodMorning => isAr ? 'صباح الخير' : 'Good Morning,';

  String get todayEarnings => isAr ? 'أرباح اليوم' : "Today's Earnings";

  String get totalTrips => isAr ? 'إجمالي الرحلات' : 'Total Trips';

  String get kilometers => isAr ? 'كيلومترات' : 'Kilometers';

  String get rating => isAr ? 'التقييم' : 'Rating';

  String get totalEarnings => isAr ? 'الإجمالي' : 'Total';

  String get seeAll => isAr ? 'عرض الكل' : 'See All';

  String get recentTrips => isAr ? 'الرحلات الأخيرة' : 'Recent Trips';

  String get startNewTrip =>
      isAr ? 'حساب رحلة جديدة +' : '+ Start New Trip Calculation';

  String get trips => isAr ? 'رحلة' : 'Trips';

  String get km => isAr ? 'كم' : 'km';

  String get sar => isAr ? 'ر.س' : 'SAR';

  String get aed => isAr ? 'د.إ' : 'AED';

  // Bottom nav
  String get home => isAr ? 'الرئيسية' : 'Home';

  String get calculator => isAr ? 'الحاسبة' : 'Calculator';

  String get history => isAr ? 'السجل' : 'History';

  String get profile => isAr ? 'الملف' : 'Profile';

  // Trip Calculator
  String get pickupLocation => isAr ? 'موقع الانطلاق' : 'Pickup Location';

  String get currentLocation => isAr ? 'موقعك الحالي' : 'Current Location';

  String get destination => isAr ? 'وجهة الوصول' : 'Destination';

  String get destinationHint =>
      isAr ? 'دبي مول، وسط المدينة' : 'Dubai Mall, Downtown';

  String get pricePerKm => isAr ? 'سعر الكيلومتر' : 'Price / km';

  String get pricePerMin => isAr ? 'سعر الدقيقة' : 'Price / min';

  String get baseFare => isAr ? 'فتح الباب' : 'Open Door';

  String get waitingPerMin => isAr ? 'انتظار/دقيقة' : 'Waiting / min';

  String get tip => isAr ? 'إكرامية' : 'Tip';

  String get distance => isAr ? 'المسافة' : 'Distance';

  String get platform => isAr ? 'التطبيق المستخدم' : 'Platform';

  String get calculate => isAr ? 'حساب رحلة جديدة' : 'Calculate Trip';

  String get estimatedEarnings => isAr ? 'الأرباح المقدرة' : 'Est. Earnings';

  String get workingDays => isAr ? 'الأيام المدخلة' : 'Working Days';

  // Trip History
  String get tripHistory => isAr ? 'سجل الرحلات' : 'Trip History';

  String get searchTrips => isAr ? 'ابحث عن وجهة...' : 'Search trips...';

  String get all => isAr ? 'الكل' : 'All';

  String get thisDay => isAr ? 'هذا اليوم' : 'this Day';

  String get thisMonth => isAr ? 'هذا الشهر' : 'This Month';

  String get thisWeek => isAr ? 'هذا الأسبوع' : 'This Week';

  String get totalEarningsMonth =>
      isAr ? 'إجمالي الأرباح (الشهر)' : 'Total Earnings (Month)';

  String get pickup => isAr ? 'نقطة البداية' : 'Pickup';

  String get destinationLabel => isAr ? 'الوجهة' : 'Destination';

  String get mins => isAr ? 'دقيقة' : 'mins';

  String get noTrips => isAr ? 'لا توجد رحلات' : 'No trips found';

  // Trip Details
  String get tripDetails => isAr ? 'تفاصيل الرحلة' : 'Trip Details';

  String get duration => isAr ? 'المدة' : 'Duration';

  String get waiting => isAr ? 'الانتظار' : 'Waiting';

  String get fare => isAr ? 'الأجرة' : 'Fare';

  // Profile
  String get captainProfile => isAr ? 'ملف الكابتن' : 'Captain Profile';

  String get totalTripsLabel => isAr ? 'إجمالي الرحلات' : 'Total Trips';

  String get ratingLabel => isAr ? 'التقييم' : 'Rating';

  String get yearsLabel => isAr ? 'سنوات' : 'Years';

  String get vehicleInfo => isAr ? 'معلومات السيارة' : 'Vehicle Information';

  String get accountSettings => isAr ? 'إعدادات الحساب' : 'Account Settings';

  String get personalInfo =>
      isAr ? 'المعلومات الشخصية' : 'Personal Information';

  String get personalInfoSub => isAr
      ? 'الاسم، البريد الإلكتروني، رقم الهاتف'
      : 'Name, email, phone number';

  String get payoutSettings => isAr ? 'إعدادات الدفع' : 'Payout Settings';

  String get payoutSettingsSub =>
      isAr ? 'حساب البنك وطرق الدفع' : 'Bank account & payment methods';

  String get active => isAr ? 'نشط' : 'Active';

  String get goldCaptain => isAr ? 'كابتن ذهبي' : 'Gold Captain';

  String get signOut => isAr ? 'تسجيل الخروج' : 'Sign Out';

  // Settings
  String get appSettings => isAr ? 'إعدادات التطبيق' : 'App Settings';

  String get appearance => isAr ? 'المظهر' : 'Appearance';

  String get darkMode => isAr ? 'الوضع الداكن' : 'Dark Mode';

  String get darkModeDesc =>
      isAr ? 'ضبط المظهر البصري للتطبيق' : "Adjust the app's visual theme";

  String get language => isAr ? 'اللغة' : 'Language';

  String get languageValue => isAr ? 'العربية' : 'English';

  String get tripCalculator => isAr ? 'حاسبة الرحلة' : 'Trip Calculator';

  String get distanceUnit => isAr ? 'وحدة المسافة' : 'Distance Unit';

  String get distanceUnitValue => isAr ? 'كيلومترات (كم)' : 'Kilometers (km)';

  String get currency => isAr ? 'العملة' : 'Currency';

  String get notifications => isAr ? 'الإشعارات' : 'Notifications';

  String get pushNotifications =>
      isAr ? 'الإشعارات الفورية' : 'Push Notifications';

  String get tripAlerts => isAr ? 'تنبيهات الرحلة' : 'Trip Alerts';

  String get tripAlertsDesc =>
      isAr ? 'مسار الطريق في الوقت الفعلي' : 'Real-time route';

  // Legal
  String get termsAndConditions =>
      isAr ? 'الشروط والأحكام' : 'Terms & Conditions';

  String get privacyPolicy => isAr ? 'سياسة الخصوصية' : 'Privacy Policy';

  String get agreePrefix =>
      isAr ? 'بمتابعتك فإنك توافق على ' : 'By continuing, you agree to our ';

  String get and => isAr ? ' و' : ' and ';

  // Days of week
  List<String> get weekDays => isAr
      ? [
          'الجمعة',
          'الخميس',
          'الأربعاء',
          'الثلاثاء',
          'الاثنين',
          'الأحد',
          'السبت'
        ]
      : ['Fri', 'Thu', 'Wed', 'Tue', 'Mon', 'Sun', 'Sat'];
}
