import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';

class _Service {
  const _Service(this.name, this.blurb, this.url, this.icon);
  final String name;
  final String blurb;
  final String url;
  final IconData icon;
}

const _services = <_Service>[
  _Service('Edtours', 'Educational trips and tours for schools',
      'https://edtours.mybidhaa.com/', Icons.travel_explore),
  _Service('KUZZA', 'Learning and school solutions',
      'https://kuzza.co.ke/', Icons.rocket_launch_outlined),
  _Service('Edusystems', 'School management systems',
      'https://edusystems.mybidhaa.com/', Icons.dashboard_customize_outlined),
  _Service('Edujenga', 'Education support and programmes',
      'https://edujenga.mybidhaa.com/', Icons.foundation_outlined),
  _Service('Careers', 'Work with MyBidhaa',
      'https://mybidhaa.com/career', Icons.work_outline),
];

/// Other MyBidhaa services; each opens its website.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral,
      appBar: AppBar(title: const Text('Other services')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _services.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = _services[i];
          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.1),
                child: Icon(s.icon, color: AppColors.primaryPurple),
              ),
              title: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(s.blurb),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => launchUrl(Uri.parse(s.url),
                  mode: LaunchMode.externalApplication),
            ),
          );
        },
      ),
    );
  }
}
