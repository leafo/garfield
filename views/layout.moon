import Widget from require "lapis.html"

class Layout extends Widget
  content: =>
     html_5 {
      lang: "en"
    }, ->
      head ->
        meta charset: "UTF-8"
        title "Garfield"

      body ->
        @content_for "inner"

