"
I am a segmented token representing a maximal run of non-CJK non-separator characters (Latin letters, digits, ASCII punctuation, etc.) that the segmenter emits for positions outside the CJK ranges.

I carry a reference to the dict that produced me so that future work can add reverse lookup (Chinese glosses for English words) without another refactor. I currently inherit all predicates and display behavior from SegmentedToken — text renders plain, isKnown is false, and the reader draws me as a non-dictionary chip.
"
Class {
	#name : 'EnglishWord',
	#superclass : 'SegmentedToken',
	#instVars : [
		'dict'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'instance creation' }
EnglishWord class >> text: aString dict: aCeDict [
	^ self new
		text: aString;
		dict: aCeDict;
		yourself
]

{ #category : 'accessing' }
EnglishWord >> dict [
	^ dict
]

{ #category : 'accessing' }
EnglishWord >> dict: aCeDict [
	dict := aCeDict
]
