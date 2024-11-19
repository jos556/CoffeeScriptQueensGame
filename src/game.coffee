class Game
  constructor: ->
    @size = 8
    @regions = @generateRandomRegions()
    @board = new Board(@size, @regions)
    @hintsRemaining = 3
    @startTime = null
    @timerInterval = null
    @initializeGame()

  # 生成隨機但有解的區域配置
  generateRandomRegions: ->
    # 首先生成一個有效的皇后解
    @solution = @generateValidQueensSolution()
    # 基於皇后的位置生成區域
    @generateRegionsFromSolution(@solution)

  generateValidQueensSolution: ->
    solution = Array(@size).fill(null)
    @placeQueens(solution, 0)
    solution

  # 遞迴放置皇后
  placeQueens: (solution, row) ->
    return true if row >= @size
    
    # 隨機嘗試每一列
    cols = [0...@size]
    cols = @shuffleArray(cols)
    
    for col in cols
      if @isSafe(solution, row, col)
        solution[row] = col
        return true if @placeQueens(solution, row + 1)
        solution[row] = null
    
    false

  # 檢查位置是否安全
  isSafe: (solution, row, col) ->
    # 檢查之前的行
    for i in [0...row]
      return false if solution[i] == col
      return false if Math.abs(solution[i] - col) == Math.abs(i - row)
    true

  # Fisher-Yates 洗牌算法
  shuffleArray: (array) ->
    for i in [array.length-1..1]
      j = Math.floor(Math.random() * (i + 1))
      [array[i], array[j]] = [array[j], array[i]]
    array

  # 基於皇后解生成區域
  generateRegionsFromSolution: (solution) ->
    # 創建二維數組的正確方式
    regions = []
    for i in [0...@size]
      row = []
      for j in [0...@size]
        row.push(0)
      regions.push(row)

    regionCount = 0
    
    # 為每個皇后創建一個區域
    for row in [0...@size]
      col = solution[row]
      currentRegion = regionCount++
      regions[row][col] = currentRegion
      
      # 擴展區域
      @expandRegion(regions, row, col, currentRegion)
    
    # 填充剩餘的空格
    @fillRemainingSpaces(regions)
    regions

  # 擴展區域
  expandRegion: (regions, row, col, region) ->
    # 隨機擴展區域的大小（2-4個格子）
    expansionSize = 2 + Math.floor(Math.random() * 3)
    directions = @shuffleArray([[-1,0], [1,0], [0,-1], [0,1]])
    
    for i in [0...expansionSize]
      for [dx, dy] in directions
        newRow = row + dx
        newCol = col + dy
        if @isValidPosition(newRow, newCol) and regions[newRow][newCol] == 0
          regions[newRow][newCol] = region
          break

  # 填充剩餘空格
  fillRemainingSpaces: (regions) ->
    for row in [0...@size]
      for col in [0...@size]
        if regions[row][col] == 0
          # 找到鄰近的區域
          neighbors = @getNeighborRegions(regions, row, col)
          if neighbors.length > 0
            # 隨機選擇一個鄰近區域
            regions[row][col] = neighbors[Math.floor(Math.random() * neighbors.length)]
          else
            # 如果沒有鄰近區域，創建新區域
            regions[row][col] = Math.max(...regions.flat()) + 1

  # 獲取鄰近的區域
  getNeighborRegions: (regions, row, col) ->
    neighbors = new Set()
    directions = [[-1,0], [1,0], [0,-1], [0,1]]
    
    for [dx, dy] in directions
      newRow = row + dx
      newCol = col + dy
      if @isValidPosition(newRow, newCol) and regions[newRow][newCol] != 0
        neighbors.add(regions[newRow][newCol])
    
    Array.from(neighbors)

  isValidPosition: (row, col) ->
    row >= 0 and row < @size and col >= 0 and col < @size

  initializeGame: ->
    gameBoard = document.getElementById('game-board')
    gameBoard.parentNode.replaceChild(@board.element, gameBoard)

    document.getElementById('check-button').addEventListener 'click', =>
      @checkSolution()

    document.getElementById('hint-button').addEventListener 'click', =>
      @giveHint()

    document.getElementById('reset-button').addEventListener 'click', =>
      @resetBoard()

    @startTimer()
    @updateHintCount()

  startTimer: ->
    @startTime = new Date()
    @timerInterval = setInterval(@updateTimer, 1000)

  updateTimer: =>
    return unless @startTime
    currentTime = new Date()
    timeDiff = Math.floor((currentTime - @startTime) / 1000)
    minutes = Math.floor(timeDiff / 60)
    seconds = timeDiff % 60
    timeString = "#{@padZero(minutes)}:#{@padZero(seconds)}"
    document.getElementById('timer').textContent = "時間: #{timeString}"

  padZero: (num) ->
    if num < 10 then "0#{num}" else "#{num}"

  updateHintCount: ->
    document.getElementById('hint-count').textContent = "提示次數剩餘: #{@hintsRemaining}"

  giveHint: ->
    return if @hintsRemaining <= 0
    
    # 移除之前的提示效果
    @clearHints()
    
    # 找到一個可以放置皇后的位置
    hintFound = false
    for row in [0...@size]
      col = @solution[row]
      cell = @board.cells[row][col]
      if cell.state isnt 'queen'
        cell.element.classList.add('hint')
        hintFound = true
        break
    
    if hintFound
      @hintsRemaining--
      @updateHintCount()
      # 3秒後移除提示效果
      setTimeout(@clearHints, 3000)

  clearHints: =>
    for row in @board.cells
      for cell in row
        cell.element.classList.remove('hint')

  checkSolution: ->
    if @board.checkSolution()
      clearInterval(@timerInterval)
      timeTaken = Math.floor((new Date() - @startTime) / 1000)
      minutes = Math.floor(timeTaken / 60)
      seconds = timeTaken % 60
      timeString = "#{minutes}分#{seconds}秒"
      
      # 顯示完成彈窗
      modal = document.getElementById('completion-modal')
      timeDisplay = document.getElementById('completion-time')
      timeDisplay.textContent = "完成時間：#{timeString}"
      modal.style.display = 'block'
      
      # 添加關閉按鈕事件
      document.getElementById('modal-close').onclick = ->
        modal.style.display = 'none'
    else
      # 顯示未完成彈窗
      modal = document.getElementById('incomplete-modal')
      modal.style.display = 'block'
      
      # 添加關閉按鈕事件
      document.getElementById('incomplete-modal-close').onclick = ->
        modal.style.display = 'none'

  resetBoard: ->
    clearInterval(@timerInterval)
    @startTime = new Date()
    @timerInterval = setInterval(@updateTimer, 1000)
    @hintsRemaining = 3
    @updateHintCount()
    @clearHints()
    for row in @board.cells
      for cell in row
        cell.setState('empty')

# 將 Game 類添加到全局範圍
window.Game = Game

# 初始化遊戲
document.addEventListener 'DOMContentLoaded', ->
  window.game = new Game() 