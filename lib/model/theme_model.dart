class ThemeModel {
  final String name;
  final String? boardPath;
  final String? stepBlockPath;
  final String? homeBlockPath;
  final String? pathBlockPath;
  final String? baseBlockPath;
  final String? starPath;
  final Map<String, String>? tokenPaths; // color -> path
  final List<String>? diceFacePaths; // 1-6 -> path

  const ThemeModel({
    required this.name,
    this.boardPath,
    this.stepBlockPath,
    this.homeBlockPath,
    this.pathBlockPath,
    this.baseBlockPath,
    this.starPath,
    this.tokenPaths,
    this.diceFacePaths,
  });

  // Default theme with no overrides
  factory ThemeModel.defaultTheme() {
    return const ThemeModel(name: 'default');
  }

  // Create from config
  factory ThemeModel.fromConfig(Map<String, dynamic> config) {
    return ThemeModel(
      name: config['name'] ?? 'default',
      boardPath: config['boardPath'],
      stepBlockPath: config['stepBlockPath'],
      homeBlockPath: config['homeBlockPath'],
      pathBlockPath: config['pathBlockPath'],
      baseBlockPath: config['baseBlockPath'],
      starPath: config['starPath'],
      tokenPaths: config['tokenPaths'] != null
          ? Map<String, String>.from(config['tokenPaths'])
          : null,
      diceFacePaths: config['diceFacePaths'] != null
          ? List<String>.from(config['diceFacePaths'])
          : null,
    );
  }
}
