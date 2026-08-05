package com.novadrift.game.screens

import com.badlogic.gdx.scenes.scene2d.InputEvent
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.ProgressBar
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener
import com.badlogic.gdx.utils.Align
import com.novadrift.game.NovaDriftGame
import com.novadrift.game.ui.GemBar
import com.novadrift.game.ui.TextureFactory
import com.novadrift.game.util.Palette

/** "CLASSIC" world-select screen — Special + World 1/2/3 + Coming Soon, matching the reference. */
class LevelSelectScreen(game: NovaDriftGame) : BaseScreen(game) {

    private data class WorldDef(
        val title: String,
        val desc: String,
        val progressPercent: Int?, // null = "Coming Soon" style card
        val locked: Boolean
    )

    init {
        bgTop = Palette.WORLD_BG_TOP
        bgBottom = Palette.WORLD_BG_BOTTOM

        val root = Table()
        root.setFillParent(true)
        root.top()
        stage.addActor(root)

        // ---- Top bar: back, cart, title, gems ----
        val topBar = Table()
        val backBtn = TextButton("<-", game.skin, "button-icon")
        backBtn.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) {
                game.setScreen(MainMenuScreen(game))
            }
        })
        val cartBtn = TextButton("cart", game.skin, "button-icon")

        topBar.add(backBtn).size(50f).padRight(10f)
        topBar.add(cartBtn).size(50f)
        topBar.add(Label("CLASSIC", game.skin, "title")).expandX().center()
        topBar.add(GemBar(game.skin, game.data.gems) {}).right()
        root.add(topBar).growX().pad(20f, 24f, 0f, 24f).row()

        // ---- World cards row ----
        val worlds = listOf(
            WorldDef("SPECIAL", "new worlds!!!", 0, false),
            WorldDef("WORLD 1", "simple world with\nsimple levels", game.data.world1Progress, false),
            WorldDef("WORLD 2", "EASY levels", null, !game.data.world2Unlocked),
            WorldDef("WORLD 3", "the floor is LAVA!", null, !game.data.world3Unlocked),
        )

        val cardsRow = Table()
        for (w in worlds) {
            cardsRow.add(worldCard(w)).growY().pad(10f, 8f, 10f, 8f)
        }
        // Trailing "coming soon" column, per reference layout
        val comingSoon = Table()
        comingSoon.background = TextureFactory.roundedRectNinePatch(Palette.WORLD_CARD_UNLOCKED, 0)
        comingSoon.add(Label("COMING\nSOON!", game.skin, "body-dark").apply { setAlignment(Align.center) })
        cardsRow.add(comingSoon).growY().growX().pad(10f, 8f, 10f, 8f)

        root.add(cardsRow).grow().row()

        // ---- Overall progress bar footer, per reference ----
        val footerBar = ProgressBar(0f, 100f, 1f, false, game.skin)
        footerBar.value = overallProgress(worlds)
        root.add(footerBar).growX().height(14f).pad(0f, 0f, 16f, 0f)
    }

    private fun overallProgress(worlds: List<WorldDef>): Float {
        val vals = worlds.mapNotNull { it.progressPercent }
        return if (vals.isEmpty()) 0f else vals.average().toFloat()
    }

    private fun worldCard(w: WorldDef): Table {
        val card = Table()
        card.background = TextureFactory.roundedRectNinePatch(
            if (w.locked) Palette.WORLD_CARD_LOCKED else Palette.WORLD_CARD_UNLOCKED, 0
        )
        card.pad(16f)

        card.add(Label(w.title, game.skin, "body-dark").apply { setAlignment(Align.center) }).padBottom(12f).row()

        // Progress pill or lock icon
        val statusPill = Table()
        statusPill.background = TextureFactory.roundedRectNinePatch(Palette.WORLD_BAR_BG, 10)
        val statusLabel = Label(if (w.locked) "LOCK" else "${w.progressPercent}%", game.skin, "small").apply {
            color = worldCardTextColor
            setAlignment(Align.center)
        }
        statusPill.add(statusLabel).pad(6f, 0f, 6f, 0f).growX()
        card.add(statusPill).width(140f).height(30f).padBottom(20f).row()

        card.add().expand().row() // spacer, description sits mid-card like reference

        card.add(Label(w.desc, game.skin, "small").apply {
            setAlignment(Align.center)
            color = worldCardTextColor
        }).padBottom(20f).row()

        val selectBtn = TextButton("SELECT", game.skin, "button-card")
        selectBtn.isDisabled = w.locked
        selectBtn.touchable = if (w.locked) com.badlogic.gdx.scenes.scene2d.Touchable.disabled else com.badlogic.gdx.scenes.scene2d.Touchable.enabled
        selectBtn.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) {
                if (!w.locked) {
                    // TODO: launch GameScreen(game, world = w.title, mode = CLASSIC)
                }
            }
        })
        card.add(selectBtn).width(160f).height(44f)

        return card
    }
}

/** Dark text reads fine on both locked (olive) and unlocked (yellow) cards. */
private val worldCardTextColor: com.badlogic.gdx.graphics.Color = com.badlogic.gdx.graphics.Color.valueOf("2A2600")
