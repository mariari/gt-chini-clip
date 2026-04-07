Class {
	#name : 'ChineseWord',
	#superclass : 'Object',
	#instVars : [
		'text',
		'entries',
		'dict'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'instance creation' }
ChineseWord class >> text: aString entries: aCollection [
	^ self new
		text: aString;
		entries: aCollection;
		yourself
]

{ #category : 'instance creation' }
ChineseWord class >> text: aString entries: aCollection dict: aDict [
	^ self new
		text: aString;
		entries: aCollection;
		dict: aDict;
		yourself
]

{ #category : 'accessing' }
ChineseWord >> bopomofo [
	^ entries ifEmpty: [ '' ] ifNotEmpty: [ entries first bopomofo ]
]

{ #category : 'accessing' }
ChineseWord >> breakdown [
	"I return my characters as individual ChineseWords looked up in the dict."
	text size <= 1 ifTrue: [ ^ #() ].
	dict ifNil: [ ^ #() ].
	^ (1 to: text size) collect: [ :i | dict word: (text at: i) asString ]
]

{ #category : 'accessing' }
ChineseWord >> definition [
	^ entries ifEmpty: [ '(unknown)' ] ifNotEmpty: [ entries first definitions first ]
]

{ #category : 'accessing' }
ChineseWord >> dict [
	^ dict
]

{ #category : 'accessing' }
ChineseWord >> dict: aDict [
	dict := aDict
]

{ #category : 'accessing' }
ChineseWord >> entries [
	^ entries
]

{ #category : 'accessing' }
ChineseWord >> entries: aCollection [
	entries := aCollection
]

{ #category : 'gt-views' }
ChineseWord >> gtBreakdownFor: aView [
	<gtView>
	| parts cjkFont |
	parts := self breakdown.
	parts ifEmpty: [ ^ aView empty ].
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'Breakdown';
		priority: 10;
		items: [ parts ];
		column: 'Character' text: [ :w |
			(w toneColoredText fontName: cjkFont) fontSize: 24 ] width: 60;
		column: 'BoPoMoFo' text: [ :w |
			w bopomofo asRopedText fontName: cjkFont ] width: 100;
		column: 'Definition' text: [ :w | w definition ];
		send: [ :w | w ]
]

{ #category : 'gt-views' }
ChineseWord >> gtDefinitionsFor: aView [
	<gtView>
	| cjkFont |
	entries ifEmpty: [ ^ aView empty ].
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'Definitions';
		priority: 5;
		items: [ entries ];
		column: 'Word' text: [ :e |
			e toneColoredTraditional fontName: cjkFont ] width: 60;
		column: 'BoPoMoFo' text: [ :e |
			e bopomofo asRopedText fontName: cjkFont ] width: 120;
		column: 'Definition' text: [ :e | '; ' join: e definitions ];
		send: [ :e | e ]
]

{ #category : 'gt-views' }
ChineseWord >> gtOverviewFor: aView [
	<gtView>
	| cjkFont |
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ {
			{ 'Text'. (self toneColoredText fontName: cjkFont) fontSize: 24 }.
			{ 'BoPoMoFo'. self bopomofo asRopedText fontName: cjkFont }.
			{ 'Definition'. self definition }.
			{ 'Entries'. entries size asString } } ];
		column: 'Property' text: #first;
		column: 'Value' text: #second
]

{ #category : 'testing' }
ChineseWord >> isKnown [
	^ entries isNotEmpty
]

{ #category : 'printing' }
ChineseWord >> printOn: aStream [
	aStream nextPutAll: text.
	entries ifNotEmpty: [
		aStream nextPutAll: ' ['; nextPutAll: self bopomofo; nextPut: $] ]
]

{ #category : 'accessing' }
ChineseWord >> text [
	^ text
]

{ #category : 'accessing' }
ChineseWord >> text: aString [
	text := aString
]

{ #category : 'accessing' }
ChineseWord >> toneColoredText [
	"I return my text as RopedText with each character colored by its tone."
	entries ifEmpty: [ ^ text asRopedText ].
	^ entries first toneColoredTraditional
]

{ #category : 'accessing' }
ChineseWord >> tooltipAptitude [
	"I return a tooltip aptitude showing my definition on hover."
	^ (BrGlamorousWithExplicitTooltipAptitude content: [
		BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: self definition ]) showDelay: 200 milliSeconds
]
