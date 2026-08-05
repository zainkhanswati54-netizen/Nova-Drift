package com.novadrift.game.ui

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.scenes.scene2d.ui.Image
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.badlogic.gdx.scenes.scene2d.ui.Table
import com.badlogic.gdx.scenes.scene2d.ui.TextButton
import com.badlogic.gdx.utils.Align
import com.novadrift.game.util.Palette

/** The gem-count pill + "[+]" button shown top-right on menu/level-select screens. */
class GemBar(skin: Skin, gemCount: Int, onAddClicked: () -> Unit) : Table() {

    private val countLabel = Label(gemCount.toString(), skin, "body")

    init {
        val pill = Table()
        pill.background = TextureFactory.roundedRectNinePatch(Color(0f, 0f, 0f, 0.35f), 22)
        val diamond = Image(TextureFactory.roundedRect(36, 36, Palette.GEM_PURPLE, 8))
        pill.add(diamond).size(28f).padLeft(10f).padRight(8f)
        countLabel.setAlignment(Align.center)
        pill.add(countLabel).padRight(16f)

        val addButton = TextButton("+", skin, "button-white")
        addButton.addListener(object : com.badlogic.gdx.scenes.scene2d.utils.ClickListener() {
            override fun clicked(event: com.badlogic.gdx.scenes.scene2d.InputEvent?, x: Float, y: Float) {
                onAddClicked()
            }
        })

        add(pill).height(44f)
        add(addButton).size(44f).padLeft(6f)
    }

    fun setGems(amount: Int) {
        countLabel.setText(amount.toString())
    }
}
