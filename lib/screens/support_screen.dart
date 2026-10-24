import 'package:flutter/material.dart';

import '../core/constants/app_links.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/bmc_support_card.dart';
import '../widgets/brand_mark.dart';
import '../widgets/external_link_tile.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('support.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const BmcSupportCard(),
          ExternalLinkTile(
            icon: Icons.favorite_outline_rounded,
            label: strings.text('support.razorpay'),
            uri: AppLinks.razorpay,
          ),
          ExternalLinkTile(
            icon: Icons.favorite_outline_rounded,
            label: strings.text('support.paypal'),
            uri: AppLinks.paypal,
          ),
          const SizedBox(height: 18),
          Text(
            strings.text('support.contact'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          ExternalLinkTile(
            icon: Icons.language_rounded,
            label: strings.text('about.website'),
            uri: AppLinks.website,
          ),
          ExternalLinkTile(
            icon: Icons.support_agent_rounded,
            label: strings.text('support.mainEmail'),
            uri: AppLinks.mainEmail,
          ),
          ExternalLinkTile(
            icon: Icons.business_center_outlined,
            label: strings.text('support.businessEmail'),
            uri: AppLinks.businessEmail,
          ),
          const SizedBox(height: 12),
          SelectableText(
            AppLinks.buyMeACoffee.toString(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('about.title'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const Center(child: BrandMark(size: 100)),
          const SizedBox(height: 16),
          Text(
            strings.text('app.name'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(strings.text('app.tagline'), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(strings.text('about.openSource'), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(strings.text('about.credits'), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ExternalLinkTile(
            icon: Icons.code_rounded,
            label: strings.text('about.repository'),
            uri: AppLinks.repository,
          ),
          ExternalLinkTile(
            icon: Icons.person_outline_rounded,
            label: strings.text('about.creator'),
            uri: AppLinks.creator,
          ),
          ExternalLinkTile(
            icon: Icons.language_rounded,
            label: strings.text('about.website'),
            uri: AppLinks.website,
          ),
          const SizedBox(height: 14),
          const BmcSupportCard(compact: true),
          const SizedBox(height: 18),
          Text(
            strings.text('common.version', <String, Object?>{
              'version': '0.1.0+1',
            }),
            textAlign: TextAlign.center,
          ),
          Text(strings.text('app.creator'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({required this.titleKey, required this.bodyKey, super.key});
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.strings.text(titleKey))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          context.strings.text(bodyKey),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        Text(
          context.strings.text('legal.review'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 18),
        const BmcSupportCard(compact: true),
      ],
    ),
  );
}
