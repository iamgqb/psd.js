module.exports = 
  parseRaw: ->
    chInfoLength = @chInfo.length
    realLength = @chanPos + chInfoLength - 2
    for i in [@chanPos...realLength]
      @channelData[i] = @file.readByte()

    @chanPos += chInfoLength - 2