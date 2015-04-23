CKEDITOR.disableAutoInline = true

class Inplace
  constructor: (@model) ->
    @instances = {}
    @editors = {}

  ###
  Register listener to widget editors.
  ###
  register: (type, Editor) ->
    @editors[type] = Editor
    $("[data-editable='#{type}']").each (i, el) =>
      @instances[$(el).attr('id')] = new Editor(el)

  ###
  Save the current context.
  ###
  save: ->
    targetField = if @model.get('type')?
      'properties'
    else
      'content'
    for own key, instance of @instances
      if $('#' + key).attr('data-global')?
        @model.get('global')[key] = instance.value()
      else
        @model.get(targetField)[key] = instance.value()
    $('#cms-alert').removeClass('hide')
    $('#save').attr 'disabled', 'disabled'
    isNew = !@model.get('__v')
    @model.save()
      .done =>
        $('#cms-alert')
          .removeClass 'alert-info'
          .removeClass 'alert-danger'
          .addClass 'alert-success'
          .html '''
            <i class="fa fa-refresh fa-spin"></i>
            Erfolgreich gespeichert!
          '''
        if isNew and @model.get('type')?
          location.replace(
            "#{location.origin}#{location.pathname}?_id=#{@model.id}"
          )
        else
          location.reload()
      .fail ->
        $('#save').attr 'disabled', false
        $('#cms-alert')
          .removeClass 'alert-info'
          .addClass 'alert-danger'
          .html '''
            <i class="fa fa-exclamation-triangle"></i>
            Speichern fehlgeschlagen!
          '''

inplace = window.INPLACE = new Inplace

###
Handler for simpletext editors
###
inplace.register 'simpletext', class
  constructor: (@el) ->
    $(@el).attr 'contenteditable', 'true'

  value: -> $(@el).html()

###
Handler for ckeditor editors.
###
inplace.register 'text', class
  constructor: (@el) ->
    $(@el).attr 'contenteditable', 'true'
    @editor = CKEDITOR.inline($(@el).attr('id'))

  value: ->
    @editor.getData()

inplace.register 'input', class
  constructor: (@el) ->
  value: -> $(@el).val()

###
Register the save handler.
###
$('#save').on 'click', ->
  inplace.save()
  false
