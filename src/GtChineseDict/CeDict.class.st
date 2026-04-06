Class {
	#name : 'CeDict',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'traditionalIndex'
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
	"I download CC-CEDICT to the data directory if not already present."
	| dir file |
	dir := self dataDirectory.
	dir ensureCreateDirectory.
	file := dir / 'cedict.txt'.
	file exists ifTrue: [ ^ file ].
	ZnClient new
		url: 'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz';
		downloadTo: dir / 'cedict.txt.gz'.
	GZipReadStream unzip: (dir / 'cedict.txt.gz') to: file.
	(dir / 'cedict.txt.gz') delete.
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
	"I load from the data directory, downloading if needed."
	| file |
	file := self dataDirectory / 'cedict.txt'.
	file exists ifFalse: [ self downloadDictionary ].
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
		add: aCeDictEntry
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
		previewObject: [ :e | e ];
		itemsLimit: 30;
		filterBySubstring
]

{ #category : 'initialization' }
CeDict >> initialize [
	entries := OrderedCollection new.
	traditionalIndex := Dictionary new
]

{ #category : 'segmentation' }
CeDict >> longestMatchAt: pos in: aString [
	"I return the longest matching ChineseWord starting at pos, or a single unknown character."
	self maxWordLength to: 1 by: -1 do: [ :len |
		| end candidate matches |
		end := pos + len - 1.
		end > aString size ifFalse: [
			candidate := aString copyFrom: pos to: end.
			matches := self lookup: candidate.
			matches ifNotEmpty: [
				^ ChineseWord text: candidate entries: matches ] ] ].
	^ ChineseWord text: (aString at: pos) asString entries: #()
]

{ #category : 'accessing' }
CeDict >> lookup: aString [
	"I return all entries matching a traditional Chinese string."
	^ traditionalIndex at: aString ifAbsent: [ #() ]
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

{ #category : 'segmentation' }
CeDict >> segment: aString [
	"I segment Chinese text using greedy longest-match."
	| result pos |
	result := OrderedCollection new.
	pos := 1.
	[ pos <= aString size ] whileTrue: [
		| word |
		word := self longestMatchAt: pos in: aString.
		result add: word.
		pos := pos + word text size ].
	^ result
]

{ #category : 'accessing' }
CeDict >> size [
	^ entries size
]
