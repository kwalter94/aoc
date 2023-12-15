import scala.io.StdIn
import scala.collection.mutable.ListBuffer
import scala.io.BufferedSource
import scala.collection.mutable.Buffer

package Day15 {
  object Part1 {
    @main def main: Unit =
      val value =
        readInput
          .map(computeHash)
          .reduce(_ + _)

      println { value }

    def readInput: Iterable[String] =
      var line = StdIn.readLine()
      val inputsBuf = ListBuffer[String]()

      while line != null do
        line = line.trim()
        inputsBuf.addAll(line.split(","))
        line = StdIn.readLine()

      inputsBuf.toList

    def computeHash(step: String): Int =
      var accum = 0

      for char <- step.chars().toArray() do
        accum += char.toInt
        accum *= 17
        accum %= 256

      accum
  }
}
