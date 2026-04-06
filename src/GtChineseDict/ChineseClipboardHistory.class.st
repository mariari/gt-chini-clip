Class {
	#name : 'ChineseClipboardHistory',
	#superclass : 'Object',
	#instVars : [
		'clipboard',
		'entries'
	],
	#category : 'GtChineseDict',
	#package : 'GtChineseDict'
}

{ #category : 'instance creation' }
ChineseClipboardHistory class >> on: aChineseClipboard [
	^ self new clipboard: aChineseClipboard
]

{ #category : 'instance creation' }
ChineseClipboardHistory class >> open [
	^ self on: ChineseClipboard open
]

{ #category : 'accessing' }
ChineseClipboardHistory >> clipboard [
	^ clipboard
]

{ #category : 'accessing' }
ChineseClipboardHistory >> clipboard: aClipboard [
	clipboard := aClipboard.
	clipboard words ifNotNil: [ self onClipboardChanged ].
	clipboard announcer
		when: ValueChanged
		send: #onClipboardChanged
		to: self
]

{ #category : 'accessing' }
ChineseClipboardHistory >> entries [
	^ entries
]

{ #category : 'gt-actions' }
ChineseClipboardHistory >> gtActionPollingFor: anAction [
	<gtAction>
	^ anAction toggle
		icon: BrGlamorousVectorIcons play;
		label: 'Watch clipboard';
		activatedAction: [ :aToggle | self startPolling ];
		deactivatedAction: [ :aToggle | self stopPolling ]
]

{ #category : 'gt-views' }
ChineseClipboardHistory >> gtCurrentFor: aView [
	<gtView>
	^ aView forward
		title: 'Current';
		priority: 1;
		object: [ clipboard ];
		view: #gtReaderFor:
]

{ #category : 'gt-views' }
ChineseClipboardHistory >> gtHistoryFor: aView [
	<gtView>
	| cjkFont |
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'History';
		priority: 5;
		updateWhen: ValueChanged in: [ clipboard announcer ];
		items: [ entries reversed ];
		column: 'Text' text: [ :text |
			| words colored |
			words := clipboard dict segment: text.
			colored := '' asRopedText.
			words do: [ :w | colored := colored , (w toneColoredText fontName: cjkFont) ].
			colored fontSize: 16 ];
		column: 'Words' text: [ :text |
			(clipboard dict segment: text) size asString ] width: 50;
		send: [ :text |
			| tool |
			tool := ChineseClipboard new dict: clipboard dict.
			tool processText: text.
			tool ]
]

{ #category : 'gt-search' }
ChineseClipboardHistory >> gtSearchDictFor: aSearch [
	<gtSearch>
	clipboard dict ifNil: [ ^ aSearch empty ].
	^ (clipboard dict gtSearchEntriesFor: aSearch)
		send: [ :e | clipboard dict word: e traditional ]
]

{ #category : 'initialization' }
ChineseClipboardHistory >> initialize [
	entries := OrderedCollection new
]

{ #category : 'private' }
ChineseClipboardHistory >> onClipboardChanged [
	clipboard words ifNotNil: [ :w |
		| fullText |
		fullText := '' join: (w collect: #text).
		(entries isEmpty or: [ entries last ~= fullText ])
			ifTrue: [ entries add: fullText ] ]
]

{ #category : 'printing' }
ChineseClipboardHistory >> printOn: aStream [
	aStream
		nextPutAll: 'ClipboardHistory(';
		print: entries size;
		nextPutAll: ' entries)'
]

{ #category : 'gt-actions' }
ChineseClipboardHistory >> startPolling [
	clipboard startPolling
]

{ #category : 'gt-actions' }
ChineseClipboardHistory >> stopPolling [
	clipboard stopPolling
]
