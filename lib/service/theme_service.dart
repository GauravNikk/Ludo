import 'dart:convert';
import 'package:aag_user/model/theme_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  // Available themes
  final availableThemes = ['default', 'ice', 'fire'];

  // Load theme by name
  Future<ThemeModel> loadTheme(String themeName) async {
    try {
      if (themeName == 'default') {
        return ThemeModel.defaultTheme();
      }

      // Try to load theme config
      final String configPath = 'assets/themes/$themeName/config.json';
      final String configData = await rootBundle.loadString(configPath);
      final config = json.decode(configData);

      return ThemeModel.fromConfig({
        'name': themeName,
        'boardPath': 'assets/themes/$themeName/board.png',
        'stepBlockPath': 'assets/themes/$themeName/step_block.png',
        'homeBlockPath': 'assets/themes/$themeName/home_block.png',
        'pathBlockPath': 'assets/themes/$themeName/path_block.png',
        'baseBlockPath': 'assets/themes/$themeName/base_block.png',
        'starPath': 'assets/themes/$themeName/star.png',
        'tokenPaths': {
          'red': 'assets/themes/$themeName/red_token.png',
          'blue': 'assets/themes/$themeName/blue_token.png',
          'green': 'assets/themes/$themeName/green_token.png',
          'yellow': 'assets/themes/$themeName/yellow_token.png',
        },
        'diceFacePaths': [
          'assets/themes/$themeName/dice_1.png',
          'assets/themes/$themeName/dice_2.png',
          'assets/themes/$themeName/dice_3.png',
          'assets/themes/$themeName/dice_4.png',
          'assets/themes/$themeName/dice_5.png',
          'assets/themes/$themeName/dice_6.png',
        ],
        ...config,
      });
    } catch (e) {
      // Fallback to default theme if there's an error
      print('Error loading theme $themeName: $e');
      return ThemeModel.defaultTheme();
    }
  }

  // Check if an asset exists
  Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
