Class {
	#name : 'ChineseWordSelected',
	#superclass : 'Announcement',
	#instVars : [
		'word'
	],
	#category : 'GtChineseDict',
	#package : 'GtChineseDict'
}

{ #category : 'instance creation' }
ChineseWordSelected class >> word: aChineseWord [
	^ self new word: aChineseWord
]

{ #category : 'accessing' }
ChineseWordSelected >> word [
	^ word
]

{ #category : 'accessing' }
ChineseWordSelected >> word: aChineseWord [
	word := aChineseWord
]
