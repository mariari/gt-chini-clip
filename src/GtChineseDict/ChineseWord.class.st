Class {
	#name : 'ChineseWord',
	#superclass : 'Object',
	#instVars : [
		'text',
		'entries'
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

{ #category : 'accessing' }
ChineseWord >> bopomofo [
	^ entries ifEmpty: [ '' ] ifNotEmpty: [ entries first bopomofo ]
]

{ #category : 'accessing' }
ChineseWord >> definition [
	^ entries ifEmpty: [ '(unknown)' ] ifNotEmpty: [ entries first definitions first ]
]

{ #category : 'accessing' }
ChineseWord >> entries [
	^ entries
]

{ #category : 'accessing' }
ChineseWord >> entries: aCollection [
	entries := aCollection
]

{ #category : 'accessing' }
ChineseWord >> tooltipAptitude [
	"I return a tooltip aptitude showing my definition on hover."
	^ (BrGlamorousWithExplicitTooltipAptitude content: [
		BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: self definition ]) showDelay: 200 milliSeconds
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
