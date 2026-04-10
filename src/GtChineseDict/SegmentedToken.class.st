"
I am the abstract parent of all tokens produced by CeDict segmentation. Concrete subclasses are:

- ChineseWord — a dictionary-backed CJK token (one character or a greedy-matched multi-character run); may have empty entries when the CJK character is unknown to the dict.
- EnglishWord — a maximal run of non-CJK non-separator characters (Latin letters, digits, ASCII punctuation); not dictionary-backed yet.
- WhitespaceToken — a single separator character (space, tab, etc.) that renders as an inline font-width spacer in the reader.
- LineBreakToken — a CR, LF, or CRLF that causes the reader's row builder to flush the current row.

Predicates (isKnown, isLineBreak, isSpacer) default to false here and are overridden where the answer is true. That makes them mutually exclusive by type: a concrete instance satisfies at most one of the three, so callers can test in any order without worrying about precedence.

toneColoredText defaults to my plain text; ChineseWord overrides it to color each character by its pinyin tone. definition defaults to the empty string; dictionary-backed subclasses override to return an actual gloss.
"
Class {
	#name : 'SegmentedToken',
	#superclass : 'Object',
	#instVars : [
		'text'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'instance creation' }
SegmentedToken class >> text: aString [
	^ self new
		text: aString;
		yourself
]

{ #category : 'accessing' }
SegmentedToken >> definition [
	"I return a human-readable gloss for this token, or the empty string for tokens that have no dictionary backing. Subclasses override."
	^ ''
]

{ #category : 'testing' }
SegmentedToken >> isKnown [
	"I return true if this token has a dictionary-backed meaning. Default false; ChineseWord overrides based on its entries."
	^ false
]

{ #category : 'testing' }
SegmentedToken >> isLineBreak [
	"I return true only for line-break tokens (LineBreakToken). The reader uses this to flush the current chip row."
	^ false
]

{ #category : 'testing' }
SegmentedToken >> isSpacer [
	"I return true only for inline-whitespace tokens (WhitespaceToken). The reader uses this to emit a font-width spacer between chips. Line breaks deliberately return false here — they are handled separately via isLineBreak, which keeps the two cases mutually exclusive by type rather than by caller ordering."
	^ false
]

{ #category : 'printing' }
SegmentedToken >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		print: text;
		nextPut: $)
]

{ #category : 'accessing' }
SegmentedToken >> text [
	^ text
]

{ #category : 'accessing' }
SegmentedToken >> text: aString [
	text := aString
]

{ #category : 'accessing' }
SegmentedToken >> toneColoredSimplifiedText [
	"I return my text as a RopedText for simplified display. Default is plain (no tone coloring); ChineseWord overrides to color each character by its pinyin tone using the simplified character form."
	^ text asRopedText
]

{ #category : 'accessing' }
SegmentedToken >> toneColoredText [
	"I return my text as a RopedText for display. Default is plain (no tone coloring); ChineseWord overrides to color each character by its pinyin tone."
	^ text asRopedText
]
