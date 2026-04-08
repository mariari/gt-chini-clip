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
				^ ChineseWord text: candidate entries: matches dict: self ] ] ].
	^ ChineseWord text: (aString at: pos) asString entries: #() dict: self
]

{ #category : 'segmentation' }
CeDict >> isCJK: aChar [
	"I return true if aChar is a CJK Unified Ideograph (U+4E00..U+9FFF). This is the same range used by ChineseClipboard>>containsChinese:. Extension A and friends are not included yet."
	^ aChar charCode between: 16r4E00 and: 16r9FFF
]

{ #category : 'segmentation' }
CeDict >> nonCjkRunAt: pos in: aString [
	"Consume a maximal run of non-CJK non-separator chars as one unknown token. Skipping dict lookup here also sidesteps CC-CEDICT's stray Latin-letter entries (e.g. a single 'w' that would otherwise come back 'known' and split an English word into letter-chips)."
	| end |
	end := pos.
	[ end <= aString size
		and: [ ((aString at: end) isSeparator) not
		and: [ (self isCJK: (aString at: end)) not ] ] ] whileTrue: [ end := end + 1 ].
	^ ChineseWord text: (aString copyFrom: pos to: end - 1) entries: #() dict: self
]

{ #category : 'segmentation' }
CeDict >> separatorTokenAt: pos in: aString [
	"Whitespace stays per-char so the reader can detect line breaks and render a font-width spacer per source character — except CRLF, which is consumed as a single 2-char token so consecutive-newline detection doesn't count it as two breaks."
	| char text |
	char := aString at: pos.
	text := (char = Character cr
		and: [ pos < aString size
		and: [ (aString at: pos + 1) = Character lf ] ])
			ifTrue: [ String crlf ]
			ifFalse: [ char asString ].
	^ ChineseWord text: text entries: #() dict: self
]

{ #category : 'segmentation' }
CeDict >> tokenAt: pos in: aString [
	"I dispatch to the per-class token helper based on what kind of character is at pos: separator → single-char whitespace token; CJK → greedy dict match; otherwise → non-CJK run."
	| char |
	char := aString at: pos.
	char isSeparator ifTrue: [ ^ self separatorTokenAt: pos in: aString ].
	(self isCJK: char) ifTrue: [ ^ self cjkTokenAt: pos in: aString ].
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
	^ ChineseWord text: aString entries: (self lookup: aString) dict: self
]
