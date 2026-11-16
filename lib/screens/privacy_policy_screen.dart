import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

/// Draft privacy policy. Have it reviewed before release.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = <(String, String)>[
    ('Who we are',
        'MyBidhaa ("we", "us") sells school books and supplies in Kenya through this app and mybidhaa.com.'),
    ('Information we collect',
        'Account details (name, email, phone number), delivery details, order history, and the photos or files you upload when you scan or upload a booklist. We also collect basic device and usage data to keep the app working.'),
    ('How we use it',
        'To process and deliver orders, take payments (including M-Pesa), match booklists to products, contact you about your order, provide support and improve the app.'),
    ('Booklist photos',
        'Photos are read on your device to find book titles. Files you choose to upload are sent to us only to prepare your quote.'),
    ('Sharing',
        'We share information only with payment providers, delivery partners and service providers who help us fulfil your order. We do not sell your personal data.'),
    ('Retention and security',
        'We keep information as long as needed for orders, legal and accounting purposes and protect it with reasonable technical measures.'),
    ('Your rights',
        'You may request access to, correction of or deletion of your personal data under the Kenya Data Protection Act, 2019, by contacting us.'),
    ('Contact',
        'WhatsApp: +254 797 100 500, or through mybidhaa.com.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final (title, body) in _sections) ...[
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 18),
          ],
          TextButton(
            onPressed: () => launchUrl(
                Uri.parse('https://mybidhaa.com/terms-conditions'),
                mode: LaunchMode.externalApplication),
            child: const Text('Terms & Conditions'),
          ),
        ],
      ),
    );
  }
}
