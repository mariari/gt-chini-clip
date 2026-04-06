Class {
	#name : 'CeDictEntry',
	#superclass : 'Object',
	#instVars : [
		'traditional',
		'simplified',
		'pinyin',
		'definitions'
	],
	#classVars : [
		'CjkFont'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'accessing' }
CeDictEntry class >> cjkFontName [
	"I return the font name for CJK and BoPoMoFo display.
	 Prefers DFPYuanW7-ZhuIn (has inline zhuyin), falls back to Source Han Sans TW."
	CjkFont ifNotNil: [ ^ CjkFont ].
	CjkFont := (SkiaFontManager default familyNames includes: 'DFPYuanW7-ZhuIn')
		ifTrue: [ 'DFPYuanW7-ZhuIn' ]
		ifFalse: [ 'Source Han Sans TW' ].
	^ CjkFont
]

{ #category : 'instance creation' }
CeDictEntry class >> fromLine: aString [
	"I parse a CC-CEDICT line: Traditional Simplified [pin1 yin1] /def1/def2/"
	| trad simp rest pinyinEnd pinyin defs |
	trad := aString copyUpTo: Character space.
	rest := aString allButFirst: trad size + 1.
	simp := rest copyUpTo: Character space.
	rest := rest allButFirst: simp size + 1.
	pinyinEnd := rest indexOf: $].
	pinyin := rest copyFrom: 2 to: pinyinEnd - 1.
	rest := rest allButFirst: pinyinEnd + 2.
	defs := ($/ split: rest) reject: #isEmpty.
	^ self new
		traditional: trad;
		simplified: simp;
		pinyin: pinyin;
		definitions: defs
]

{ #category : 'accessing' }
CeDictEntry >> bopomofo [
	^ PinyinBopomofo convert: pinyin
]

{ #category : 'accessing' }
CeDictEntry >> definitions [
	^ definitions
]

{ #category : 'accessing' }
CeDictEntry >> definitions: anArray [
	definitions := anArray
]

{ #category : 'gt-views' }
CeDictEntry >> gtDefinitionsFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Definitions';
		priority: 5;
		items: [ definitions ];
		column: '#'
			text: [ :d :idx | idx ]
			width: 30;
		column: 'Definition'
			text: [ :d | d asRopedText fontName: CeDictEntry cjkFontName ]
]

{ #category : 'gt-views' }
CeDictEntry >> gtOverviewFor: aView [
	<gtView>
	| cjkFont |
	cjkFont := self class cjkFontName.
	^ aView columnedList
		title: 'Overview';
		priority: 1;
		items: [ {
			{ 'Traditional'. (self toneColoredTraditional fontName: cjkFont) fontSize: 24 }.
			{ 'Simplified'. simplified asRopedText fontName: cjkFont }.
			{ 'Pinyin'. pinyin }.
			{ 'BoPoMoFo'. self bopomofo asRopedText fontName: cjkFont }.
			{ 'Definitions'. '; ' join: definitions } } ];
		column: 'Property' text: #first;
		column: 'Value' text: #second
]

{ #category : 'accessing' }
CeDictEntry >> pinyin [
	^ pinyin
]

{ #category : 'accessing' }
CeDictEntry >> pinyin: aString [
	pinyin := aString
]

{ #category : 'printing' }
CeDictEntry >> printOn: aStream [
	aStream
		nextPutAll: traditional;
		nextPutAll: ' [';
		nextPutAll: self bopomofo;
		nextPutAll: '] ';
		nextPutAll: definitions first
]

{ #category : 'accessing' }
CeDictEntry >> simplified [
	^ simplified
]

{ #category : 'accessing' }
CeDictEntry >> simplified: aString [
	simplified := aString
]

{ #category : 'accessing' }
CeDictEntry >> toneColoredTraditional [
	"I return traditional text as RopedText with per-character tone coloring."
	| syllables |
	syllables := Character space split: pinyin.
	^ (1 to: traditional size) inject: '' asRopedText into: [ :acc :i |
		acc , ((traditional at: i) asString asRopedText
			foreground: (ChineseToneColor colorForPinyin: (syllables at: i ifAbsent: [ '' ]))) ]
]

{ #category : 'accessing' }
CeDictEntry >> traditional [
	^ traditional
]

{ #category : 'accessing' }
CeDictEntry >> traditional: aString [
	traditional := aString
]
