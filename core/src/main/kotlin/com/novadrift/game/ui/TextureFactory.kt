package com.novadrift.game.ui

import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.Pixmap
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.TextureRegion
import com.badlogic.gdx.scenes.scene2d.ui.Skin
import com.badlogic.gdx.scenes.scene2d.utils.NinePatchDrawable
import com.badlogic.gdx.graphics.g2d.NinePatch

/**
 * Builds every visual we need (rounded cards, buttons, bars, wedges) from Pixmaps at runtime.
 * Keeps the project buildable and previewable before final art assets are dropped in
 * (art can later replace these drawables 1:1 in [com.novadrift.game.ui.UiSkinFactory]).
 */
object TextureFactory {

    /** Disposable textures created so far — disposed together when the game shuts down. */
    private val created = mutableListOf<Texture>()

    fun disposeAll() {
        created.forEach { it.dispose() }
        created.clear()
    }

    fun roundedRect(width: Int, height: Int, color: Color, radius: Int = 16, borderColor: Color? = null, borderWidth: Int = 0): TextureRegion {
        val pixmap = Pixmap(width, height, Pixmap.Format.RGBA8888)
        pixmap.setColor(0f, 0f, 0f, 0f)
        pixmap.fill()
        drawRoundedRect(pixmap, 0, 0, width, height, radius, color)
        if (borderColor != null && borderWidth > 0) {
            drawRoundedRectBorder(pixmap, 0, 0, width, height, radius, borderColor, borderWidth)
        }
        val tex = Texture(pixmap)
        pixmap.dispose()
        created.add(tex)
        return TextureRegion(tex)
    }

    /** Nine-patch friendly rounded rect so buttons/cards can stretch without distorting corners. */
    fun roundedRectNinePatch(color: Color, radius: Int = 20, borderColor: Color? = null, borderWidth: Int = 0): NinePatchDrawable {
        val size = radius * 2 + 4
        val region = roundedRect(size, size, color, radius, borderColor, borderWidth)
        val patch = NinePatch(region, radius, radius, radius, radius)
        return NinePatchDrawable(patch)
    }

    fun circle(diameter: Int, color: Color): TextureRegion {
        val pixmap = Pixmap(diameter, diameter, Pixmap.Format.RGBA8888)
        pixmap.setColor(0f, 0f, 0f, 0f)
        pixmap.fill()
        pixmap.setColor(color)
        pixmap.fillCircle(diameter / 2, diameter / 2, diameter / 2)
        val tex = Texture(pixmap)
        pixmap.dispose()
        created.add(tex)
        return TextureRegion(tex)
    }

    fun solid(width: Int, height: Int, color: Color): TextureRegion {
        val pixmap = Pixmap(width, height, Pixmap.Format.RGBA8888)
        pixmap.setColor(color)
        pixmap.fill()
        val tex = Texture(pixmap)
        pixmap.dispose()
        created.add(tex)
        return TextureRegion(tex)
    }

    /** A single pie wedge, used to build the daily-reward spin wheel without any art. */
    fun wheelTexture(diameter: Int, segments: Int, colorA: Color, colorB: Color): TextureRegion {
        val pixmap = Pixmap(diameter, diameter, Pixmap.Format.RGBA8888)
        pixmap.setColor(0f, 0f, 0f, 0f)
        pixmap.fill()
        val cx = diameter / 2f
        val cy = diameter / 2f
        val r = diameter / 2f
        val step = 360f / segments
        for (y in 0 until diameter) {
            for (x in 0 until diameter) {
                val dx = x - cx
                val dy = y - cy
                val dist = Math.sqrt((dx * dx + dy * dy).toDouble())
                if (dist <= r) {
                    var angle = Math.toDegrees(Math.atan2(dy.toDouble(), dx.toDouble()))
                    if (angle < 0) angle += 360.0
                    val segIndex = (angle / step).toInt()
                    pixmap.drawPixel(x, y, if (segIndex % 2 == 0) Color.rgba8888(colorA) else Color.rgba8888(colorB))
                }
            }
        }
        val tex = Texture(pixmap)
        pixmap.dispose()
        created.add(tex)
        return TextureRegion(tex)
    }

    private fun drawRoundedRect(pixmap: Pixmap, x: Int, y: Int, w: Int, h: Int, r: Int, color: Color) {
        pixmap.setColor(color)
        pixmap.fillRectangle(x + r, y, w - 2 * r, h)
        pixmap.fillRectangle(x, y + r, w, h - 2 * r)
        pixmap.fillCircle(x + r, y + r, r)
        pixmap.fillCircle(x + w - r - 1, y + r, r)
        pixmap.fillCircle(x + r, y + h - r - 1, r)
        pixmap.fillCircle(x + w - r - 1, y + h - r - 1, r)
    }

    private fun drawRoundedRectBorder(pixmap: Pixmap, x: Int, y: Int, w: Int, h: Int, r: Int, color: Color, thickness: Int) {
        pixmap.setColor(color)
        for (i in 0 until thickness) {
            pixmap.drawRectangle(x + i, y + i, w - 2 * i, h - 2 * i)
        }
    }
}
