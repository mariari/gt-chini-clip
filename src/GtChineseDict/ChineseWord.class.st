Class {
	#name : 'ChineseWord',
	#superclass : 'SegmentedToken',
	#instVars : [
		'entries',
		'dict'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'display mode' }
ChineseWord class >> convertSelector [
	"I return the selector to send to a token to convert it into my display mode."
	self subclassResponsibility
]

{ #category : 'display mode' }
ChineseWord class >> displayFont [
	"I return the CJK font name appropriate for my display mode."
	self subclassResponsibility
]

{ #category : 'display mode' }
ChineseWord class >> isSimplified [
	"I return whether I represent the simplified display mode."
	self subclassResponsibility
]

{ #category : 'display mode' }
ChineseWord class >> pronunciationLabel [
	"I return the human-readable label for the pronunciation column."
	self subclassResponsibility
]

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

{ #category : 'conversion' }
ChineseWord >> asSimplified [
	self subclassResponsibility
]

{ #category : 'conversion' }
ChineseWord >> asTraditional [
	self subclassResponsibility
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
	^ (1 to: text size) collect: [ :i | self convertToMyMode: (dict word: (text at: i) asString) ]
]

{ #category : 'conversion' }
ChineseWord >> convertToMyMode: aWord [
	"I convert aWord into the same display mode as myself. TraditionalWord sends asTraditional, SimplifiedWord sends asSimplified. No type tests — pure dispatch."
	self subclassResponsibility
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
ChineseWord >> displayTextOf: aCeDictEntry [
	"I return tone-colored text from aCeDictEntry for my display mode. TraditionalWord returns toneColoredTraditional, SimplifiedWord returns toneColoredSimplified."
	self subclassResponsibility
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
	cjkFont := self class displayFont.
	^ aView columnedList
		title: 'Breakdown';
		priority: 10;
		items: [ parts ];
		column: 'Character' text: [ :w |
			(w toneColoredText fontName: cjkFont) fontSize: 24 ] width: 60;
		column: self class pronunciationLabel text: [ :w |
			w pronunciation asRopedText fontName: cjkFont ] width: 100;
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
	cjkFont := self class displayFont.
	^ aView columnedList
		title: 'Definitions';
		priority: 5;
		items: [ entries ];
		column: 'Word' text: [ :e |
			(self displayTextOf: e) fontName: cjkFont ] width: 60;
		column: self class pronunciationLabel text: [ :e |
			(self pronunciationOf: e) asRopedText fontName: cjkFont ] width: 120;
		column: 'Definition' text: [ :e | '; ' join: e definitions ];
		send: [ :e | e ]
]

{ #category : 'gt-views' }
ChineseWord >> gtMoedictFor: aView [
	<gtView>
	| entry |
	entry := self moedictEntry.
	entry ifNil: [ ^ aView empty ].
	^ aView forward
		title: 'MOEDICT';
		priority: 6;
		object: [ entry ];
		view: #gtDefinitionsFor:
]

{ #category : 'gt-views' }
ChineseWord >> gtOverviewFor: aView [
	<gtView>
	| cjkFont |
	cjkFont := self class displayFont.
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ {
			{ 'Text'. (self toneColoredText fontName: cjkFont) fontSize: 24 }.
			{ self class pronunciationLabel. self pronunciation asRopedText fontName: cjkFont }.
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
ChineseWord >> knownPronunciation [
	"I return the pronunciation string for a known word. TraditionalWord returns bopomofo, SimplifiedWord returns pinyin."
	self subclassResponsibility
]

{ #category : 'accessing' }
ChineseWord >> moedictEntry [
	"I look up my canonical traditional form in MOEDICT, returning a MoedictEntry or nil. Lookup goes through preferredEntry so simplified-source words like 东西 still find the trad headword 東西."
	entries ifEmpty: [ ^ nil ].
	^ MoedictDict default lookup: self preferredEntry traditional
]

{ #category : 'accessing' }
ChineseWord >> pinyin [
	"I return the preferred entry's raw pinyin (space-separated numbered syllables like 'ni3 hao3'), or empty string if I have no entries."
	^ entries ifEmpty: [ '' ] ifNotEmpty: [ self preferredEntry pinyin ]
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
ChineseWord >> pronunciation [
	"I return the mode-appropriate pronunciation for this word: bopomofo for traditional, pinyin for simplified. The raw accessors bopomofo and pinyin remain available for direct access."
	^ entries ifEmpty: [ '' ] ifNotEmpty: [ self knownPronunciation ]
]

{ #category : 'accessing' }
ChineseWord >> pronunciationOf: aCeDictEntry [
	"I return the pronunciation string from aCeDictEntry appropriate for my display mode. TraditionalWord returns bopomofo, SimplifiedWord returns pinyin."
	self subclassResponsibility
]

{ #category : 'accessing' }
ChineseWord >> toneColoredKnownText [
	"I return tone-colored text for a known word. TraditionalWord uses traditional chars, SimplifiedWord uses simplified chars."
	self subclassResponsibility
]

{ #category : 'accessing' }
ChineseWord >> toneColoredText [
	"I return my text as RopedText with each character colored by its tone. Delegates to toneColoredKnownText which TraditionalWord and SimplifiedWord each implement for their character form."
	entries ifEmpty: [ ^ text asRopedText ].
	^ self toneColoredKnownText
]

{ #category : 'accessing' }
ChineseWord >> tooltipAptitude [
	"I return a tooltip aptitude showing my definition on hover."
	^ (BrGlamorousWithExplicitTooltipAptitude content: [
		BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: self definition ]) showDelay: 200 milliSeconds
]
