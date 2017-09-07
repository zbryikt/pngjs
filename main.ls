require! <[fs]>

assets = do
  header: "89504E470D0A1A0A"

Util = -> @buf = it; return @
Util.prototype = do
  buf: null
  pad: -> "0" * (2 - ("#it".length <? 2)) + it
  value: (i,len = 1) ->
    for j from 0 til len => ret = (ret or 0) * 256 + @buf[i + j]
    return ret
  ascii-at: (i) -> @ascii i, 1
  ascii: (i,c) -> [String.fromCharCode(@buf[j]) for j from i til i + c].join("")
  subbuf: (i, c) ->
    ret = Buffer.allocUnsafe(c)
    @buf.slice(i, i + c).copy(ret)
    return ret
  data-at: (i) -> @data i, 1
  data: (i,c) -> @raw.substring(i,i + c)
  hex-at: (i) -> @hex i, 1
  hex: (i,c) -> [@pad(@buf[j].toString(\16).toUpperCase!) for j from i til i + c].join("")

PNG = (input) ->
  @raw = fs.read-file-sync input, \binary
  @buf = Buffer.from(@raw, \binary)
  util = new Util @buf
  @length = @raw.length
  @chunk = []
  throw new Error("file header incorrect") if assets.header != util.hex(0, 8)
  idx = 8
  while idx < @length
    length = util.value idx, 4
    @chunk.push chunk = do
      length: length
      type: util.ascii idx + 4, 4
      data: util.subbuf idx + 8, length
      crc: util.hex idx + 8 + length, 4
    if chunk.type == \IEND =>
      console.log chunk.crc
    if chunk.type == \IHDR =>
      @header = ihdr = do
        width: chunk.data.readUInt32BE 0
        height: chunk.data.readUInt32BE 4
        bit-depth: chunk.data.readUInt8 8
        color-type: chunk.data.readUInt8 9
        compression-method: chunk.data.readUInt8 10
        filter-method: chunk.data.readUInt8 11
        interlace-method: chunk.data.readUInt8 12
    idx = idx + length + 12
  return @

PNG.prototype = do
  save: ->


console.log "[red.png]"
png = new PNG("red.png")

/*
console.log ""
console.log "[ok-src.png]"
png = new PNG("ok-src.png")

console.log ""
console.log "[ps3.png]"
png = new PNG("ps3.png")

console.log ""
console.log "[test.png]"
png = new PNG("test.png")

*/
