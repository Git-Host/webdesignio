_ = require('highland')
require './vendor/contact'

###
# Snippet copied from angle.
###
jQuery(document).ready ($) ->
  # bind submit handler to form

  showInputMessage = (message, status) ->
    $('#messages').empty()
    $('#messages').append '<div class="alert alert-' + status + '" role="alert">' + message.message + '</div>'

  $('#contactForm').on 'submit', (e) ->
    $form = $(this)
    $submitButton = $form.find('button')
    # prevent native submit
    e.preventDefault()
    # submit the form
    $form.ajaxSubmit
      url: '/messages'
      type: 'post'
      dataType: 'json'
      beforeSubmit: ->
        # disable submit button
        $submitButton.attr 'disabled', 'disabled'
        # add spinner icon
        $submitButton.find('i').removeClass().addClass 'fa fa-circle-o-notch fa-spin'
      success: (response, status, xhr, form) ->
        if response.status == 'ok'
          # mail sent ok - display sent message
          for msg of response.messages
            showInputMessage response.messages[msg], 'success'
          # clear the form
          form[0].reset()
        else
          for error of response.messages
            showInputMessage response.messages[error], 'danger'
        # make button active
        $submitButton.removeAttr 'disabled'
        # add back icon
        $submitButton.find('i').removeClass().addClass 'fa fa-envelope'
      error: (response) ->
        for error of response.messages
          showInputMessage response.messages[error], 'danger'
        # make button active
        $submitButton.removeAttr 'disabled'
        # add back icon
        $submitButton.find('i').removeClass().addClass 'fa fa-envelope'
    false

initialized = false
CKEDITOR.disableAutoInline = true
bodyEditor = CKEDITOR.inline('editor-demo')

###
# Check if `el` is currently within the viewport.
###
elementInViewport = (el) ->
  top = el.offsetTop
  left = el.offsetLeft
  width = el.offsetWidth
  height = el.offsetHeight
  while el.offsetParent
    el = el.offsetParent
    top += el.offsetTop
    left += el.offsetLeft
  top >= window.pageYOffset and left >= window.pageXOffset and top + height <= window.pageYOffset + window.innerHeight and left + width <= window.pageXOffset + window.innerWidth

###
# Type the text into the editor word by word.
###
typeText = (text) ->
  data = $('#editor-demo-head').text()
  data += text
  $('#editor-demo-head').html data
  el = document.getElementById('editor-demo-head')
  range = document.createRange()
  sel = window.getSelection()
  range.setStart el.childNodes[0], data.length
  range.collapse true
  sel.removeAllRanges()
  sel.addRange range

###
# Imitate typing like a human being would.
###
humanType = (text, done) ->
  _ text.split(' ')
    .flatMap _.wrapCallback (word, next) ->
      setTimeout ->
        typeText " #{word}"
        next()
      , 200
    .collect()
    .pull (err) ->
      return alert(err) if err
      done()

$(window).on 'scroll resize', ->
  if elementInViewport($('#editor-demo-head').get(0))
    return if initialized
    bodyEditor.focus() if bodyEditor?
    humanType '''
      Unser innovatives CMS lässt Ihnen die Freiheit den Inhalt dort zu
      bearbeiten wo er auch wirklich steht. Probieren Sie\'s aus!
    ''', ->
      bodyEditor.focus()
    initialized = true
