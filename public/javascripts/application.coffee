window.puts = (string)-> console?.log? string

class ReplacementPair
  @count: ->
    list = []
    $('.replacement_pair').each (index, el)-> list.push($(el).attr('num')*1)
    list.sort()
    list[list.length - 1]+1

  @default: -> $ '.replacement_pair[num="0"]'


  constructor: (isDefault) ->
    if isDefault?
      @el = ReplacementPair.default()
      @button().click -> (new ReplacementPair()).render()
    else
      @el = ReplacementPair.default().clone()
      @el.attr 'num', ReplacementPair.count
      @el.find('label').remove()
      @el.find('input').val ''
      @el.find('input[name="replacements[0][s]"]').attr 'name', "replacements[#{@index()}][s]"
      @el.find('input[name="replacements[0][r]"]').attr 'name', "replacements[#{@index()}][r]"
      @button().removeClass('add').addClass('del').text '-'

  button:    -> @el.find '.button'
  isDefault: -> @index() is 0
  index:     -> @el.attr('num')*1
  remove:    -> @el.remove()

  render: ->
    unless @isDefault()
      @button().click => @remove()
      @el.insertBefore 'li.submit'




class Form
  constructor: ->
    @el = $ 'form'
    @submit = @el.find 'input[type="submit"]'
    @submit.click (e) =>
      unless @submitting
        e.preventDefault()
        e.stopPropagation()
        @send()

  send: ->
    return unless @isValid()
    $.ajax
      url:        @el.attr 'action'
      data:       @el.serialize()+"&json=1"
      beforeSend: @_beforeSend
      dataType:   'json'
      type:       'POST'
      success:    @_sendSucceeded
      error:      @_sendFailed
      complete:   @_sendComplete

  isValid: ->
    valid = true
    @el.find('.url input, .search input').each (index, el)->
      valid = false unless $.trim($(el).val()).length
    valid

  urlSection: -> $ '.generated_url'

  _sendSucceeded: (response) =>
    link = $ '<a>'
    link.attr 'href', response.url
    link.attr 'target', '_blank'
    link.text response.url
    link.appendTo @urlSection()
    @urlSection().removeClass 'hidden'

  _sendFailed: (response) =>
    # todo

  _sendComplete: =>
    @submitting = false
    @submit.attr 'disabled', false
    $('.loading').remove()

  _beforeSend: =>
    @submitting = true
    @submit.attr 'disabled', true
    @urlSection().addClass 'hidden'
    @urlSection().find('a').remove()
    @_loading().insertAfter @submit

  _loading: =>
    $('<span>').addClass 'loading'



$ ->
  new ReplacementPair(true)
  new Form()