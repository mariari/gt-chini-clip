Class {
	#name : 'SimplifiedWord',
	#superclass : 'ChineseWord',
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'display mode' }
SimplifiedWord class >> convertSelector [
	^ #asSimplified
]

{ #category : 'display mode' }
SimplifiedWord class >> displayFont [
	^ CeDictEntry simplifiedFontName
]

{ #category : 'display mode' }
SimplifiedWord class >> isSimplified [
	^ true
]

{ #category : 'display mode' }
SimplifiedWord class >> pronunciationLabel [
	^ 'Pinyin'
]

{ #category : 'conversion' }
SimplifiedWord >> asSimplified [
	^ self
]

{ #category : 'conversion' }
SimplifiedWord >> asTraditional [
	^ TraditionalWord text: text entries: entries dict: dict
]

{ #category : 'conversion' }
SimplifiedWord >> convertToMyMode: aWord [
	^ aWord asSimplified
]

{ #category : 'accessing' }
SimplifiedWord >> displayTextOf: aCeDictEntry [
	^ aCeDictEntry toneColoredSimplified
]

{ #category : 'accessing' }
SimplifiedWord >> knownPronunciation [
	^ self preferredEntry pinyin
]

{ #category : 'accessing' }
SimplifiedWord >> pronunciationOf: aCeDictEntry [
	^ aCeDictEntry pinyin
]

{ #category : 'accessing' }
SimplifiedWord >> toneColoredKnownText [
	^ self preferredEntry toneColoredSimplified
]
