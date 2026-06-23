import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/app_colors.dart';

/// A single block of legal text: an optional heading followed by paragraphs.
class LegalSection {
  final String? heading;
  final List<String> paragraphs;
  const LegalSection({this.heading, required this.paragraphs});
}

/// Generic, scrollable screen used for both Terms & Conditions and the
/// Privacy Policy. Pass a title and the localized sections to render.
class LegalScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;
  final String? lastUpdated;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastUpdated != null) ...[
              Text(
                lastUpdated!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.secondary,
                    ),
              ),
              const SizedBox(height: 16),
            ],
            for (final section in sections) ...[
              if (section.heading != null) ...[
                Text(
                  section.heading!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              for (final paragraph in section.paragraphs) ...[
                Text(
                  paragraph,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

/// Terms & Conditions screen, wired to the current app language.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<AppStateProvider>().isAr;
    return LegalScreen(
      title: isAr ? 'الشروط والأحكام' : 'Terms & Conditions',
      lastUpdated: isAr ? 'آخر تحديث: يونيو 2026' : 'Last updated: June 2026',
      sections: LegalContent.terms(isAr),
    );
  }
}

/// Privacy Policy screen, wired to the current app language.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<AppStateProvider>().isAr;
    return LegalScreen(
      title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
      lastUpdated: isAr ? 'آخر تحديث: يونيو 2026' : 'Last updated: June 2026',
      sections: LegalContent.privacy(isAr),
    );
  }
}

/// Localized legal copy. Keep the wording here so it is easy to review and
/// update without touching screen layout. IMPORTANT: have this text reviewed
/// by the business / legal owner before publishing to the stores.
class LegalContent {
  static List<LegalSection> terms(bool isAr) {
    if (isAr) {
      return const [
        LegalSection(paragraphs: [
          'باستخدامك تطبيق حاسبة المشاوير، فإنك توافق على الشروط والأحكام التالية. يرجى قراءتها بعناية قبل الاشتراك في الخدمة.',
        ]),
        LegalSection(heading: 'المنتجات والخدمات', paragraphs: [
          'حاسبة المشاوير – اشتراك أسبوعي.',
          'مدة الاشتراك: 7 أيام.',
          'السعر: 5 ريال سعودي.',
        ]),
        LegalSection(heading: 'الاشتراك والتجديد', paragraphs: [
          'يمنحك الاشتراك الأسبوعي حق استخدام ميزات الحاسبة طوال مدة الاشتراك.',
          'تتم إدارة عمليات الدفع والتجديد عبر مزود خدمة الدفع المعتمد ووفق سياسات متجر التطبيقات المعمول بها.',
        ]),
        LegalSection(heading: 'سياسة الاسترجاع', paragraphs: [
          'يجوز طلب استرجاع قيمة الاشتراك في الحالات التالية:',
          'وجود مشكلات فنية جوهرية منعت المستخدم من الاستفادة من الخدمة.',
          'أي حالة أخرى تراها المؤسسة مناسبة بعد المراجعة.',
        ]),
        LegalSection(heading: 'مدة معالجة الطلبات', paragraphs: [
          'في حال الموافقة على الاسترجاع، تتم معالجة الطلب خلال مدة معقولة وفق إجراءات مزود الدفع والأنظمة المعمول بها.',
        ]),
        LegalSection(heading: 'مسؤولية المستخدم', paragraphs: [
          'النتائج التي يقدمها التطبيق تقديرية وتهدف إلى مساعدة الكابتن في حساب أرباحه، ولا تُعد بديلاً عن الأرقام الرسمية الصادرة عن منصات التوصيل.',
          'يتحمل المستخدم مسؤولية صحة البيانات التي يدخلها في التطبيق.',
        ]),
        LegalSection(heading: 'التواصل', paragraphs: [
          'لأي استفسار يتعلق بالشروط والأحكام أو طلبات الاسترجاع، يرجى التواصل مع مؤسسة قوة الكباتن.',
        ]),
      ];
    }
    return const [
      LegalSection(paragraphs: [
        'By using the Trip Calculator app, you agree to the following terms and conditions. Please read them carefully before subscribing to the service.',
      ]),
      LegalSection(heading: 'Products & Services', paragraphs: [
        'Trip Calculator – Weekly subscription.',
        'Subscription period: 7 days.',
        'Price: 5 SAR.',
      ]),
      LegalSection(heading: 'Subscription & Renewal', paragraphs: [
        'The weekly subscription grants you access to the calculator features for the duration of the subscription.',
        'Payments and renewals are handled through the approved payment provider and in accordance with the applicable app store policies.',
      ]),
      LegalSection(heading: 'Refund Policy', paragraphs: [
        'A refund of the subscription fee may be requested in the following cases:',
        'Substantial technical issues that prevented the user from benefiting from the service.',
        'Any other case the company deems appropriate after review.',
      ]),
      LegalSection(heading: 'Processing Time', paragraphs: [
        'If a refund is approved, the request is processed within a reasonable period in accordance with the payment provider procedures and applicable regulations.',
      ]),
      LegalSection(heading: 'User Responsibility', paragraphs: [
        'The results provided by the app are estimates intended to help captains calculate their earnings, and are not a substitute for the official figures issued by delivery platforms.',
        'The user is responsible for the accuracy of the data they enter into the app.',
      ]),
      LegalSection(heading: 'Contact', paragraphs: [
        'For any inquiry regarding these terms or refund requests, please contact Captains Power.',
      ]),
    ];
  }

  static List<LegalSection> privacy(bool isAr) {
    if (isAr) {
      return const [
        LegalSection(paragraphs: [
          'تحترم مؤسسة قوة الكباتن خصوصيتك. توضح هذه السياسة أنواع البيانات التي نجمعها وكيفية استخدامها وحمايتها عند استخدامك تطبيق حاسبة المشاوير.',
        ]),
        LegalSection(heading: 'البيانات التي نجمعها', paragraphs: [
          'بيانات الحساب: الاسم والبريد الإلكتروني ورقم الجوال عند إنشاء الحساب.',
          'بيانات الاستخدام: تفاصيل الرحلات والمسافات والأرباح التي تدخلها في التطبيق.',
          'بيانات الموقع: تُستخدم لحساب المسافات وتقدير الأجرة فقط عند منحك الإذن.',
        ]),
        LegalSection(heading: 'كيفية استخدام البيانات', paragraphs: [
          'تقديم خدمة حساب الرحلات والأرباح وتحسين تجربة الاستخدام.',
          'إدارة الاشتراكات والمدفوعات والدعم الفني.',
          'لا نبيع بياناتك الشخصية لأي طرف ثالث.',
        ]),
        LegalSection(heading: 'تخزين البيانات وحمايتها', paragraphs: [
          'تُخزن بياناتك بشكل آمن عبر خدمات Firebase من Google، ونتخذ إجراءات معقولة لحمايتها من الوصول غير المصرح به.',
        ]),
        LegalSection(heading: 'حقوقك', paragraphs: [
          'يحق لك الوصول إلى بياناتك أو تعديلها أو طلب حذف حسابك في أي وقت عبر التواصل معنا.',
        ]),
        LegalSection(heading: 'التواصل', paragraphs: [
          'لأي استفسار يتعلق بالخصوصية، يرجى التواصل مع مؤسسة قوة الكباتن.',
        ]),
      ];
    }
    return const [
      LegalSection(paragraphs: [
        'Captains Power respects your privacy. This policy explains what data we collect, and how we use and protect it when you use the Trip Calculator app.',
      ]),
      LegalSection(heading: 'Data We Collect', paragraphs: [
        'Account data: name, email, and phone number when you create an account.',
        'Usage data: trip details, distances, and earnings you enter into the app.',
        'Location data: used only to calculate distances and estimate fares, and only when you grant permission.',
      ]),
      LegalSection(heading: 'How We Use Data', paragraphs: [
        'To provide the trip and earnings calculation service and improve your experience.',
        'To manage subscriptions, payments, and technical support.',
        'We do not sell your personal data to any third party.',
      ]),
      LegalSection(heading: 'Data Storage & Protection', paragraphs: [
        'Your data is stored securely using Google Firebase services, and we take reasonable measures to protect it from unauthorized access.',
      ]),
      LegalSection(heading: 'Your Rights', paragraphs: [
        'You may access or modify your data, or request deletion of your account at any time by contacting us.',
      ]),
      LegalSection(heading: 'Contact', paragraphs: [
        'For any privacy-related inquiry, please contact Captains Power.',
      ]),
    ];
  }
}
