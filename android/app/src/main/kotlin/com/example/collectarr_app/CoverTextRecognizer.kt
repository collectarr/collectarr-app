package com.example.collectarr_app

import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import java.nio.FloatBuffer
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Reads the text of a cover on the device with PaddleOCR's detection and Latin
 * recognition models, without an angle classifier (see assets/cover_ocr/NOTICE.txt).
 */
class CoverTextRecognizer(private val assets: AssetManager) {
    private val env = OrtEnvironment.getEnvironment()
    private val detector = session("det.onnx")
    private val recognizer = session("rec.onnx")

    // The models reserve class 0 for CTC's blank and the last class for a space.
    private val characters: List<String> = listOf("") +
        assets.open("$ASSETS/keys.txt").bufferedReader(Charsets.UTF_8).readLines() + " "

    private fun session(name: String): OrtSession =
        env.createSession(assets.open("$ASSETS/$name").use { it.readBytes() })

    private class Box(val left: Int, val top: Int, val right: Int, val bottom: Int)

    fun read(path: String): String {
        val image = decode(path) ?: error("Cannot decode $path")
        return detect(image).mapNotNull { box ->
            val width = box.right - box.left + 1
            val height = box.bottom - box.top + 1
            if (width < 2 || height < 2) return@mapNotNull null
            var crop = Bitmap.createBitmap(image, box.left, box.top, width, height)
            if (height >= 1.5f * width) crop = rotated(crop, 270f)
            recognize(crop).takeIf { it.isNotBlank() }
        }.joinToString("\n")
    }

    /** Decodes [path] upright, at no more than the detector's largest input. */
    private fun decode(path: String): Bitmap? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        var sample = 1
        while (max(bounds.outWidth, bounds.outHeight) / (sample * 2) >= MAX_SIDE) sample *= 2
        val options = BitmapFactory.Options().apply { inSampleSize = sample }
        val image = BitmapFactory.decodeFile(path, options) ?: return null
        val degrees = when (
            ExifInterface(path).getAttributeInt(
                ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
        ) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90f
            ExifInterface.ORIENTATION_ROTATE_180 -> 180f
            ExifInterface.ORIENTATION_ROTATE_270 -> 270f
            else -> 0f
        }
        return if (degrees == 0f) image else rotated(image, degrees)
    }

    private fun rotated(image: Bitmap, degrees: Float): Bitmap = Bitmap.createBitmap(
        image, 0, 0, image.width, image.height, Matrix().apply { postRotate(degrees) }, true)

    private fun tensor(bitmap: Bitmap, width: Int): OnnxTensor {
        val w = bitmap.width
        val h = bitmap.height
        val pixels = IntArray(w * h)
        bitmap.getPixels(pixels, 0, w, 0, 0, w, h)
        // Channel-first BGR in [-1, 1]; anything past the bitmap stays 0.
        val data = FloatArray(3 * h * width)
        for (y in 0 until h) for (x in 0 until w) {
            val pixel = pixels[y * w + x]
            val at = y * width + x
            data[at] = (pixel and 255) / 127.5f - 1f
            data[h * width + at] = ((pixel shr 8) and 255) / 127.5f - 1f
            data[2 * h * width + at] = ((pixel shr 16) and 255) / 127.5f - 1f
        }
        return OnnxTensor.createTensor(
            env, FloatBuffer.wrap(data), longArrayOf(1, 3, h.toLong(), width.toLong()))
    }

    private fun detect(image: Bitmap): List<Box> {
        var scale = max(1f, MIN_SIDE / min(image.width, image.height))
        if (max(image.width, image.height) * scale > MAX_SIDE) {
            scale = MAX_SIDE / max(image.width, image.height)
        }
        val w = max(32, (image.width * scale / 32f).roundToInt() * 32)
        val h = max(32, (image.height * scale / 32f).roundToInt() * 32)
        val resized = Bitmap.createScaledBitmap(image, w, h, true)
        val probability = tensor(resized, w).use { input ->
            detector.run(mapOf(detector.inputNames.first() to input)).use { output ->
                FloatArray(w * h).also { (output[0] as OnnxTensor).floatBuffer.get(it) }
            }
        }
        val seen = BooleanArray(w * h)
        val queue = IntArray(w * h)
        val boxes = mutableListOf<Box>()
        val toImageX = image.width.toFloat() / w
        val toImageY = image.height.toFloat() / h
        for (start in probability.indices) {
            if (seen[start] || probability[start] <= TEXT_THRESHOLD) continue
            var head = 0
            var tail = 0
            queue[tail++] = start
            seen[start] = true
            var left = w
            var right = 0
            var top = h
            var bottom = 0
            var sum = 0f
            while (head < tail) {
                val at = queue[head++]
                val x = at % w
                val y = at / w
                left = min(left, x)
                right = max(right, x)
                top = min(top, y)
                bottom = max(bottom, y)
                sum += probability[at]
                for (next in intArrayOf(at - 1, at + 1, at - w, at + w)) {
                    if (next < 0 || next >= probability.size) continue
                    if ((next == at - 1 && x == 0) || (next == at + 1 && x == w - 1)) continue
                    if (!seen[next] && probability[next] > TEXT_THRESHOLD) {
                        seen[next] = true
                        queue[tail++] = next
                    }
                }
            }
            val boxWidth = right - left + 1
            val boxHeight = bottom - top + 1
            if (boxWidth < 4 || boxHeight < 4 || sum / tail < BOX_THRESHOLD) continue
            // The detector marks shrunken text; grow it back as PP-OCR's unclip does.
            val grow = boxWidth * boxHeight * UNCLIP_RATIO / (2f * (boxWidth + boxHeight))
            boxes += Box(
                ((left - grow) * toImageX).toInt().coerceAtLeast(0),
                ((top - grow) * toImageY).toInt().coerceAtLeast(0),
                ((right + grow) * toImageX).toInt().coerceAtMost(image.width - 1),
                ((bottom + grow) * toImageY).toInt().coerceAtMost(image.height - 1))
        }
        return boxes.sortedWith(compareBy({ it.top / 10 }, { it.left }))
    }

    private fun recognize(crop: Bitmap): String {
        val lineWidth = max(1, ceil(LINE_HEIGHT * crop.width.toFloat() / crop.height).toInt())
        val line = Bitmap.createScaledBitmap(crop, lineWidth, LINE_HEIGHT, true)
        return tensor(line, max(MIN_LINE_WIDTH, lineWidth)).use { input ->
            recognizer.run(mapOf(recognizer.inputNames.first() to input)).use { output ->
                val result = output[0] as OnnxTensor
                val steps = result.info.shape[1].toInt()
                val classes = result.info.shape[2].toInt()
                val values = result.floatBuffer
                val text = StringBuilder()
                var previous = 0
                var total = 0f
                var count = 0
                for (step in 0 until steps) {
                    var best = 0
                    var score = -1f
                    for (index in 0 until classes) {
                        val value = values.get(step * classes + index)
                        if (value > score) {
                            score = value
                            best = index
                        }
                    }
                    if (best != 0 && best != previous) {
                        text.append(characters[best])
                        total += score
                        count++
                    }
                    previous = best
                }
                if (count > 0 && total / count >= LINE_THRESHOLD) text.toString() else ""
            }
        }
    }

    private companion object {
        const val ASSETS = "cover_ocr"
        const val MIN_SIDE = 736f
        const val MAX_SIDE = 2000f
        const val TEXT_THRESHOLD = .3f
        const val BOX_THRESHOLD = .5f
        const val UNCLIP_RATIO = 1.6f
        const val LINE_HEIGHT = 48
        const val MIN_LINE_WIDTH = 320
        const val LINE_THRESHOLD = .5f
    }
}
