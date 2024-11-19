class Cell
  constructor: (@row, @col, @region) ->
    @state = 'empty'  # 可能的狀態: 'empty', 'x', 'queen'
    @element = document.createElement('div')
    @element.className = 'cell'
    @element.style.backgroundColor = @getRegionColor()
    @setupEventListeners()

  getRegionColor: ->
    colors = [
      '#FFE4E1', # Misty Rose
      '#E6E6FA', # Lavender
      '#F0FFF0', # Honeydew
      '#FFE4B5', # Moccasin
      '#E0FFFF', # Light Cyan
      '#FFF0F5', # Lavender Blush
      '#F0F8FF', # Alice Blue
      '#FFDAB9'  # Peach Puff
    ]
    return colors[@region % 8]

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