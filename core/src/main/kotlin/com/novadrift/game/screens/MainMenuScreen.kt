package com.novadrift.game.screens

import com.badlogic.gdx.scenes.scene2d.InputEvent
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.badlogic.gdx.scenes.scene2d.utils.ClickListener
import com.badlogic.gdx.utils.Align
import com.novadrift.game.NovaDriftGame
import com.novadrift.game.ui.GemBar
import com.novadrift.game.ui.TextureFactory
import com.novadrift.game.util.Palette

/** "SELECT A GAME MODE" screen — Classic / Endless / Race, plus shop/gift/skin/settings shortcuts. */
class MainMenuScreen(game: NovaDriftGame) : BaseScreen(game) {

    init {
        bgTop = Palette.MENU_BG_TOP
        bgBottom = Palette.MENU_BG_BOTTOM

        val root = Table()
        root.setFillParent(true)
        root.top()
        stage.addActor(root)

        // ---- Top bar: title + gem currency ----
        val topBar = Table()
        topBar.add(Label("SELECT A GAME MODE", game.skin, "title")).expandX().center()
        val gemBar = GemBar(game.skin, game.data.gems) { /* TODO: open IAP / add-gems flow */ }
        topBar.add(gemBar).right()
        root.add(topBar).growX().pad(20f, 24f, 0f, 24f).row()

        // ---- Center: three mode cards ----
        val cardsRow = Table()
        cardsRow.add(modeCard("CLASSIC", "reach the finish\nto complete levels", "SELECT LEVEL") {
            game.setScreen(LevelSelectScreen(game))
        }).pad(20f).growY()
        cardsRow.add(modeCard("ENDLESS", "go as far as possible\nand set a highscore", null) {
            // TODO: launch GameScreen in endless mode
        }).pad(20f).growY()
        cardsRow.add(modeCard("RACE", "reach the finish\nbefore others", null) {
            // TODO: launch GameScreen in race mode (multiplayer/bots)
        }).pad(20f).growY()
        root.add(cardsRow).expand().center().row()

        // ---- Bottom: Skin / Settings ----
        val bottomRow = Table()
        val skinBtn = TextButton("  SKIN", game.skin, "button-white")
        val settingsBtn = TextButton("  SETTINGS", game.skin, "button-white")
        bottomRow.add(skinBtn).height(52f).width(220f).padRight(16f)
        bottomRow.add(settingsBtn).height(52f).width(220f)
        root.add(bottomRow).padBottom(20f)

        // ---- Left side icon column: Shop / Offer ----
        val leftCol = Table()
        leftCol.add(iconButton("SHOP") { /* TODO: open shop */ }).size(84f).padBottom(12f).row()
        leftCol.add(iconButton("% OFFER") { /* TODO: open offers */ }).size(84f)
        leftCol.setPosition(70f, stage.viewport.worldHeight / 2f)
        stage.addActor(leftCol)

        // ---- Right side icon column: Gift / No-Ads ----
        val rightCol = Table()
        rightCol.add(iconButton("GIFT") { openDailyReward() }).size(84f).padBottom(12f).row()
        rightCol.add(iconButton("NO-ADS") { /* TODO: open IAP remove-ads */ }).size(84f)
        rightCol.setPosition(stage.viewport.worldWidth - 70f - 84f, stage.viewport.worldHeight / 2f)
        stage.addActor(rightCol)
    }

    private fun openDailyReward() {
        game.setScreen(DailyRewardScreen(game))
    }

    private fun modeCard(title: String, desc: String, actionLabel: String?, onStart: () -> Unit): Table {
        val card = Table()
        card.background = TextureFactory.roundedRectNinePatch(Palette.MENU_CARD, 18)
        card.pad(20f)

        card.add(Label(title, game.skin, "body-dark").apply { setAlignment(Align.center) }).padBottom(14f).row()
        card.add(Label(desc, game.skin, "small").apply {
            setAlignment(Align.center)
            color = Palette.MENU_CARD_TEXT
        }).padBottom(20f).row()

        if (actionLabel != null) {
            val selectBtn = TextButton(actionLabel, game.skin, "button-card")
            card.add(selectBtn).width(200f).height(44f).padBottom(12f).row()
        } else {
            card.add().height(56f).row()
        }

        val startBtn = TextButton("START >", game.skin, "button-white")
        startBtn.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) = onStart()
        })
        card.add(startBtn).width(200f).height(48f)

        return card
    }

    private fun iconButton(label: String, onClick: () -> Unit): TextButton {
        val btn = TextButton(label, game.skin, "button-icon")
        btn.label.setWrap(true)
        btn.addListener(object : ClickListener() {
            override fun clicked(event: InputEvent?, x: Float, y: Float) = onClick()
        })
        return btn
    }
}
