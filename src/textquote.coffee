Range = require("xpath-range").Range

class SelectorCreator

  configure: (@manager) ->
    # Register function to get quote from this selector
    @manager._getQuoteForSelectors = (selectors) =>
      selector = @manager._findSelector selectors, "TextQuoteSelector"
      if selector?
        @manager._normalizeString selector.exact
      else
        null

  name: "TextQuoteSelector from text range (either raw or magic)"

  createSelectors: (segmentDescription) ->
    unless segmentDescription.type in ["magic text range", "raw text range"]
      return []

    unless segmentDescription.range?
      throw new Error "Tried to create a TextQuoteSelector from a null range!"

    r = if segmentDescription.type is "raw text range"
      # TODO: we should be able to do this without converting to magic range.
      new Range.BrowserRange(segmentDescription.range).normalize()
    else
      segmentDescription.range

    rangeStart = segmentDescription.range.startContainer
    unless rangeStart?
      throw new Error "Trying to create a TextQuoteSelector from
        a range with no valid start."
    rangeEnd = segmentDescription.range.endContainer
    unless rangeEnd?
      throw new Error "Trying to create a TextQuoteSelector from
        a range with no valid end."

    state = segmentDescription.data?.dtmState
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
      exact: @manager._normalizeString r.text().trim()

module.exports =
  creator: SelectorCreator
