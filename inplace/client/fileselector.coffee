modal = require('./fileselector/modal.jade')

$modal = null
$modal = $('<div id="cms-modal-files" class="fade modal"></div>')
$modal.css 'z-index', '99999999999'
$modal.appendTo 'body'

Files = Backbone.Collection.extend(
  url: '/inplace/files'
)

###
Backbone view to synchronise the chooser with the download link within the DOM.
###
Editor = Backbone.View.extend(
  events:
    'click button.fa-trash[data-id]': 'destroy'
    'click a[data-id]': 'select'
    'shown.bs.tab a[data-toggle="pill"]': 'tabChange'
    'keyup input[type="text"]': 'textChange'

  textChange: (e) ->
    @text = $(e.target).val()
    @trigger 'change:text', @text

  tabChange: (e) ->
    @tab = $(e.target).attr('href').slice(1)

  render: ->
    @$el.html modal(this)
    @$('input[type="text"]').val @text
    @$('#download').attr 'href', @href
    @renderDropzone()

  renderDropzone: ->
    previewNode = @$('#template').get(0)
    previewNode.id = ""
    previewTemplate = previewNode.parentNode.innerHTML
    previewNode.parentNode.removeChild previewNode
    myDropzone = new Dropzone(@$('.modal-content').get(0),
      url: "/inplace/files" # Set the url
      thumbnailWidth: 80
      thumbnailHeight: 80
      parallelUploads: 20
      previewTemplate: previewTemplate
      autoQueue: false # Make sure the files aren't queued until manually added
      previewsContainer: @$('#previews').get(0)
      clickable: @$('.fileinput-button').get(0)
    )
    myDropzone.on "addedfile", (file) ->
      # Hookup the start button
      file.previewElement.querySelector(".start").onclick = ->
        myDropzone.enqueueFile file

    # Update the total progress bar
    myDropzone.on "totaluploadprogress", (progress) ->
      document.querySelector("#total-progress .progress-bar").style.width = progress + "%"

    myDropzone.on "sending", (file) ->
      # Show the total progress bar when upload starts
      document.querySelector("#total-progress").style.opacity = "1"
      # And disable the start button
      file.previewElement.querySelector(".start").setAttribute "disabled", "disabled"

    # Hide the total progress bar when nothing's uploading anymore
    myDropzone.on "queuecomplete", (progress) ->
      document.querySelector("#total-progress").style.opacity = "0"

    myDropzone.on 'queuecomplete', =>
      @trigger 'uploadComplete'

    # Setup the buttons for all transfers
    # The "add files" button doesn't need to be setup because the config
    # `clickable` has already been specified.
    @$("#actions .start").on 'click', ->
      myDropzone.enqueueFiles myDropzone.getFilesWithStatus(Dropzone.ADDED)
    @$("#actions .cancel").on 'click', ->
      myDropzone.removeAllFiles true

  destroy: (e) ->
    target = $(e.target)
    return unless confirm('Datei wirklich löschen?')
    @trigger 'destroy', target.attr('data-id')

  ###
  Select a file.
  ###
  select: (e) ->
    $(e.target).closest('tr').addClass 'active'
    @href = $(e.target).attr('data-href')
    @text = $(e.target).text()
    @file = $(e.target).attr('data-id')
    @tab = 'current'
    @render()
    @trigger 'selected'
)

view = new Editor(
  el: $modal.get(0)
  model: new Files()
)

###
Export the editor.
###
INPLACE.register 'file', class

  ###
  Construct the editor
  ###
  constructor: (@el) ->
    @view = view
    @handlers = {}
    field = $(@el).attr('id')
    view.on 'selected', =>
      return unless view.field is field
      $(@el).attr 'href', view.href
      $(@el).text view.text
      @trigger 'change:href', view.href
      @trigger 'change:text', view.text
    view.on 'change:text', (value) =>
      return unless view.field is field
      $(@el).text value
      @trigger 'change:text', view.text

    if @el.tagName is 'A'
      view.href = $(@el).attr('href')
      view.text = $(@el).text()
      setTimeout =>
        @trigger 'change:href', $(@el).attr('href')
        @trigger 'change:text', $(@el).text()
      , 0
    else
      return alert('Currently the file editor only supports A tags.')

    view.on 'uploadComplete', =>
      view.model.fetch().done =>
        view.render()

    view.on 'destroy', (id) =>
      $.ajax
        url: "/inplace/files/#{id}"
        type: 'DELETE'
        success: =>
          view.model.fetch().done =>
            view.render()
    @registerTrigger (e) =>
      e.preventDefault()
      view.model.fetch().done =>
        view.field = $(@el).attr('id')
        view.href = $(@el).attr('href')
        view.text = $(@el).text()
        view.render()
        $modal.modal()
      false

  on: (e, fn) ->
    @handlers[e] = [] unless @handlers[e]?
    @handlers[e].push(fn)

  trigger: (e, args ...) ->
    return unless @handlers[e]?
    for handler in @handlers[e]
      handler.apply this, args

  registerTrigger: (fn) ->
    el = $(@el)
    el.on 'click', (e) ->
      e.preventDefault()
      fn arguments...

  ###
  Return the values selected.
  ###
  value: ->
    if @el.tagName is 'A'
      href: $(@el).attr('href')
      text: $(@el).text()
