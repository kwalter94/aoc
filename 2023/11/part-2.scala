package AOC2023 {
  package Day10 {
    import scala.collection.mutable.ArrayBuffer
    import scala.io.StdIn

    enum Content:
      case Space, Planet

    type World = ArrayBuffer[ArrayBuffer[Content]]

    type Point = (Long, Long)

    object Part1 {
      @main def main: Unit = {
        val coordinates = planetCoordinates(readInput).toArray
        coordinates.foreach(println)
        val distances = (0 to coordinates.size - 2).flatMap(i => {
          val start = coordinates(i)
          coordinates
            .slice(i + 1, coordinates.size)
            .map(shortestDistanceBetweenPoints(start, _))
        })
        println(distances.sum)
      }

      def readInput: World = {
        val world = ArrayBuffer[ArrayBuffer[Content]]()
        var line = ""

        while { line = StdIn.readLine; line != null } do {
          val row = line.map[Content](char =>
            if char == '#' then Content.Planet else Content.Space
          )
          world.addOne(ArrayBuffer[Content]().addAll(row))
        }

        world
      }

      val DISTORTION_UNIT = 1_000_000

      def getRealDistances(world: World): (Array[Long], Array[Long]) = {
        val x_distances = ArrayBuffer[Long]()
        var distortion = 0L

        for x <- (0 to world(0).size - 1) do {
          x_distances.addOne(x + distortion)

          if (0 to world.size - 1).forall(world(_)(x) == Content.Space) then
            distortion += DISTORTION_UNIT - 1
        }

        val y_distances = ArrayBuffer[Long]()
        distortion = 0L

        for y <- (0 to world.size - 1) do {
          y_distances.addOne(y + distortion)

          if (0 to world(y).size - 1).forall(world(y)(_) == Content.Space) then
            distortion += DISTORTION_UNIT - 1
        }

        (x_distances.toArray, y_distances.toArray)
      }

      def planetCoordinates(world: World): Iterable[Point] = {
        val realDistances = getRealDistances(world)

        world.zipWithIndex
          .flatMap((row, y) =>
            row.zipWithIndex
              .map((content, x) =>
                if content == Content.Planet then
                  (realDistances._1(x), realDistances._2(y))
                else (-1L, -1L)
              )
          )
          .filter(point => point._1 >= 0L)
      }

      def shortestDistanceBetweenPoints(from: Point, to: Point): Long = {
        val (start_x, start_y) = from
        val (end_x, end_y) = to

        if start_x == end_x then (end_y - start_y).abs
        else if start_y == end_y then (end_x - start_x).abs
        else if (end_x - start_x).abs >= (end_y - start_y).abs then
          (end_y - start_y).abs * 2 + ((end_x - start_x).abs - (end_y - start_y).abs)
        else
          (end_x - start_x).abs * 2 + ((end_y - start_y).abs - (end_x - start_x).abs)
      }
    }
  }
}
