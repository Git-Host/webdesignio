# Inplace

## Api

### .page(name, view)

This method registers a new cms page.

*Example:*

    inplace = require('inplace')

    app.get '/mypage', inplace.page('mypage', 'mypage_view')

### req.object()

### req.objects()

### res.renderPage()
