import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Vos fichiers de configuration locaux
import 'config/supabase_config.dart';
import 'config/routes.dart';
import 'config/theme.dart';

void main() async {
  // Indispensable pour l'initialisation asynchrone de Supabase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: HollaApp(),
    ),
  );
}

// Raccourci global pour accéder au client Supabase partout dans l'application
final supabase = Supabase.instance.client;

class HollaApp extends ConsumerWidget {
  const HollaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute de la configuration GoRouter provenant de votre Riverpod Provider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HOLLA',
      debugShowCheckedModeBanner: false,
      
      // Gestion dynamique du thème (Clair / Sombre basé sur le système)
      theme: HollaTheme.light,
      darkTheme: HollaTheme.dark,
      themeMode: ThemeMode.system,
      
      // Liaison avec GoRouter pour la navigation
      routerConfig: router,
      
      // Configuration des délégués pour la localisation (Correction ici)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
      ],
    );
  }
}