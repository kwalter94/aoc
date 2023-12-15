import scala.io.StdIn
import scala.collection.mutable.ListBuffer
import java.io.EOFException
import scala.io.Source
import java.io.IOException
import scala.collection.mutable.ArrayDeque

package Day15 {
  object Part2 {
    @main def main: Unit =
      val boxes = (0 to 256).map(_ => ArrayDeque[(String, Int)]()).toArray

      for (label, symbol, focalLength) <- readInput do
        val hash = computeHash(label)

        if symbol == '=' then
          val index = boxes(hash)
            .find(_._1 == label)
            .map(boxes(hash).indexOf(_))

          if index.isEmpty then boxes(hash).addOne((label, focalLength.get))
          else
            boxes(hash).insert(index.get, (label, focalLength.get))
            boxes(hash).remove(index.get + 1, 1)
        else if symbol == '-' then
          val index = boxes(hash)
            .find(_._1 == label)
            .map(boxes(hash).indexOf(_))

          if !index.isEmpty then boxes(hash).remove(index.get, 1)

      val focalLengths =
        boxes
          .zip((0 to boxes.length))
          .map((box, i) => {
            box
              .zip(0 to box.length)
              .foldLeft(0)((accum, box_item) => {
                val (lens, j) = box_item
                accum + (i + 1) * ((j + 1) * lens._2)
              })
          })

      println(focalLengths.sum)

    def readInput: Iterable[(String, Char, Option[Int])] =
      val buff = ListBuffer[(String, Char, Option[Int])]()
      var label = ""
      var symbol = 0.toChar
      var focalLength: Option[Int] = None

      var line = ""

      while { line = StdIn.readLine; line != null } do
        for ordinal <- line.chars().toArray() do
          val char = ordinal.toChar

          char match
            case ',' =>
              buff.addOne((label, symbol, focalLength))
              label = ""
              symbol = '\u0000'
              focalLength = None
            case '=' | '-' =>
              symbol = char
            case _ if char.isDigit =>
              if focalLength.isEmpty then focalLength = Some(char.asDigit)
              else focalLength = focalLength.map(_ * 10 + char.asDigit)
            case _ =>
              label += char

      buff.addOne((label, symbol, focalLength))
      buff.toList

    def computeHash(step: String): Int =
      var accum = 0

      for char <- step.chars().toArray() do
        accum += char.toInt
        accum *= 17
        accum %= 256

      accum
  }
}
