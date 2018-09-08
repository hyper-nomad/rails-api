#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

jQuery ->
  _drop_zone = '#upload_images_box .drop_area'
  box = $('#upload_images_box')
  album = $('#album')

  sortUpdate = ->
    ids = album.find('li').map((i, e) -> $(e).data('id')).toArray()
    origin_id = album.find('li')[0].
    return if ids.length == 0
    $.ajax
      url: album.data('url')
      type: 'patch'
      dataType: 'script'
      data:
        model_type: album.data('model-type')
        id: album.data('model-id')
        ids: ids

  box.fileupload
    dataType: "script"
    url: box.data('url')
    add: (e, data) ->
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      if types.test(file.type) || types.test(file.name)
        data.context = $(tmpl("template-upload", file))
        $('#upload_images_box').append(data.context)
        data.submit()
      else
        alert("#{file.name} is not a gif, jpeg, or png image file")
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
    success: (e, data) ->
  

  album.sortable(update: sortUpdate)
  album.disableSelection()