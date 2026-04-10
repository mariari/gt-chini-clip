Class {
	#name : 'TraditionalWord',
	#superclass : 'ChineseWord',
	#instVars : [ ],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'conversion' }
TraditionalWord >> asSimplified [
	^ SimplifiedWord text: text entries: entries dict: dict
]

{ #category : 'conversion' }
TraditionalWord >> asTraditional [
	^ self
]

{ #category : 'display mode' }
TraditionalWord class >> convertSelector [
	^ #asTraditional
]

{ #category : 'display mode' }
TraditionalWord class >> pronunciationLabel [
	^ 'BoPoMoFo'
]

{ #category : 'display mode' }
TraditionalWord class >> displayFont [
	^ CeDictEntry cjkFontName
]

{ #category : 'display mode' }
TraditionalWord class >> isSimplified [
	^ false
]

{ #category : 'conversion' }
TraditionalWord >> convertToMyMode: aWord [
	^ aWord asTraditional
]

{ #category : 'accessing' }
TraditionalWord >> displayTextOf: aCeDictEntry [
	^ aCeDictEntry toneColoredTraditional
]

{ #category : 'accessing' }
TraditionalWord >> pronunciationOf: aCeDictEntry [
	^ aCeDictEntry bopomofo
]

{ #category : 'accessing' }
TraditionalWord >> knownPronunciation [
	^ self preferredEntry bopomofo
]

{ #category : 'accessing' }
TraditionalWord >> toneColoredKnownText [
	^ self preferredEntry toneColoredTraditional
]
