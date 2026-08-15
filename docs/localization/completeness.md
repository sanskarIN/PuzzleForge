# Translation Completeness

| Locale | Key parity | Developer review | Professional review | Release status |
|---|---|---|---|---|
| English (`en`) | 100% automated parity baseline | Complete | Not requested | Source |
| Hindi (`hi`) | 100% automated parity | Complete | Pending | Included with review notice |
| Pseudolocale (`en-XA`) | Generated from English | Automated | Not applicable | Developer-only layout aid |

`test/localization/localization_test.dart` fails when English and Hindi keys diverge. Text-scaling, overflow, TalkBack pronunciation, and cultural review remain manual/device release gates.
