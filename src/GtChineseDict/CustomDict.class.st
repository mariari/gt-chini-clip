Class {
	#name : 'CustomDict',
	#superclass : 'CeDict',
	#instVars : [
		'name',
		'baseDict',
		'maxLen'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'accessing' }
CustomDict class >> allNames [
	"I list available custom dict names from files in the custom directory."
	| dir |
	dir := self customDirectory.
	dir exists ifFalse: [ ^ #() ].
	^ ((dir files select: [ :f | f extension = 'txt' ])
		collect: [ :f | f basenameWithoutExtension ]) asArray
]

{ #category : 'accessing' }
CustomDict class >> customDirectory [
	"I return the directory holding custom dictionaries, one file per name."
	^ CeDict dataDirectory / 'custom'
]

{ #category : 'instance creation' }
CustomDict class >> named: aString [
	"I return a custom dict with aString as its name, layered on top of the default CC-CEDICT. If a file exists at data/custom/{name}.txt, I load it; otherwise I start empty."
	^ self new
		name: aString;
		baseDict: CeDict default;
		loadEntries;
		yourself
]

{ #category : 'adding' }
CustomDict >> addEntry: aCeDictEntry [
	"I track the longest entry length for segmentation alongside the inherited bookkeeping."
	super addEntry: aCeDictEntry.
	maxLen := (maxLen ifNil: [ 0 ]) max: aCeDictEntry traditional size
]

{ #category : 'adding' }
CustomDict >> addLine: aString [
	"I parse a CC-CEDICT line, add the entry, and persist to disk."
	self addEntry: (CeDictEntry fromLine: aString).
	self save
]

{ #category : 'accessing' }
CustomDict >> baseDict [
	^ baseDict
]

{ #category : 'accessing' }
CustomDict >> baseDict: aDict [
	baseDict := aDict
]

{ #category : 'accessing' }
CustomDict >> file [
	"I return the path to my custom file."
	^ self class customDirectory / (name , '.txt')
]

{ #category : 'segmentation' }
CustomDict >> firstOwnStartAfter: pos in: aString [
	"I return the smallest p > pos at which one of my own entries starts (matching either traditional or simplified), within a window of my longest entry. nil if no own entry starts in the window."
	| maxOwn limit |
	maxOwn := maxLen ifNil: [ ^ nil ].
	maxOwn = 0 ifTrue: [ ^ nil ].
	limit := (pos + maxOwn) min: aString size.
	(pos + 1) to: limit do: [ :p |
		1 to: (maxOwn min: (aString size - p + 1)) do: [ :len |
			(super lookup: (aString copyFrom: p to: p + len - 1)) isEmpty
				ifFalse: [ ^ p ] ] ].
	^ nil
]

{ #category : 'gt-views' }
CustomDict >> gtEntriesFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Custom';
		priority: 1;
		items: [ entries ];
		column: 'Traditional'
			text: [ :e | (e toneColoredTraditional fontName: CeDictEntry cjkFontName) fontSize: 20 ]
			width: 150;
		column: 'BoPoMoFo'
			text: [ :e | e bopomofo asRopedText fontName: CeDictEntry cjkFontName ]
			width: 120;
		column: 'Definition' text: [ :e | '; ' join: e definitions ]
]

{ #category : 'persistence' }
CustomDict >> loadEntries [
	"I load entries from my file if it exists. Lines starting with # are comments."
	| f |
	f := self file.
	f exists ifFalse: [ ^ self ].
	f readStreamDo: [ :stream |
		[ stream atEnd ] whileFalse: [ | line |
			line := stream nextLine.
			(line isNotEmpty and: [ line first ~= $# ])
				ifTrue: [ self addEntry: (CeDictEntry fromLine: line) ] ] ]
]

{ #category : 'segmentation' }
CustomDict >> cjkTokenAt: pos in: aString [
	"I prefer my own entries: take the longest custom match starting here. Only fall back to a base-dict match if no custom match starts here, and only if the base match wouldn't shadow a custom entry that begins later in the lookahead window. Overrides CeDict>>cjkTokenAt:in: to preserve the lookahead-respecting behavior that CustomDict had prior to the segmenter dispatch refactor."
	| ownMax endCap |
	ownMax := self ownLongestMatchAt: pos in: aString.
	ownMax ifNotNil: [ ^ ownMax ].
	endCap := self firstOwnStartAfter: pos in: aString.
	self maxWordLength to: 1 by: -1 do: [ :len |
		| end |
		end := pos + len - 1.
		(end <= aString size and: [ endCap isNil or: [ end < endCap ] ]) ifTrue: [
			| candidate matches |
			candidate := aString copyFrom: pos to: end.
			matches := baseDict ifNil: [ #() ] ifNotNil: [ baseDict lookup: candidate ].
			matches ifNotEmpty: [
				^ ChineseWord text: candidate entries: matches dict: self ] ] ].
	^ ChineseWord text: (aString at: pos) asString entries: #() dict: self
]

{ #category : 'accessing' }
CustomDict >> lookup: aString [
	"I return my own entries first (matching either traditional or simplified), then fall back to the base dict."
	^ (super lookup: aString)
		, (baseDict ifNil: [ #() ] ifNotNil: [ baseDict lookup: aString ])
]

{ #category : 'accessing' }
CustomDict >> maxWordLength [
	"I take the longer of my own longest entry and the base dict's max."
	^ (maxLen ifNil: [ 0 ])
		max: (baseDict ifNil: [ 0 ] ifNotNil: [ baseDict maxWordLength ])
]

{ #category : 'accessing' }
CustomDict >> name [
	^ name
]

{ #category : 'accessing' }
CustomDict >> name: aString [
	name := aString
]

{ #category : 'segmentation' }
CustomDict >> ownLongestMatchAt: pos in: aString [
	"I return the longest match starting at pos that comes from my own entries (not the base dict), or nil. Checks both traditional and simplified."
	| maxOwn |
	maxOwn := maxLen ifNil: [ ^ nil ].
	maxOwn to: 1 by: -1 do: [ :len |
		| end |
		end := pos + len - 1.
		end <= aString size ifTrue: [
			| candidate matches |
			candidate := aString copyFrom: pos to: end.
			matches := super lookup: candidate.
			matches isEmpty ifFalse: [
				^ ChineseWord text: candidate entries: matches dict: self ] ] ].
	^ nil
]

{ #category : 'printing' }
CustomDict >> printOn: aStream [
	aStream
		nextPutAll: 'CustomDict(';
		nextPutAll: (name ifNil: [ '?' ]);
		nextPutAll: ': ';
		print: entries size;
		nextPutAll: ' entries)'
]

{ #category : 'persistence' }
CustomDict >> save [
	"I write all my entries back to my file in CC-CEDICT format."
	self class customDirectory ensureCreateDirectory.
	self file writeStreamDo: [ :stream |
		stream
			nextPutAll: '# Custom dictionary: ';
			nextPutAll: name;
			lf.
		entries do: [ :e |
			stream nextPutAll: e ceDictLine; lf ] ]
]
