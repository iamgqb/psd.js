Image = require './image.coffee'
ImageFormat = require './image_format.coffee'

module.exports = class ChannelImage extends Image
  @includes ImageFormat.LayerRAW
  @includes ImageFormat.LayerRLE

  constructor: (layer, @file, @header) ->

    @layer = layer

    # width() heig.
    @width = @widthOverride
    @height = @heightOverride

    super(@file, @header)

    @channelsInfo = @layer.channelsInfo
    
    @hasMask = false
    for chan in @channelsInfo
      if chan.id == -2
        @hasMask = true
        break

    @opacity = @layer.opacity / 255.0
    @maskData = []

  skip: ->
    for i in @channelsInfo
      @file.seek i.length, true

  parse: ->

    @chanPos = 0

    for chInfo in @channelsInfo
      console.log(chInfo)
      @chInfo = chInfo 
      if chInfo.length <= 0
        @parseCompression()
        continue

      if chInfo.id < -1
        @layer.width = @layer.mask.width
        @layer.height = @layer.mask.height
      # else 
      #   @layer.handle.width = @layer.width
      #   @layer.handle.height = @layer.height

      @length = @width() * @height()

      start = @file.tell()
      @parseImageData()
      end = @file.tell()
      if end != start + chInfo.length
        console.log('位置不匹配')

    if @channelData.length != (@length*@channelsInfo.length)
      console.log('channelData长度不匹配')

    @parseUserMask()
    @processImageData()

  parseImageData: ->
    @compression = @parseCompression()

    switch @compression
      when 0 then @parseRaw()
      when 1 then @parseRLE()
      when 2, 3 then @parseZip()
      else @file.seek(@endPos)

  parseUserMask: ->
    return unless hasMask?

    maskId = -2

    for o, i in channelsInfo
      if o.id == maskId
        channel = o
        index = i
        break
    return if channel?

    start = @channelLength * index
    length = @layer.mask.width * @layer.mask.height

    # @maskData = @channelData for i in [start...start+length]

  widthOverride: ->
    @layer.width

  heightOverride: ->
    @layer.height