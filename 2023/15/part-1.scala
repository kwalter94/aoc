import scala.io.StdIn
import scala.collection.mutable.ListBuffer

package AOC2023 {
  package Day15 {
    object Part1 {
      @main def main: Unit =
        println(readInput.map(computeHash).reduce(_ + _))

      def readInput: Iterable[String] = {
        val inputsBuf = ListBuffer[String]()
        var line = ""

        while { line = StdIn.readLine(); line != null } do {
          line = line.trim()
          inputsBuf.addAll(line.split(","))
        }

        inputsBuf.toList
      }

      def computeHash(step: String): Int =
        step
          .chars()
          .toArray()
          .foldLeft(0)((accum, char) => ((accum + char.toInt) * 17) % 256)
    }
  }
}
