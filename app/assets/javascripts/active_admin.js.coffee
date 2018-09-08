#= require active_admin/base
#= require active_admin/jquery.datetimepicker.js
#= require active_admin/map
#= require active_admin/fileupload
#= require active_admin/form
#= require active_admin/close_day
#= require select2
#= require select2_locale_ja
jQuery ->
  $(document).ready ->
    # レストラン指定の無いメニュー一覧ではメニューの追加ボタンを表示しない（url直書きしても一覧にredirectしている）
    $('.action_items').remove() if document.location.href.match(/\/admin\/dishes$/)