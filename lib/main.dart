import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local storage
  await LocalStorage.init();

  // Initialize Realtime Free Backend (Supabase or Offline-first Realtime Engine)
  await SupabaseService.instance.init();

  runApp(
    const ProviderScope(
      child: PadCareApp(),
    ),
  );
}
