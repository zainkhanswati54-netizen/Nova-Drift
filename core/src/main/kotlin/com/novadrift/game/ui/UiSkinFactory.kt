package com.novadrift.game.ui

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.ProgressBar
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.novadrift.game.util.Palette

/**
 * Builds one shared [Skin] used across every screen.
 * Uses LibGDX's built-in font at runtime (no .ttf bundled yet) so the project
 * runs immediately — swap in a real display font here once art/typography is finalized.
 */
object UiSkinFactory {

    fun build(): Skin {
        val skin = Skin()

        val titleFont = BitmapFont().apply { data.setScale(2.4f) }
        val bodyFont = BitmapFont().apply { data.setScale(1.3f) }
        val smallFont = BitmapFont().apply { data.setScale(1.0f) }
        skin.add("font-title", titleFont)
        skin.add("font-body", bodyFont)
        skin.add("font-small", smallFont)

        // ---- Label styles ----
        skin.add("title", Label.LabelStyle(titleFont, Color.WHITE))
        skin.add("body", Label.LabelStyle(bodyFont, Color.WHITE))
        skin.add("small", Label.LabelStyle(smallFont, Color.WHITE))
        skin.add("body-dark", Label.LabelStyle(bodyFont, Palette.MENU_CARD_TEXT))

        // ---- Buttons ----
        val whiteButtonStyle = TextButton.TextButtonStyle().apply {
            up = TextureFactory.roundedRectNinePatch(Color.WHITE, 14)
            down = TextureFactory.roundedRectNinePatch(Color(0.9f, 0.9f, 0.9f, 1f), 14)
            font = bodyFont
            fontColor = Palette.MENU_CARD_TEXT
        }
        skin.add("button-white", whiteButtonStyle)

        val cardButtonStyle = TextButton.TextButtonStyle().apply {
            up = TextureFactory.roundedRectNinePatch(Color(1f, 1f, 1f, 0.15f), 10, Color.WHITE, 2)
            down = TextureFactory.roundedRectNinePatch(Color(1f, 1f, 1f, 0.3f), 10, Color.WHITE, 2)
            font = bodyFont
            fontColor = Color.WHITE
        }
        skin.add("button-card", cardButtonStyle)

        val iconButtonStyle = TextButton.TextButtonStyle().apply {
            up = TextureFactory.roundedRectNinePatch(Color(0f, 0f, 0f, 0.25f), 8, Color.WHITE, 2)
            down = TextureFactory.roundedRectNinePatch(Color(0f, 0f, 0f, 0.4f), 8, Color.WHITE, 2)
            font = smallFont
            fontColor = Color.WHITE
        }
        skin.add("button-icon", iconButtonStyle)

        // ---- Progress bar (world/level completion %) ----
        val progressStyle = ProgressBar.ProgressBarStyle().apply {
            background = TextureFactory.roundedRectNinePatch(Palette.WORLD_BAR_BG, 10)
            knobBefore = TextureFactory.roundedRectNinePatch(Palette.WORLD_BAR_FILL, 10)
        }
        skin.add("default-horizontal", progressStyle)

        return skin
    }
}
