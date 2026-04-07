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
	^ entries ifEmpty: [ '' ] ifNotEmpty: [ self preferredEntry bopomofo ]
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
	^ entries ifEmpty: [ '(unknown)' ] ifNotEmpty: [ self preferredEntry definitions first ]
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
		column: 'Other readings' text: [ :w |
			w entries size > 1
				ifTrue: [ (w entries size - 1) asString, ' more' ]
				ifFalse: [ '' ] ] width: 90;
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

{ #category : 'accessing' }
ChineseWord >> preferredEntry [
	"I prefer entries whose first definition isn't a 'variant of' pointer. CC-CEDICT marks alt-form entries this way (e.g. 着 trad=着 is 'variant of 著', and 吃 trad=喫 is 'variant of 吃'); the other entry is the canonical one. Falls back to my first entry when none of them are variants."
	^ entries
		detect: [ :e | (e definitions first beginsWith: 'variant of') not ]
		ifNone: [ entries first ]
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
	"I return my text as RopedText with each character colored by its tone. The preferred entry's traditional form is what I render."
	entries ifEmpty: [ ^ text asRopedText ].
	^ self preferredEntry toneColoredTraditional
]

{ #category : 'accessing' }
ChineseWord >> tooltipAptitude [
	"I return a tooltip aptitude showing my definition on hover."
	^ (BrGlamorousWithExplicitTooltipAptitude content: [
		BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: self definition ]) showDelay: 200 milliSeconds
]
