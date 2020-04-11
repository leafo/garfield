lapis = require "lapis"

date = require "date"

first = date 1978, 6, 19

-- https://d1ejxu6vysztl5.cloudfront.net/comics/garfield/1978/1978-06-19.gif?v=1.1
strip_url = do
  prefix = "https://d1ejxu6vysztl5.cloudfront.net/comics/garfield"
  (d) ->
    -- TODO: should this check if date is invalid??
    "#{prefix}/#{d\fmt "%Y/%Y-%m-%d.gif"}?v=1.1 "

nearest_sunday = (d, direction=1) ->
  assert direction == 1 or direction == -1, "invalid direction"

  d = d\copy!
  while d\getweekday! != 1
    d\adddays direction

  d

class extends lapis.Application
  layout: require "views.layout"
  [home: "/"]: =>
    today = date!

    @html ->
      a href: @url_for("sundays"), "Sundays"

      h1 "Years"
      details ->
        summary "Select a year..."
        ul ->
          for y=first\getyear!, today\getyear!
            li ->
              a href: @url_for("year", year: y), y

      h1 "Most recent"
      d = today

      for i=1,20
        d = d\copy!\adddays -1
        div ->
          h3 d\fmt "%Y-%m-%d (%A)"
          img src: strip_url d

  [year: "/browse/:year"]: =>
    year = assert tonumber(@params.year), "invalid year"

    first_month = date first\getyear!, first\getmonth!, 1
    today = date!

    @html ->
      -- list all the months
      h1 "#{year} - Months"

      p ->
        a {
          href: @url_for "home"
        }, "Return home"

      ul ->
        for i=1,12
          m = date year, i, 1
          continue if m < first_month
          continue if m > today

          li ->
            a {
              href: @url_for "month", {
                year: year
                month: m\getmonth!
              }
            }, m\fmt "%Y-%m"

  [month: "/browse/:year/:month"]: =>
    year = assert tonumber(@params.year), "invalid year"
    month = assert tonumber(@params.month), "invalid month"

    start = date year, month, 1
    stop = date(year, month, 1)\addmonths(1)

    current = start\copy!

    @html ->
      pagination = ->
        p ->
          next_month = start\copy!\addmonths 1
          prev_month = start\copy!\addmonths -1

          a {
            href: @url_for "month", {
              year: prev_month\getyear!
              month: prev_month\getmonth!
            }
          }, "Previous month"

          text " - "

          a {
            href: @url_for "month", {
              year: next_month\getyear!
              month: next_month\getmonth!
            }
          }, "Next month"

          text " - "

          a {
            href: @url_for "year", year: current\getyear!
          }, "Return to year"

      h1 start\fmt "%Y-%m"
      pagination!
      while true
        div class: "strip", ->
          h3 current\fmt "%Y-%m-%d (%A)"
          img src: strip_url current

        current\adddays 1
        break unless current < stop
      pagination!


  [sundays: "/sundays"]: =>
    start = if type(@params.from) == "string"
      y, m, d = @params.from\match "(%d%d%d%d)%-(%d+)%-(%d+)"
      if y
        date y, m, d

    unless start
      start = first

    current = nearest_sunday start

    @html ->
      pagination = ->
        a {
          href: @url_for "sundays", nil, from: current\fmt "%Y-%m-%d"
        }, "Next page →"

      h1 "Sundays"
      pagination!
      for i=1,20
        div class: "strip", ->
          h3 current\fmt "%Y-%m-%d (%A)"
          img src: strip_url current

        current\adddays 7

      pagination!

