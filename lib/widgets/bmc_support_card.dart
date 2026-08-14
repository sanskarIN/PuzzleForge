import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/constants/app_links.dart';
import '../core/localization/app_localizations.dart';

class BmcSupportCard extends StatelessWidget {
  const BmcSupportCard({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final scheme = Theme.of(context).colorScheme;
    Future<void> openSupport() async {
      final opened = await ControllerScope.read(
        context,
      ).openExternal(AppLinks.buyMeACoffee);
      if (!context.mounted || opened) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.text('support.openFailed'))),
      );
    }

    return Semantics(
      button: true,
      link: true,
      label: strings.text('support.bmcLabel'),
      onTap: openSupport,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openSupport,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[scheme.primary, scheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(compact ? 16 : 22),
            child: Row(
              children: <Widget>[
                Container(
                  width: compact ? 48 : 64,
                  height: compact ? 48 : 64,
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.coffee_rounded,
                    color: scheme.onPrimary,
                    size: compact ? 28 : 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        strings.text('support.bmc'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (!compact) ...<Widget>[
                        const SizedBox(height: 5),
                        Text(
                          strings.text('support.optional'),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.88),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.open_in_new_rounded, color: scheme.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
