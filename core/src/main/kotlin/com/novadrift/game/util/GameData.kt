package com.novadrift.game.util

import com.badlogic.gdx.Gdx

/** Thin wrapper around LibGDX [com.badlogic.gdx.Preferences] for player progress/currency. */
class GameData {
    private val prefs = Gdx.app.getPreferences(Constants.PREFS_NAME)

    var gems: Int
        get() = prefs.getInteger(Constants.KEY_GEMS, Constants.STARTING_GEMS)
        set(value) { prefs.putInteger(Constants.KEY_GEMS, value); prefs.flush() }

    fun addGems(amount: Int) { gems += amount }
    fun spendGems(amount: Int): Boolean {
        if (gems < amount) return false
        gems -= amount
        return true
    }

    /** 0..100 percent complete for World 1. Worlds 2/3 follow the same pattern once levels exist. */
    var world1Progress: Int
        get() = prefs.getInteger(Constants.KEY_WORLD1_PROGRESS, 11) // matches reference: 11%
        set(value) { prefs.putInteger(Constants.KEY_WORLD1_PROGRESS, value); prefs.flush() }

    var world2Unlocked: Boolean
        get() = prefs.getBoolean(Constants.KEY_WORLD2_UNLOCKED, false)
        set(value) { prefs.putBoolean(Constants.KEY_WORLD2_UNLOCKED, value); prefs.flush() }

    var world3Unlocked: Boolean
        get() = prefs.getBoolean(Constants.KEY_WORLD3_UNLOCKED, false)
        set(value) { prefs.putBoolean(Constants.KEY_WORLD3_UNLOCKED, value); prefs.flush() }

    var lastDailyRewardDay: Long
        get() = prefs.getLong(Constants.KEY_LAST_DAILY_REWARD_DAY, -1L)
        set(value) { prefs.putLong(Constants.KEY_LAST_DAILY_REWARD_DAY, value); prefs.flush() }

    fun canClaimDailyReward(): Boolean {
        val today = System.currentTimeMillis() / (24L * 60 * 60 * 1000)
        return lastDailyRewardDay != today
    }

    fun markDailyRewardClaimed() {
        lastDailyRewardDay = System.currentTimeMillis() / (24L * 60 * 60 * 1000)
    }
}
