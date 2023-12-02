package AOC2023 {
  package Day10 {
    import scala.collection.mutable.ArrayBuffer
    import scala.io.StdIn

    enum Content:
      case Space, Planet

    type World = ArrayBuffer[ArrayBuffer[Content]]

    type Point = (Int, Int)

    object Part1 {
      @main def main: Unit = {
        val coordinates = planetCoordinates(stretchWorld(readInput)).toArray
        val distances = (0 to coordinates.size - 2).flatMap(i => {
          val start = coordinates(i)
          coordinates
            .slice(i + 1, coordinates.size)
            .map(shortestDistanceBetweenPoints(start, _))
        })
        distances.foreach(println)
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

      def stretchWorld(world: World): World = {
        val stretchedWorld = ArrayBuffer[ArrayBuffer[Content]]()

        // Stretch rows
        for { row <- world } do {
          stretchedWorld.addOne(row.clone)

          if row.forall(_ == Content.Space) then {
            val blankRow = ArrayBuffer[Content]()
            blankRow.addAll((0 to row.length).map(_ => Content.Space))
            stretchedWorld.addOne(blankRow)
          }
        }

        var addedColumns = 0

        // Stretch columns
        for { col <- (0 to world(0).length - 1) } do {
          val hasPlanet =
            (0 to world.length - 1)
              .find(row => world(row)(col) == Content.Planet)

          hasPlanet match {
            case None =>
              stretchedWorld
                .foreach(row => row.insert(col + addedColumns, Content.Space))
              addedColumns += 1
            case Some(_) => {}
          }
        }

        stretchedWorld
      }

      def planetCoordinates(world: World): Iterable[Point] =
        world.zipWithIndex
          .flatMap((row, y) =>
            row.zipWithIndex
              .map((content, x) =>
                if content == Content.Planet then (x, y) else (-1, -1)
              )
          )
          .filter(point => point._1 >= 0)

      def shortestDistanceBetweenPoints(from: Point, to: Point): Int = {
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
