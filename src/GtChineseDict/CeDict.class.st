Class {
	#name : 'CeDict',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'traditionalIndex',
		'simplifiedIndex'
	],
	#classVars : [
		'Default'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'accessing' }
CeDict class >> dataDirectory [
	"I return the data directory relative to the repo."
	^ (IceRepository registeredRepositoryIncludingPackage: self package)
		ifNotNil: [ :repo | repo location / 'data' ]
		ifNil: [ 'data' asFileReference ]
]

{ #category : 'accessing' }
CeDict class >> default [
	^ Default ifNil: [ Default := self loadFromDefaultPath ]
]

{ #category : 'instance creation' }
CeDict class >> downloadDictionary [
	"I download CC-CEDICT to the data directory if not already present.
	Note: avoid GZipReadStream class>>#unzip:to:, whose `to:` argument is treated as a directory (it calls #ensureCreateDirectory and writes a child file inside it). Unzip explicitly to the desired file path instead."
	| dir file gzFile |
	dir := self dataDirectory.
	dir ensureCreateDirectory.
	file := dir / 'cedict.txt'.
	file isFile ifTrue: [ ^ file ].
	gzFile := dir / 'cedict.txt.gz'.
	ZnClient new
		url: 'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz';
		downloadTo: gzFile.
	gzFile binaryReadStreamDo: [ :rawStream |
		file binaryWriteStreamDo: [ :out |
			| unzipper buffer |
			unzipper := GZipReadStream on: rawStream.
			buffer := ByteArray new: 50000.
			[ unzipper atEnd ] whileFalse: [
				out nextPutAll: (unzipper nextInto: buffer) ] ] ].
	gzFile delete.
	^ file
]

{ #category : 'instance creation' }
CeDict class >> loadFrom: aFileReference [
	| dict |
	dict := self new.
	aFileReference readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [ | line |
			line := stream nextLine.
			(line isNotEmpty and: [ line first ~= $# ])
				ifTrue: [ dict addEntry: (CeDictEntry fromLine: line) ] ] ].
	^ dict
]

{ #category : 'accessing' }
CeDict class >> loadFromDefaultPath [
	"I load from the data directory, downloading if needed.
	Use #isFile (not #exists) so a stray directory at this path doesn't masquerade as the dictionary."
	| file |
	file := self dataDirectory / 'cedict.txt'.
	file isFile ifFalse: [ self downloadDictionary ].
	^ self loadFrom: file
]

{ #category : 'accessing' }
CeDict class >> reset [
	Default := nil
]

{ #category : 'adding' }
CeDict >> addEntry: aCeDictEntry [
	entries add: aCeDictEntry.
	(traditionalIndex at: aCeDictEntry traditional ifAbsentPut: [ OrderedCollection new ])
		add: aCeDictEntry.
	aCeDictEntry simplified = aCeDictEntry traditional ifFalse: [
		(simplifiedIndex at: aCeDictEntry simplified ifAbsentPut: [ OrderedCollection new ])
			add: aCeDictEntry ]
]

{ #category : 'gt-views' }
CeDict >> gtEntriesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Entries';
		priority: 5;
		items: [ entries ];
		column: 'Traditional'
			text: [ :e | (e toneColoredTraditional fontName: CeDictEntry cjkFontName)  fontSize: 20 ]
			width: 150;
		column: 'BoPoMoFo'
			text: [ :e | e bopomofo asRopedText fontName: CeDictEntry cjkFontName ]
			width: 120;
		column: 'Definition' text: [ :e | e definitions first ]
]

{ #category : 'gt-search' }
CeDict >> gtSearchEntriesFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Entries';
		priority: 10;
		wantsToDisplayOnEmptyQuery: false;
		items: [ entries ];
		itemName: [ :e | e traditional, ' [', e bopomofo, '] ', e definitions first ];
		previewObject: [ :e | self word: e traditional ];
		send: [ :e | self word: e traditional ];
		itemsLimit: 30;
		filterBySubstring
]

{ #category : 'initialization' }
CeDict >> initialize [
	entries := OrderedCollection new.
	traditionalIndex := Dictionary new.
	simplifiedIndex := Dictionary new
]

{ #category : 'segmentation' }
CeDict >> cjkTokenAt: pos in: aString [
	"Greedy longest-match against the dictionary, length maxWordLength down to 1. Falls back to a single unknown CJK character when no prefix matches."
	self maxWordLength to: 1 by: -1 do: [ :len |
		| end candidate matches |
		end := pos + len - 1.
		end > aString size ifFalse: [
			candidate := aString copyFrom: pos to: end.
			matches := self lookup: candidate.
			matches ifNotEmpty: [
				^ TraditionalWord text: candidate entries: matches dict: self ] ] ].
	^ TraditionalWord text: (aString at: pos) asString entries: #() dict: self
]

{ #category : 'segmentation' }
CeDict class >> isCJK: aChar [
	"I return true if aChar is in one of the Unicode CJK ranges used for segmentation. Ranges included:
	- U+4E00..U+9FFF  CJK Unified Ideographs (most common; fast path)
	- U+3400..U+4DBF  CJK Extension A
	- U+F900..U+FAFF  CJK Compatibility Ideographs
	- U+3000..U+303F  CJK Symbols and Punctuation (covers 。、， and friends)
	- U+20000..U+2FA1F CJK Extensions B-F plus Compatibility Ideographs Supplement
	- U+30000..U+323AF CJK Extensions G and H (Tertiary Ideographic Plane)
	Full-width Latin forms (U+FF00..U+FFEF) are NOT included — they're semantically Latin even when rendered wide, and pulling them in would split full-width English words into per-letter tokens via the dict-lookup path. Chinese-style full-width punctuation (！？, at U+FF01/U+FF1F) is also excluded for the same reason; the ideographic punctuation in U+3000..U+303F handles the common cases."
	| code |
	code := aChar charCode.
	(code between: 16r4E00 and: 16r9FFF) ifTrue: [ ^ true ].
	(code between: 16r3400 and: 16r4DBF) ifTrue: [ ^ true ].
	(code between: 16rF900 and: 16rFAFF) ifTrue: [ ^ true ].
	(code between: 16r3000 and: 16r303F) ifTrue: [ ^ true ].
	(code between: 16r20000 and: 16r2FA1F) ifTrue: [ ^ true ].
	(code between: 16r30000 and: 16r323AF) ifTrue: [ ^ true ].
	^ false
]

{ #category : 'segmentation' }
CeDict >> nonCjkRunAt: pos in: aString [
	"Consume a maximal run of non-CJK non-separator chars and return one EnglishWord for the whole run. Skipping dict lookup here also sidesteps CC-CEDICT's stray Latin-letter entries (e.g. a single 'w' that would otherwise come back 'known' and split an English word into letter-chips)."
	| end |
	end := pos.
	[ end <= aString size
		and: [ ((aString at: end) isSeparator) not
		and: [ (self class isCJK: (aString at: end)) not ] ] ] whileTrue: [ end := end + 1 ].
	^ EnglishWord text: (aString copyFrom: pos to: end - 1) dict: self
]

{ #category : 'segmentation' }
CeDict >> separatorTokenAt: pos in: aString [
	"Separators stay per-char so the reader's row builder can see each line break and render each space/tab as its own font-width spacer. CR+LF is consumed as a single 2-character LineBreakToken so consecutive-newline detection doesn't count it as two breaks. Lone CR and lone LF also become LineBreakTokens; every other separator becomes a WhitespaceToken."
	| char |
	char := aString at: pos.
	(char = Character cr
		and: [ pos < aString size
		and: [ (aString at: pos + 1) = Character lf ] ])
			ifTrue: [ ^ LineBreakToken text: String crlf ].
	(char = Character cr or: [ char = Character lf ])
		ifTrue: [ ^ LineBreakToken text: char asString ].
	^ WhitespaceToken text: char asString
]

{ #category : 'segmentation' }
CeDict >> tokenAt: pos in: aString [
	"I dispatch to the per-class token helper based on what kind of character is at pos: separator → single-char whitespace token; CJK → greedy dict match; otherwise → non-CJK run."
	| char |
	char := aString at: pos.
	char isSeparator ifTrue: [ ^ self separatorTokenAt: pos in: aString ].
	(self class isCJK: char) ifTrue: [ ^ self cjkTokenAt: pos in: aString ].
	^ self nonCjkRunAt: pos in: aString
]

{ #category : 'accessing' }
CeDict >> lookup: aString [
	"I return all entries matching aString as either traditional or simplified Chinese."
	simplifiedIndex ifNil: [ self rebuildSimplifiedIndex ].
	^ (traditionalIndex at: aString ifAbsent: [ #() ])
		, (simplifiedIndex at: aString ifAbsent: [ #() ])
]

{ #category : 'accessing' }
CeDict >> maxWordLength [
	^ 6
]

{ #category : 'printing' }
CeDict >> printOn: aStream [
	aStream
		nextPutAll: 'CeDict(';
		print: entries size;
		nextPutAll: ' entries)'
]

{ #category : 'initialization' }
CeDict >> rebuildSimplifiedIndex [
	"I (re)build the simplified-form index from existing entries. Used to migrate dictionaries loaded before the simplified index existed, and called lazily by lookup: when the index is nil."
	simplifiedIndex := Dictionary new.
	entries do: [ :e |
		e simplified = e traditional ifFalse: [
			(simplifiedIndex at: e simplified ifAbsentPut: [ OrderedCollection new ])
				add: e ] ]
]

{ #category : 'segmentation' }
CeDict >> segment: aString [
	"I walk aString left-to-right, emitting one token per position via tokenAt:in: and advancing by its length. Tokens come in three shapes: single-char whitespace (plus CRLF collapsed to one), CJK greedy-matched dict words or single unknown CJK chars, and maximal non-CJK non-whitespace runs."
	| result pos |
	result := OrderedCollection new.
	pos := 1.
	[ pos <= aString size ] whileTrue: [
		| token |
		token := self tokenAt: pos in: aString.
		result add: token.
		pos := pos + token text size ].
	^ result
]

{ #category : 'accessing' }
CeDict >> size [
	^ entries size
]

{ #category : 'accessing' }
CeDict >> word: aString [
	"I return a ChineseWord for a string."
	^ TraditionalWord text: aString entries: (self lookup: aString) dict: self
]
