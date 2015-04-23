$('#domains')
  .tagEditor(
    onChange: (field, editor, tags) ->
      $('input[type="hidden"][name="domains"]').val JSON.stringify(tags)
  )

users = JSON.parse($('#users-data').html())

User = Backbone.Model.extend(
  idAttribute: '_id'
)

Users = Backbone.Collection.extend(
  model: User
)

View = Backbone.View.extend(
  el: '#users'
  events:
    'typeahead:selected #users-add': 'selected'
    'click .close': 'remove'

  initialize: ->
    @listenTo @model, 'change add remove reset sort', @render

  render: ->
    unless @typeahead
      @typeahead = $('#users-add').typeahead(
        minLength: 0
        highlight: true
      ,
        name: 'user-dataset'
        displayKey: 'email'
        templates:
          suggestion: require('./websites_edit/tt_suggestion.jade')
        source: (query, cb) ->
          res = _.filter(users, (user) ->
            return true if user.email.indexOf(query) isnt -1
            return true if user.name and user.name.indexOf(query) isnt -1
            false
          )
          cb(res or [])
      )

    $('#users-list').html(
      require('./websites_edit/users_list.jade')(users: @model.toJSON())
    )

  selected: (e, suggestion) ->
    @typeahead.typeahead 'val', ''
    inst = @model.get(suggestion._id)
    return if inst?
    @model.push suggestion

  remove: (e) ->
    id = $(e.target).attr('data-id')
    user = @model.get(id)
    @model.remove user
    false
)

view = new View(model: new Users(
  JSON.parse $('#website-users-data').html()
))
view.render()
