Application.factory "ThemeLoader",
['$http', '$q', '$window', 'FileManager',
( $http,   $q,   $window,   FileManager) ->

  cache_prefix = "cache_http"

  themes_future = $q.defer()
  themes = $http.get("#{$window.API}/gallery.json")
  themes.success (data) ->
    for theme in data
      theme.color_type = if theme.light then 'light' else 'dark'
    themes_future.resolve(data)

  load = (theme) ->
    theme_promise = $q.defer()
    cached = FileManager.load(theme.url, cache_prefix)
    if cached
      theme_promise.resolve(cached)
    else
      http_get = $http.get("#{$window.API}/get_uri?uri=#{encodeURIComponent(theme.url)}")
      http_get.success (data) ->
        theme_promise.resolve(data)
        FileManager.save(theme.url, data, cache_prefix)
      http_get.error (data) ->
        theme_promise.reject("LOAD ERROR: Can not fetch color scheme")
    theme_promise.promise

  return {
    themes: themes_future.promise
    load: load
  }
]
