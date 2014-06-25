Range = require("xpath-range").Range

class TextQuoteSelectorCreator

  name: "TextQuoteSelector from text range (either raw or magic)"

  # Do some normalization to get a "canonical" form of a string.
  # Used to even out some browser differences.
  _normalizeString: (string) -> string.replace /\s{2,}/g, " "

  describe: (selection) ->
    return [] unless selection.type in ["magic text range", "raw text range"]

    unless selection.range?
      throw new Error "Tried to create a TextQuoteSelector from a null range!"

    r = if selection.type is "raw text range"
      # TODO: we should be able to do this without converting to magic range.
      new Range.BrowserRange(selection.range).normalize()
    else
      selection.range

    rangeStart = selection.range.startContainer
    unless rangeStart?
      throw new Error "Called getTextQuoteSelector(range) on a range with no valid start."
    rangeEnd = selection.range.endContainer
    unless rangeEnd?
      throw new Error "Called getTextQuoteSelector(range) on a range with no valid end."

    state = selection.data?.dtmState
    # Do we have d-t-m catabilitities and state?
    if state?.getStartInfoForNode?
      # Calculate the quote and context using DTM

      #console.log "Start info:", state.getInfoForNode rangeStart

      startOffset = (state.getStartInfoForNode rangeStart).start
      endOffset = (state.getEndInfoForNode rangeEnd).end
      quote = state.getCorpus()[ startOffset ... endOffset ].trim()
      [prefix, suffix] = state.getContextForCharRange startOffset, endOffset

      type: "TextQuoteSelector"
      prefix: prefix
      exact: quote
      suffix: suffix

    else
      # Get the quote directly from the range

      type: "TextQuoteSelector"
      exact: @_normalizeString r.text().trim()

module.exports =
  creator: TextQuoteSelectorCreator
