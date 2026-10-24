package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * App-owned plugin registrant template.
 *
 * The integration_test plugin is present only in debug/instrumented builds.
 * Registering it reflectively keeps release APK/AAB compilation independent
 * of the test-only Android library while preserving integration-test support.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    registerOptionalPlugin(
        flutterEngine,
        "dev.flutter.plugins.integration_test.IntegrationTestPlugin",
        "integration_test");
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin url_launcher_android, io.flutter.plugins.urllauncher.UrlLauncherPlugin", e);
    }
  }

  private static void registerOptionalPlugin(
      FlutterEngine flutterEngine, String className, String pluginName) {
    try {
      Class<?> pluginClass = Class.forName(className);
      Object plugin = pluginClass.getDeclaredConstructor().newInstance();
      if (plugin instanceof FlutterPlugin) {
        flutterEngine.getPlugins().add((FlutterPlugin) plugin);
      } else {
        Log.e(TAG, "Skipping plugin " + pluginName + ": class is not a FlutterPlugin");
      }
    } catch (ClassNotFoundException ignored) {
      // Optional plugin is intentionally absent from production release builds.
    } catch (ReflectiveOperationException | LinkageError e) {
      Log.e(TAG, "Error registering optional plugin " + pluginName + " (" + className + ")", e);
    }
  }
}
