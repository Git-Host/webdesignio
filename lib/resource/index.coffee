
###
Tiny module to ease the registration of resources.
###
module.exports = (app, name, plural, controllers) ->
  actions = [
    'list'
    'new'
    'show'
    'edit'
    'create'
    'update'
    'updatePartial'
    'destroy'
  ]

  if typeof plural is 'object'
    controllers = plural
    plural = "#{name}s"

  route = (method, path, controller) ->
    app[method] "/#{plural}#{path}", controller

  for action in actions
    if controllers[action]?
      switch action
        when 'list' then route 'get', '/', controllers[action]
        when 'new' then route 'get', '/new', controllers[action]
        when 'show' then route 'get', "/:#{name}", controllers[action]
        when 'edit' then route 'get', "/:#{name}/edit", controllers[action]
        when 'create' then route 'post', '/', controllers[action]
        when 'update' then route 'put', "/:#{name}", controllers[action]
        when 'updatePartial'
          route 'patch', "/:#{name}", controllers[action]
        when 'destroy' then route 'delete', "/:#{name}", controllers[action]
