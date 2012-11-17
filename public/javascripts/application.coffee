window.puts = (string)-> console?.log? string

class ReplacementPair
  constructor: (isDefault)->
    if isDefault?
      @el = ReplacementPair.default()
      @button().click -> (new ReplacementPair()).render()
    else
      @el = ReplacementPair.default().clone()
      @el.attr 'num', ReplacementPair.count
      @el.find('label').remove()
      @el.find('input[name="replacements[0][s]"]').attr 'name', "replacements[#{@index()}][s]"
      @el.find('input[name="replacements[0][r]"]').attr 'name', "replacements[#{@index()}][r]"
      @button().removeClass('add').addClass('del').text '-'

  button: ->
    @el.find '.button'

  @default: ->
    $ '.replacement_pair[num="0"]'

  @count: ->
    list = []
    $('.replacement_pair').each (index, el)-> list.push($(el).attr('num')*1)
    list.sort()
    list[list.length - 1]+1

  isDefault: ->
    @index() is 0

  index: ->
    @el.attr('num')*1

  remove: ->
    @el.remove()

  render: ->
    return if @isDefault()
    @button().click => @remove()
    @el.insertAfter ReplacementPair.default()

$ ->
  new ReplacementPair(true)
