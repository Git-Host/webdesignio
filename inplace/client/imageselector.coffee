modal = require('./imageselector/modal.jade')

$modal = null
$modal = $('<div id="cms-modal" class="fade modal"></div>')
$modal.css 'z-index', '99999999999'
$modal.appendTo 'body'

Files = Backbone.Collection.extend(
  url: '/inplace/images'
)

###
Backbone view to synchronise the chooser with the image within the DOM.
###
Editor = Backbone.View.extend(
  events:
    'click span.fa-stack.fa-lg[data-id]': 'destroy'
    'click img[data-id]': 'select'
    'shown.bs.tab a[data-toggle="pill"]': 'tabChange'
    'keyup input[type="text"]': 'altChange'

  altChange: (e) ->
    @alt = $(e.target).val()
    @trigger 'change:alt', @alt

  tabChange: (e) ->
    @tab = $(e.target).attr('href').slice(1)

  render: ->
    @$el.html modal(this)
    @$('img.preview').attr 'src', @src
    @$('input[type="text"]').val @alt
    @renderDropzone()

  renderDropzone: ->
    previewNode = @$('#template').get(0)
    previewNode.id = ""
    previewTemplate = previewNode.parentNode.innerHTML
    previewNode.parentNode.removeChild previewNode
    myDropzone = new Dropzone(@$('.modal-content').get(0),
      url: "/inplace/images" # Set the url
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
    target = $(e.target).closest('span') unless target.prop('tagName') is 'SPAN'
    return unless confirm('Datei wirklich löschen?')
    @trigger 'destroy', target.attr('data-id')

  ###
  Select an image.
  ###
  select: (e) ->
    $(e.target).addClass 'active'
    @src = $(e.target).attr('src')
    @alt = $(e.target).attr('alt')
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
INPLACE.register 'image', class

  ###
  Construct the editor
  ###
  constructor: (@el) ->
    @view = view
    @handlers = {}
    field = $(@el).attr('id')
    view.on 'selected', =>
      return unless view.field is field
      $(@el).attr 'src', view.src
      $(@el).attr 'alt', view.alt
      @trigger 'change:src', view.src
      @trigger 'change:alt', view.alt
    view.on 'change:alt', (value) =>
      return unless view.field is field
      $(@el).attr 'alt', value
      @trigger 'change:alt', view.alt

    if @el.tagName is 'IMG'
      view.src = $(@el).attr('src')
      view.alt = $(@el).attr('alt')
      setTimeout =>
        @trigger 'change:src', $(@el).attr('src')
        @trigger 'change:alt', $(@el).attr('alt')
      , 0
    else
      return alert('Currently the image editor only supports IMG tags.')

    view.on 'uploadComplete', =>
      view.model.fetch().done =>
        view.render()

    view.on 'destroy', (id) =>
      $.ajax
        url: "/inplace/images/#{id}"
        type: 'DELETE'
        success: =>
          view.model.fetch().done =>
            view.render()
    @registerTrigger (e) =>
      e.preventDefault()
      view.model.fetch().done =>
        view.field = $(@el).attr('id')
        view.src = $(@el).attr('src')
        view.alt = $(@el).attr('alt')
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
    $(@el).on 'click', fn

  ###
  Return the values selected.
  ###
  value: ->
    if @el.tagName is 'IMG'
      src: $(@el).attr('src')
      alt: $(@el).attr('alt')
