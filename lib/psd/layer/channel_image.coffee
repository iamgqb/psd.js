ChannelImage = require '../channe_image.coffee'
LazyExecute = require '../lazy_execute.coffee'

module.exports =
  parseChannelImage: (layer) ->
    image = new ChannelImage(layer, @file, @header)
    @image =  new LazyExecute(image, @file)
      .now('skip')
      .later('parse')
      .ignore('width', 'height')
      .get()