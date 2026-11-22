/// Sizes of the on-screen buttons and badges, shared by the HUD (which
/// draws them) and the game (which keeps pickups out from under them).
class HudLayout {
  /// The big round bonus buttons (beehive, honey) in the bottom corners.
  static const buttonSize = 112.0;
  static const buttonMargin = 24.0;

  /// Space at the top of the screen for the score and level badges.
  static const topHeight = 110.0;

  /// Extra room above the buttons so a pickup is never half under one.
  static const _clearance = 40.0;

  /// How far up from the bottom of the screen pickups must stay.
  static const bottomStrip = buttonMargin + buttonSize + _clearance;
}
