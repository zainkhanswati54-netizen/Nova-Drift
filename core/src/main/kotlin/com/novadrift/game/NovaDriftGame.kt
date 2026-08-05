package com.novadrift.game

import com.badlogic.gdx.Game
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.novadrift.game.screens.SplashScreen
import com.novadrift.game.ui.TextureFactory
import com.novadrift.game.ui.UiSkinFactory
import com.novadrift.game.util.GameData

/**
 * Nova Drift — an arrow-dashing arcade game (Kotlin + LibGDX).
 * This class is the single source of truth for shared resources (batch, skin, save data)
 * and hands control to whichever [com.badlogic.gdx.Screen] is active.
 */
class NovaDriftGame : Game() {

    lateinit var batch: SpriteBatch
        private set
    lateinit var skin: Skin
        private set
    lateinit var data: GameData
        private set

    override fun create() {
        batch = SpriteBatch()
        skin = UiSkinFactory.build()
        data = GameData()
        setScreen(SplashScreen(this))
    }

    override fun dispose() {
        super.dispose()
        screen?.dispose()
        batch.dispose()
        skin.dispose()
        TextureFactory.disposeAll()
    }
}
