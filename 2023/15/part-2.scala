import scala.io.StdIn
import scala.collection.mutable.ListBuffer
import scala.collection.mutable.ArrayDeque

package AOC2023 {
  package Day15 {
    object Part2 {
      @main def main: Unit = {
        val totalFocusingPower =
          getBoxes.zipWithIndex
            .map((box, i) => boxFocusingPower(box, i))
            .sum

        println(totalFocusingPower)
      }

      def getBoxes: Array[Array[(String, Int)]] = {
        val boxes = (0 to 256).map(_ => ArrayDeque[(String, Int)]()).toArray

        for (label, symbol, focalLength) <- readInput do {
          val hash = computeHash(label)
          val index =
            boxes(hash).find(_._1 == label).map(boxes(hash).indexOf(_))

          index match {
            case Some(i) if symbol == '=' => {
              boxes(hash).insert(i, (label, focalLength.get))
              boxes(hash).remove(i + 1, 1)
            }
            case Some(i) if symbol == '-' => {
              boxes(hash).remove(i, 1)
            }
            case None if symbol == '=' => {
              boxes(hash).addOne((label, focalLength.get))
            }
            case _ => {}
          }
        }

        boxes.map(_.toArray)
      }

      def readInput: Iterable[(String, Char, Option[Int])] = {
        val buff = ListBuffer[(String, Char, Option[Int])]()
        var label = ""
        var symbol = 0.toChar
        var focalLength: Option[Int] = None

        var line = ""

        while { line = StdIn.readLine; line != null } do {
          for ordinal <- line.chars().toArray() do {
            val char = ordinal.toChar

            char match {
              case ',' => {
                buff.addOne((label, symbol, focalLength))
                label = ""
                symbol = '\u0000'
                focalLength = None
              }
              case '=' | '-' => {
                symbol = char
              }
              case _ if char.isDigit => {
                if focalLength.isEmpty then focalLength = Some(char.asDigit)
                else focalLength = focalLength.map(_ * 10 + char.asDigit)
              }
              case _ => {
                label += char
              }
            }
          }
        }

        buff.addOne((label, symbol, focalLength))
        buff.toList
      }

      def computeHash(step: String): Int =
        step.chars.toArray
          .foldLeft(0)((accum, char) => ((accum + char.toInt) * 17) % 256)

      def boxFocusingPower(box: Iterable[(String, Int)], boxNumber: Int): Int =
        box.zipWithIndex
          .map((lens, i) => (boxNumber + 1) * (i + 1) * lens._2)
          .foldLeft(0)((accum, focusingPower) => accum + focusingPower)
    }
  }
}
