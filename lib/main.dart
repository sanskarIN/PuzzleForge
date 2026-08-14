import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_controller.dart';
import 'core/services/external_link_service.dart';
import 'core/storage/app_repository.dart';
import 'core/storage/key_value_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await SharedPreferencesKeyValueStore.create();
  runApp(
    PuzzleForgeApp(
      controller: AppController(
        repository: AppRepository(store),
        externalLinks: SafeExternalLinkService(),
      ),
    ),
  );
}
