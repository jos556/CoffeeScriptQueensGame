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
    # 創建二維數組
    regions = []
    for i in [0...@size]
      row = []
      for j in [0...@size]
        row.push(-1)  # 使用-1表示未分配區域
      regions.push(row)

    regionCount = 0
    
    # 為每個皇后創建一個區域
    for row in [0...@size]
      col = solution[row]
      if regions[row][col] is -1  # 只有在未分配時才創建新區域
        currentRegion = regionCount
        regionCount++
        if regionCount > 7  # 確保不超過8個區域
          regionCount = 0
        regions[row][col] = currentRegion
        @expandRegion(regions, row, col, currentRegion)
    
    # 填充剩餘的空格
    @fillRemainingSpaces(regions)
    
    # 驗證區域數量
    usedRegions = new Set(regions.flat())
    console.log("Generated regions count:", usedRegions.size)
    
    return regions

  # 擴展區域
  expandRegion: (regions, row, col, region) ->
    # 確保每個區域至少有2-3個格子
    expansionSize = 2 + Math.floor(Math.random() * 2)
    directions = @shuffleArray([[-1,0], [1,0], [0,-1], [0,1]])
    
    expanded = 0
    for [dx, dy] in directions
      break if expanded >= expansionSize
      newRow = row + dx
      newCol = col + dy
      if @isValidPosition(newRow, newCol) and regions[newRow][newCol] is -1
        regions[newRow][newCol] = region
        expanded++

  # 填充剩餘空格
  fillRemainingSpaces: (regions) ->
    maxRegion = 7  # 設定最大區域編號

    for row in [0...@size]
      for col in [0...@size]
        if regions[row][col] is -1
          neighbors = @getNeighborRegions(regions, row, col)
          if neighbors.length > 0
            # 選擇數量最少的鄰近區域
            regionCounts = {}
            for region in neighbors
              regionCounts[region] = 0 unless regionCounts[region]?
              regionCounts[region]++
            
            minCount = Math.min(...Object.values(regionCounts))
            availableRegions = Object.keys(regionCounts).filter((r) -> 
              regionCounts[r] is minCount
            )
            regions[row][col] = parseInt(availableRegions[0])
          else
            # 如果沒有鄰近區域，使用最小可用的區域號（0-7）
            usedRegions = new Set(regions.flat().filter((r) -> r isnt -1))
            for i in [0..maxRegion]
              unless usedRegions.has(i)
                regions[row][col] = i
                break
            # 如果沒有找到可用區域，使用區域 0
            if regions[row][col] is -1
              regions[row][col] = 0

    # 最後檢查並修正任何大於 7 的區域
    for row in [0...@size]
      for col in [0...@size]
        if regions[row][col] > maxRegion
          regions[row][col] = regions[row][col] % (maxRegion + 1)

  # 獲取鄰近的區域
  getNeighborRegions: (regions, row, col) ->
    neighbors = new Set()
    directions = [[-1,0], [1,0], [0,-1], [0,1]]
    
    for [dx, dy] in directions
      newRow = row + dx
      newCol = col + dy
      if @isValidPosition(newRow, newCol) and regions[newRow][newCol] isnt -1
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

    # 添加幫助按鈕事件
    document.getElementById('help-button').addEventListener 'click', =>
      document.getElementById('help-modal').style.display = 'block'

    document.getElementById('help-modal-close').addEventListener 'click', =>
      document.getElementById('help-modal').style.display = 'none'

    # 點擊模態框外部關閉
    document.getElementById('help-modal').addEventListener 'click', (e) =>
      if e.target.id == 'help-modal'
        e.target.style.display = 'none'

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