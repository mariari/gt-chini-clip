Class {
	#name : 'MoedictEntry',
	#superclass : 'Object',
	#instVars : [
		'data'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'instance creation' }
MoedictEntry class >> on: aDictionary [
	"I wrap a parsed JSON entry from MOEDICT bulk data."
	^ self new data: aDictionary; yourself
]

{ #category : 'accessing' }
MoedictEntry class >> posLegend [
	"I return a Dictionary mapping MOEDICT's single-character POS tags to a human-readable English name."
	^ Dictionary new
		at: '名' put: 'noun';
		at: '動' put: 'verb';
		at: '形' put: 'adjective';
		at: '副' put: 'adverb';
		at: '介' put: 'preposition';
		at: '連' put: 'conjunction';
		at: '助' put: 'particle';
		at: '嘆' put: 'interjection';
		at: '歎' put: 'interjection';
		at: '代' put: 'pronoun';
		at: '量' put: 'classifier (measure word)';
		at: '擬' put: 'onomatopoeia';
		at: '綴' put: 'affix';
		yourself
]

{ #category : 'accessing' }
MoedictEntry class >> posNameFor: aTag [
	"I return the English name for a POS tag, or the tag itself if unknown."
	^ self posLegend at: aTag ifAbsent: [ aTag ]
]

{ #category : 'accessing' }
MoedictEntry >> allDefinitions [
	"I return all definitions across all heteronyms as a flat collection of Dictionaries (each with def, optional type, optional example, optional quote)."
	^ self heteronyms gather: [ :h | h at: 'definitions' ifAbsent: [ #() ] ]
]

{ #category : 'accessing' }
MoedictEntry >> data [
	^ data
]

{ #category : 'accessing' }
MoedictEntry >> data: aDictionary [
	data := aDictionary
]

{ #category : 'accessing' }
MoedictEntry >> heteronyms [
	"I return the array of pronunciation variants. Each is a Dictionary with bopomofo, pinyin, definitions."
	^ data at: 'heteronyms' ifAbsent: [ #() ]
]

{ #category : 'accessing' }
MoedictEntry >> posTags [
	"I return the distinct POS tags across all my definitions, in order of first appearance."
	| seen result |
	seen := Set new.
	result := OrderedCollection new.
	self allDefinitions do: [ :d |
		(d at: 'type' ifAbsent: [ nil ]) ifNotNil: [ :tag |
			(seen includes: tag) ifFalse: [
				seen add: tag.
				result add: tag ] ] ].
	^ result
]

{ #category : 'printing' }
MoedictEntry >> printOn: aStream [
	aStream
		nextPutAll: 'MoedictEntry(';
		nextPutAll: self title;
		nextPutAll: ': ';
		print: self heteronyms size;
		nextPutAll: ' het, ';
		print: self allDefinitions size;
		nextPutAll: ' defs)'
]

{ #category : 'accessing' }
MoedictEntry >> title [
	^ data at: 'title' ifAbsent: [ '' ]
]
