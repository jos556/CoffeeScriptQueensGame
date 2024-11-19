class Board
  constructor: (@size, @regions) ->
    @cells = []
    @createBoard()

  createBoard: ->
    @element = document.createElement('div')
    @element.id = 'game-board'
    
    for row in [0...@size]
      rowDiv = document.createElement('div')
      rowDiv.className = 'row'
      rowCells = []
      
      for col in [0...@size]
        cell = new Cell(row, col, @regions[row][col])
        rowCells.push(cell)
        rowDiv.appendChild(cell.element)
      
      @cells.push(rowCells)
      @element.appendChild(rowDiv)

  checkSolution: ->
    @checkRows() and @checkColumns() and @checkRegions() and @checkDiagonals()

  checkRows: ->
    for row in @cells
      queens = row.filter((cell) -> cell.state is 'queen')
      if queens.length isnt 1
        return false
    true

  checkColumns: ->
    for col in [0...@size]
      queens = @cells.map((row) -> row[col])
                    .filter((cell) -> cell.state is 'queen')
      if queens.length isnt 1
        return false
    true

  checkRegions: ->
    regionCounts = {}
    for row in @cells
      for cell in row
        if cell.state is 'queen'
          regionCounts[cell.region] ?= 0
          regionCounts[cell.region]++
    
    for region, count of regionCounts
      if count isnt 1
        return false
    true

  checkDiagonals: ->
    for row in [0...@size]
      for col in [0...@size]
        if @cells[row][col].state is 'queen'
          if @hasAdjacentQueen(row, col)
            return false
    true

  hasAdjacentQueen: (row, col) ->
    directions = [
      [-1,-1], [-1,0], [-1,1],
      [0,-1],          [0,1],
      [1,-1],  [1,0],  [1,1]
    ]
    
    for [dx, dy] in directions
      newRow = row + dx
      newCol = col + dy
      if @isValidPosition(newRow, newCol)
        if @cells[newRow][newCol].state is 'queen'
          return true
    false

  isValidPosition: (row, col) ->
    row >= 0 and row < @size and col >= 0 and col < @size 

# 將 Board 類添加到全局範圍
window.Board = Board