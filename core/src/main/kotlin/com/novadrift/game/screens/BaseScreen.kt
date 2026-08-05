package com.novadrift.game.screens

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.Screen
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.glutils.ShapeRenderer
import com.badlogic.gdx.scenes.scene2d.Stage
import com.badlogic.gdx.utils.viewport.FitViewport
import com.novadrift.game.NovaDriftGame
import com.novadrift.game.util.Constants

/**
 * Shared scaffolding: a [Stage] sized to our fixed virtual resolution (so the landscape
 * layout always matches the reference screenshots regardless of device size), plus a
 * simple vertical-gradient background renderer so each screen can drop in its own palette.
 */
abstract class BaseScreen(protected val game: NovaDriftGame) : Screen {

    protected val stage = Stage(FitViewport(Constants.VIRTUAL_WIDTH, Constants.VIRTUAL_HEIGHT), game.batch)
    private val shapes = ShapeRenderer()

    protected var bgTop: Color = Color.BLACK
    protected var bgBottom: Color = Color.BLACK

    override fun show() {
        Gdx.input.inputProcessor = stage
    }

    protected fun drawGradientBackground() {
        Gdx.gl.glEnable(GL20.GL_BLEND)
        shapes.projectionMatrix = stage.camera.combined
        shapes.begin(ShapeRenderer.ShapeType.Filled)
        val w = Constants.VIRTUAL_WIDTH
        val h = Constants.VIRTUAL_HEIGHT
        shapes.rect(0f, 0f, w, h, bgBottom, bgBottom, bgTop, bgTop)
        shapes.end()
    }

    override fun render(delta: Float) {
        Gdx.gl.glClearColor(0f, 0f, 0f, 1f)
        Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT)
        drawGradientBackground()
        stage.act(delta)
        stage.draw()
    }

    override fun resize(width: Int, height: Int) {
        stage.viewport.update(width, height, true)
    }

    override fun pause() {}
    override fun resume() {}
    override fun hide() {}

    override fun dispose() {
        stage.dispose()
        shapes.dispose()
    }
}
