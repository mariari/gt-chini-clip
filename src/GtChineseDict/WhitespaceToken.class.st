"
I am a segmented token for a single inline whitespace character (space, tab, or any other Character isSeparator that the segmenter emits one-at-a-time). The reader renders me as a BlTextElement with editorMeasurement, which gives me my natural font-advance width — not the 2 pixels BrLabel would strip a single-space label down to.

Line breaks (CR, LF, CRLF) are NOT instances of me. They are LineBreakToken, a sibling class, because rendering a line break as an inline spacer would be wrong. Keeping the two as sibling classes makes isSpacer and isLineBreak mutually exclusive by construction rather than by caller-test-ordering discipline.
"
Class {
	#name : 'WhitespaceToken',
	#superclass : 'SegmentedToken',
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'testing' }
WhitespaceToken >> isSpacer [
	^ true
]
