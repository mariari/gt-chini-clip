Class {
	#name : 'ChineseToneColor',
	#superclass : 'Object',
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'accessing' }
ChineseToneColor class >> colorForPinyin: pinyinString [
	"I return the tone color for a pinyin string (uses first syllable's tone)."
	| syllables first |
	syllables := Character space split: pinyinString.
	syllables ifEmpty: [ ^ Color black ].
	first := syllables first.
	first ifEmpty: [ ^ Color black ].
	^ self colorForTone: (first last isDigit
		ifTrue: [ first last digitValue ]
		ifFalse: [ 5 ])
]

{ #category : 'accessing' }
ChineseToneColor class >> colorForTone: aToneNumber [
	"1=red (flat), 2=orange (rising), 3=green (dip), 4=blue (falling), 5=gray (neutral)"
	aToneNumber = 1 ifTrue: [ ^ Color fromHexString: '#D32F2F' ].
	aToneNumber = 2 ifTrue: [ ^ Color fromHexString: '#F57C00' ].
	aToneNumber = 3 ifTrue: [ ^ Color fromHexString: '#388E3C' ].
	aToneNumber = 4 ifTrue: [ ^ Color fromHexString: '#1976D2' ].
	^ Color gray
]
