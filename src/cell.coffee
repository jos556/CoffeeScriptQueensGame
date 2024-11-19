class Cell
  constructor: (@row, @col, @region) ->
    @state = 'empty'  # 可能的狀態: 'empty', 'x', 'queen'
    @element = document.createElement('div')
    @element.className = 'cell'
    @element.style.backgroundColor = @getRegionColor()
    @setupEventListeners()

  getRegionColor: ->
    # 根據region返回不同的顏色
    colors = [
      '#FFE4E1', '#E6E6FA', '#F0FFF0', '#F5F5DC',
      '#E0FFFF', '#FFE4B5', '#F0F8FF', '#FFF0F5'
    ]
    colors[@region % colors.length]

  setupEventListeners: ->
    @element.addEventListener 'click', =>
      @toggleState()

  toggleState: ->
    switch @state
      when 'empty' then @setState('x')
      when 'x' then @setState('queen')
      when 'queen' then @setState('empty')

  setState: (newState) ->
    @state = newState
    @updateDisplay()

  updateDisplay: ->
    switch @state
      when 'empty' then @element.textContent = ''
      when 'x' then @element.textContent = 'X'
      when 'queen' then @element.textContent = '👑' 

# 將 Cell 類添加到全局範圍
window.Cell = Cell