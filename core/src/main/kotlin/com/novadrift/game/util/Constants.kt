package com.novadrift.game.util

import com.badlogic.gdx.graphics.Color

/** Nova Drift is a landscape game — matches the reference UI (1200x540 design canvas). */
object Constants {
    const val VIRTUAL_WIDTH = 1200f
    const val VIRTUAL_HEIGHT = 540f

    const val PREFS_NAME = "nova_drift_prefs"
    const val KEY_GEMS = "gems"
    const val KEY_WORLD1_PROGRESS = "world1_progress"
    const val KEY_WORLD2_UNLOCKED = "world2_unlocked"
    const val KEY_WORLD3_UNLOCKED = "world3_unlocked"
    const val KEY_LAST_DAILY_REWARD_DAY = "last_daily_reward_day"

    const val STARTING_GEMS = 260
}

/** Central palette pulled straight from the reference screenshots so every screen feels consistent. */
object Palette {
    // Splash / space background
    val SPACE_DARK = Color.valueOf("0B0E2A")
    val SPACE_MID = Color.valueOf("1B1F4B")

    // Main menu (Select A Game Mode) — magenta/crimson theme
    val MENU_BG_TOP = Color.valueOf("B0134B")
    val MENU_BG_BOTTOM = Color.valueOf("7A0E36")
    val MENU_CARD = Color.valueOf("F07BAC")
    val MENU_CARD_TEXT = Color.valueOf("6B1030")
    val MENU_BUTTON = Color.valueOf("FFFFFF")

    // World / level select (Classic) — olive/gold theme
    val WORLD_BG_TOP = Color.valueOf("9A8C00")
    val WORLD_BG_BOTTOM = Color.valueOf("C9BC1F")
    val WORLD_CARD_LOCKED = Color.valueOf("5C5300")
    val WORLD_CARD_UNLOCKED = Color.valueOf("EDE24A")
    val WORLD_BAR_BG = Color.valueOf("C7BE7A")
    val WORLD_BAR_FILL = Color.valueOf("4A4300")

    // Daily reward wheel — purple/magenta theme
    val REWARD_BG_TOP = Color.valueOf("8A1064")
    val REWARD_BG_BOTTOM = Color.valueOf("5C0A46")
    val WHEEL_LIGHT = Color.valueOf("FFFFFF")
    val WHEEL_DARK = Color.valueOf("A32E86")

    val GEM_PURPLE = Color.valueOf("9B30FF")
    val WHITE = Color.WHITE
}
