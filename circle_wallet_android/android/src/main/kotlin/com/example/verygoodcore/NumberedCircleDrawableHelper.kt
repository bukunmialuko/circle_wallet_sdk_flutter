package com.example.verygoodcore

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.TypedValue

/**
 * Creates a numbered circle drawable for the Security Confirmation item list (B1).
 *
 * Visual spec:
 *  - Circle fill: #9E9FA0
 *  - Number text: #6172F3
 */
object NumberedCircleDrawableHelper {

    private const val CIRCLE_COLOR = "#1C2126"
    private const val NUMBER_COLOR = "#6172F3"

    fun make(context: Context, number: Int): Drawable {
        // Size: 32dp circle
        val sizePx = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP, 32f,
            context.resources.displayMetrics
        ).toInt()

        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // Draw filled circle
        val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor(CIRCLE_COLOR)
            style = Paint.Style.FILL
        }
        val radius = sizePx / 2f
        canvas.drawCircle(radius, radius, radius, circlePaint)

        // Draw number text centred in circle
        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor(NUMBER_COLOR)
            textSize = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP, 13f,
                context.resources.displayMetrics
            )
            isFakeBoldText = true
            textAlign = Paint.Align.CENTER
        }

        // Vertically centre the text
        val textBounds = android.graphics.Rect()
        val label = number.toString()
        textPaint.getTextBounds(label, 0, label.length, textBounds)
        val textY = radius + (textBounds.height() / 2f) - textBounds.bottom

        canvas.drawText(label, radius, textY, textPaint)

        return BitmapDrawable(context.resources, bitmap)
    }
}
