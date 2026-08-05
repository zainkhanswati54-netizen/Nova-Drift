package com.novadrift.game.screens

import com.badlogic.gdx.scenes.scene2d.ui.Image
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.ProgressBar
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.novadrift.game.NovaDriftGame
import com.novadrift.game.ui.TextureFactory
import com.novadrift.game.util.Palette

/**
 * First screen shown on launch. Mirrors the reference splash: dark starfield backdrop,
 * a bold logo mark, and a loading bar. Real asset loading (AssetManager.update) will
 * plug into [progressBar] once art/audio assets exist — for now it's a timed simulation
 * so the flow (Splash -> Main Menu) is fully testable today.
 */
class SplashScreen(game: NovaDriftGame) : BaseScreen(game) {

    private val progressBar: ProgressBar
    private var elapsed = 0f
    private val loadDuration = 1.6f
    private var finished = false

    init {
        bgTop = Palette.SPACE_MID
        bgBottom = Palette.SPACE_DARK

        val root = Table()
        root.setFillParent(true)
        stage.addActor(root)

        // Logo mark: a simple angular "arrow" built from a rotated square, rainbow-tinted
        // to echo the app icon until real logo art is dropped in.
        val logo = Image(TextureFactory.roundedRect(140, 140, Palette.GEM_PURPLE, 28))
        logo.setOrigin(70f, 70f)
        logo.rotation = 45f

        val title = Label("NOVA DRIFT", game.skin, "title")
        val subtitle = Label("dash through the waves", game.skin, "small")

        root.add(logo).size(120f).padBottom(28f).row()
        root.add(title).padBottom(6f).row()
        root.add(subtitle).padBottom(48f).row()

        progressBar = ProgressBar(0f, 1f, 0.01f, false, game.skin)
        root.add(progressBar).width(420f).height(18f)
    }

    override fun render(delta: Float) {
        super.render(delta)
        if (finished) return
        elapsed += delta
        progressBar.value = (elapsed / loadDuration).coerceIn(0f, 1f)
        if (elapsed >= loadDuration) {
            finished = true
            game.setScreen(MainMenuScreen(game))
        }
    }
}
