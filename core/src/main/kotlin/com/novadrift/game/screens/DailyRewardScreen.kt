package com.novadrift.game.screens

import com.badlogic.gdx.scenes.scene2d.InputEvent
import com.badlogic.gdx.scenes.scene2d.actions.Actions
import com.badlogic.gdx.scenes.scene2d.ui.Image
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener
import com.novadrift.game.NovaDriftGame
import com.novadrift.game.ui.TextureFactory
import com.novadrift.game.util.Palette
import kotlin.random.Random

/** "DAILY REWARD" spin wheel — 8 wedges (gem amounts + a couple of special icons), matches reference. */
class DailyRewardScreen(game: NovaDriftGame) : BaseScreen(game) {

    // Reward values read clockwise from the top wedge in the reference image.
    private val segmentValues = listOf(1000, 300, 400, 50, 200, -1, 200, 100) // -1 = "special" wedge
    private lateinit var wheelImage: Image
    private var spinning = false

    init {
        bgTop = Palette.REWARD_BG_TOP
        bgBottom = Palette.REWARD_BG_BOTTOM

        val root = Table()
        root.setFillParent(true)
        stage.addActor(root)

        root.add(Label("DAILY REWARD", game.skin, "title")).padTop(20f).colspan(2).row()

        val wheelStack = Table()
        val wheelTexture = TextureFactory.wheelTexture(320, segmentValues.size, Palette.WHEEL_LIGHT, Palette.WHEEL_DARK)
        wheelImage = Image(wheelTexture)
        wheelImage.setOrigin(160f, 160f)
        val hub = Image(TextureFactory.circle(48, Palette.REWARD_BG_BOTTOM))

        val wheelContainer = com.badlogic.gdx.scenes.scene2d.Group()
        wheelContainer.addActor(wheelImage)
        hub.setPosition(160f - 24f, 160f - 24f)
        wheelContainer.addActor(hub)
        wheelContainer.setSize(320f, 320f)

        wheelStack.add(wheelContainer).size(320f)

        val rightCol = Table()
        val spinBtn = TextButton("SPIN", game.skin, "button-white")
        spinBtn.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) {
                if (!spinning) doSpin()
            }
        })
        val noThanks = TextButton("no thanks", game.skin, "small").apply {
            style = TextButton.TextButtonStyle(style).apply { up = null; down = null }
        }
        noThanks.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) {
                game.setScreen(MainMenuScreen(game))
            }
        })

        rightCol.add(spinBtn).width(220f).height(56f).padBottom(16f).row()
        rightCol.add(noThanks).row()

        val middleRow = Table()
        middleRow.add(wheelStack).padRight(60f)
        middleRow.add(rightCol)

        root.add(middleRow).expand().row()
    }

    private fun doSpin() {
        spinning = true
        val winnerIndex = Random.nextInt(segmentValues.size)
        val degreesPerSegment = 360f / segmentValues.size
        // land the winning wedge under the fixed top pointer, plus a few full spins for effect
        val targetAngle = 360f * 4 + (360f - winnerIndex * degreesPerSegment)
        wheelImage.addAction(
            Actions.sequence(
                Actions.rotateBy(targetAngle, 2.4f, com.badlogic.gdx.math.Interpolation.exp10Out),
                Actions.run {
                    spinning = false
                    val reward = segmentValues[winnerIndex]
                    if (reward > 0) game.data.addGems(reward)
                    game.data.markDailyRewardClaimed()
                }
            )
        )
    }
}
