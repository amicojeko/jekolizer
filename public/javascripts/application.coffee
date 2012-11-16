window.puts = (string)-> console?.log? string

class ReplacementPair
  constructor: ->
    @firstPair = $ '.replacement_pair[num="0"]'
    @el = @firstPair.clone()

  render: ->
    @el.attr 'num', 1
    @button = @el.find('.button')
    @button.removeClass('add').addClass('del').text('-')
    @button.click => @el.remove()
    @el.insertAfter @firstPair


$ ->
  # r = new ReplacementPair
  # r.render()
