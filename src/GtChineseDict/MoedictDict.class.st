Class {
	#name : 'MoedictDict',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'titleIndex'
	],
	#classVars : [
		'Default'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'accessing' }
MoedictDict class >> dataDirectory [
	"I return the data directory holding the moedict file."
	^ CeDict dataDirectory
]

{ #category : 'accessing' }
MoedictDict class >> default [
	^ Default ifNil: [ Default := self loadFromDefaultPath ]
]

{ #category : 'accessing' }
MoedictDict class >> dictionaryFile [
	^ self dataDirectory / 'moedict.json'
]

{ #category : 'instance creation' }
MoedictDict class >> downloadDictionary [
	"I download the MOEDICT bulk JSON to the data directory if not already present. Source: g0v/moedict-data on GitHub. ~75 MB."
	| dir file |
	dir := self dataDirectory.
	dir ensureCreateDirectory.
	file := self dictionaryFile.
	file exists ifTrue: [ ^ file ].
	ZnClient new
		url: 'https://raw.githubusercontent.com/g0v/moedict-data/master/dict-revised_bkup.json';
		downloadTo: file.
	^ file
]

{ #category : 'instance creation' }
MoedictDict class >> loadFrom: aFileReference [
	"I parse the MOEDICT bulk JSON (an array of entry dicts) and index them by title."
	| dict raw |
	dict := self new.
	raw := aFileReference readStreamDo: [ :s | (NeoJSONReader on: s) next ].
	raw do: [ :entryData | dict addEntry: (MoedictEntry on: entryData) ].
	^ dict
]

{ #category : 'instance creation' }
MoedictDict class >> loadFromDefaultPath [
	"I load from the data directory, downloading if needed."
	| file |
	file := self dictionaryFile.
	file exists ifFalse: [ self downloadDictionary ].
	^ self loadFrom: file
]

{ #category : 'accessing' }
MoedictDict class >> reset [
	Default := nil
]

{ #category : 'adding' }
MoedictDict >> addEntry: aMoedictEntry [
	entries add: aMoedictEntry.
	titleIndex at: aMoedictEntry title put: aMoedictEntry
]

{ #category : 'gt-views' }
MoedictDict >> gtEntriesFor: aView [
	<gtView>
	| cjkFont |
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'Entries';
		priority: 5;
		items: [ entries ];
		column: 'Title'
			text: [ :e | (e title asRopedText fontName: cjkFont) fontSize: 18 ]
			width: 150;
		column: 'Het'
			text: [ :e | e heteronyms size ]
			width: 50;
		column: 'Defs'
			text: [ :e | e allDefinitions size ]
			width: 50;
		column: 'POS'
			text: [ :e | (' ' join: e posTags) asRopedText fontName: cjkFont ]
			width: 120;
		column: 'First definition'
			text: [ :e |
				e allDefinitions isEmpty
					ifTrue: [ '' asRopedText ]
					ifFalse: [ (e allDefinitions first at: 'def' ifAbsent: [ '' ]) asRopedText fontName: cjkFont ] ];
		send: [ :e | e ]
]

{ #category : 'gt-search' }
MoedictDict >> gtSearchEntriesFor: aSearch [
	<gtSearch>
	^ aSearch list
		title: 'Entries';
		priority: 10;
		wantsToDisplayOnEmptyQuery: false;
		items: [ entries ];
		itemName: [ :e |
			e title , ' (' , e heteronyms size asString , ' het, ' ,
			e allDefinitions size asString , ' defs)' ];
		send: [ :e | e ];
		itemsLimit: 30;
		filterBySubstring
]

{ #category : 'initialization' }
MoedictDict >> initialize [
	entries := OrderedCollection new.
	titleIndex := Dictionary new
]

{ #category : 'accessing' }
MoedictDict >> lookup: aString [
	"I return the entry for aString, or nil."
	^ titleIndex at: aString ifAbsent: [ nil ]
]

{ #category : 'printing' }
MoedictDict >> printOn: aStream [
	aStream nextPutAll: 'MoedictDict('; print: entries size; nextPutAll: ' entries)'
]

{ #category : 'accessing' }
MoedictDict >> size [
	^ entries size
]
