window.initCloseDay = ->
  $('#close_days').each (i, clc) -> closeDayControl(clc)

$(document).ready ->
  initCloseDay()

closeDayControl = (e) ->
  container = $(e)
  key = container.find('.day_type')
  params = container.find('.day_param')

  conf = {
    every_week: 'day_type_val',
    first_week: 'day_type_val',
    second_week: 'day_type_val',
    third_week: 'day_type_val',
    fourth_week: 'day_type_val',
    fifth_week: 'day_type_val',
    biweekly: 'day_type_val',
    holiday: '',
    irregular: '',
    after_weekend: '',
    begin_and_end_of_year: '',
    the_day: 'one_day'
  }

  showByType = () ->
    input = conf[key.val()]
    params.each (i, e) ->
      param = $(e)
      if param.hasClass(input)
        param.show()
      else
        param.hide()

  key.change (e) -> showByType()
  showByType()

  $("#restaurant_close_day_one_day").datetimepicker
    lang: 'ja'
    timepicker: false
    format: 'Y/m/d'
    dayOfWeekStart: 1
