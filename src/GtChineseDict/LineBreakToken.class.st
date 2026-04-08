"
I am a segmented token for a line break in the source text. My text is one of String cr, String lf, or String crlf — the segmenter emits CRLF as a single two-character LineBreakToken so consecutive-newline detection in the reader doesn't see it as two breaks.

The reader recognizes me via isLineBreak and flushes the current row when it encounters me; a second LineBreakToken in a row (with nothing between) produces a blank row, preserving paragraph gaps from the source.

I am a sibling of WhitespaceToken under SegmentedToken, NOT a subclass of it. Inline whitespace (isSpacer) and line breaks (isLineBreak) are mutually exclusive concepts from the reader's perspective — the first renders as a spacer between chips, the second flushes a row — so making them disjoint classes removes a documentation-level contract about test ordering.
"
Class {
	#name : 'LineBreakToken',
	#superclass : 'SegmentedToken',
	#instVars : [ ],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'testing' }
LineBreakToken >> isLineBreak [
	^ true
]
