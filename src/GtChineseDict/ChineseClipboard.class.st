Class {
	#name : 'ChineseClipboard',
	#superclass : 'Object',
	#instVars : [
		'dict',
		'lastText',
		'words',
		'pollingProcess',
		'announcer'
	],
	#category : 'GtChineseDict-Tool',
	#package : 'GtChineseDict',
	#tag : 'Tool'
}

{ #category : 'instance creation' }
ChineseClipboard class >> open [
	^ self new dict: CeDict default
]

{ #category : 'accessing' }
ChineseClipboard >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'private' }
ChineseClipboard >> buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize [
	self buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: nil
]

{ #category : 'private' }
ChineseClipboard >> buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: chipMap list: listRef [
	| flow highlightColor |
	highlightColor := (Color fromHexString: '#FFEB3B') alpha: 0.3.
	flow := BrHorizontalFlow new
		hMatchParent; vFitContent;
		padding: (BlInsets all: 8).
	words do: [ :word |
		| chip |
		chip := BrVerticalPane new
			fitContent; alignCenter;
			padding: (BlInsets all: 3);
			margin: (BlInsets all: 1);
			when: BlDoubleClickEvent do: [ :evt |
				evt consumed: true.
				evt currentTarget phlow spawnObject: word ];
			when: BlClickEvent do: [ :evt |
				evt consumed: true.
				chipMap ifNotNil: [
					chipMap valuesDo: [ :c | c background: Color transparent ].
					chip background: highlightColor ].
				(listRef notNil and: [ listRef first notNil ]) ifTrue: [
					| list idx |
					list := listRef first.
					idx := list items indexOf: word.
					idx > 0 ifTrue: [
						list deselectAll.
						list selectOne: idx ] ] ].
		word isKnown ifTrue: [
			chip addAptitude: word tooltipAptitude ].
		chip addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: charSize);
			text: (word toneColoredText fontName: cjkFont)).
		word isKnown ifTrue: [
			chip addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new fontSize: bopoSize);
				text: ((word bopomofo asRopedText fontName: cjkFont) foreground: Color gray)) ].
		chipMap ifNotNil: [ chipMap at: word put: chip ].
		flow addChild: chip ].
	aPane addChild: flow
]

{ #category : 'private' }
ChineseClipboard >> buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: chipMap [
	self buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: chipMap list: nil
]

{ #category : 'private' }
ChineseClipboard >> buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize [
	self buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: nil list: nil
]

{ #category : 'private' }
ChineseClipboard >> buildWordListIn: aPane font: cjkFont [
	self buildWordListIn: aPane font: cjkFont chipMap: nil listRef: nil
]

{ #category : 'private' }
ChineseClipboard >> buildWordListIn: aPane font: cjkFont chipMap: chipMap [
	self buildWordListIn: aPane font: cjkFont chipMap: chipMap listRef: nil
]

{ #category : 'private' }
ChineseClipboard >> buildWordListIn: aPane font: cjkFont chipMap: chipMap listRef: listRef [
	| list knownWords highlightColor |
	knownWords := words select: #isKnown.
	highlightColor := (Color fromHexString: '#FFEB3B') alpha: 0.3.
	list := BrColumnedList new matchParent.
	list rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
	listRef ifNotNil: [ listRef at: 1 put: list ].
	(list column title: 'Word'; width: 120)
		stencil: [ :w :col |
			BrLabel new aptitude: BrGlamorousLabelAptitude new;
				text: ((w toneColoredText fontName: cjkFont) fontSize: 20) ].
	(list column title: 'BoPoMoFo'; width: 120)
		stencil: [ :w :col |
			BrLabel new aptitude: BrGlamorousLabelAptitude new;
				text: ((w bopomofo asRopedText fontName: cjkFont) fontSize: 12) ].
	(list column title: 'Definition')
		stencil: [ :w :col |
			BrLabel new aptitude: BrGlamorousLabelAptitude new;
				text: w definition ].
	list items: knownWords.
	list when: BrSelectionDoubleClicked do: [ :evt |
		evt selection do: [ :each |
			list phlow spawnObject: (list items at: each) ] ].
	chipMap ifNotNil: [
		list when: BrSelectionChanged do: [ :evt |
			chipMap valuesDo: [ :c | c background: Color transparent ].
			evt selectedDo: [ :interval |
				| word chip idx |
				idx := interval isInteger ifTrue: [ interval ] ifFalse: [ interval first ].
				word := list items at: idx.
				chip := chipMap at: word ifAbsent: [ nil ].
				chip ifNotNil: [ chip background: highlightColor ] ] ] ].
	aPane addChild: list
]

{ #category : 'testing' }
ChineseClipboard >> containsChinese: aString [
	"I return true if the string contains CJK characters."
	^ aString anySatisfy: [ :c | c charCode between: 16r4E00 and: 16r9FFF ]
]

{ #category : 'accessing' }
ChineseClipboard >> dict [
	^ dict
]

{ #category : 'accessing' }
ChineseClipboard >> dict: aCeDict [
	dict := aCeDict
]

{ #category : 'gt-actions' }
ChineseClipboard >> gtActionPollingFor: anAction [
	<gtAction>
	^ anAction toggle
		icon: BrGlamorousVectorIcons play;
		label: 'Watch clipboard';
		activatedAction: [ :aToggle | self startPolling ];
		deactivatedAction: [ :aToggle | self stopPolling ]
]

{ #category : 'gt-views' }
ChineseClipboard >> gtReaderFor: aView [
	<gtView>
	words ifNil: [ ^ aView empty ].
	^ aView explicit
		title: 'Reader';
		priority: 0;
		updateWhen: ValueChanged in: [ self announcer ];
		stencil: [
			| pane cjkFont chipMap listRef |
			cjkFont := CeDictEntry cjkFontName.
			chipMap := IdentityDictionary new.
			listRef := Array new: 1.
			pane := BrVerticalPane new matchParent.
			self buildWordChipsIn: pane font: cjkFont charSize: 30 bopoSize: 10 chipMap: chipMap list: listRef.
			self buildWordListIn: pane font: cjkFont chipMap: chipMap listRef: listRef.
			pane ]
]

{ #category : 'gt-search' }
ChineseClipboard >> gtSearchDictFor: aSearch [
	<gtSearch>
	dict ifNil: [ ^ aSearch empty ].
	^ (dict gtSearchEntriesFor: aSearch)
		send: [ :e | dict word: e traditional ]
]

{ #category : 'gt-views' }
ChineseClipboard >> gtSegmentedFor: aView [
	<gtView>
	| cjkFont |
	words ifNil: [ ^ aView empty ].
	cjkFont := CeDictEntry cjkFontName.
	^ aView explicit
		title: 'Words';
		priority: 1;
		updateWhen: ValueChanged in: [ self announcer ];
		stencil: [
			| flow |
			flow := BrHorizontalFlow new
				matchParent;
				padding: (BlInsets all: 8).
			words do: [ :word |
				| chip |
				chip := BrVerticalPane new
					fitContent;
					padding: (BlInsets all: 4);
					margin: (BlInsets all: 2);
					border: (BlBorder
						paint: (word isKnown
							ifTrue: [ Color fromHexString: '#4CAF50' ]
							ifFalse: [ Color fromHexString: '#FF5722' ])
						width: 1);
					background: (word isKnown
						ifTrue: [ Color fromHexString: '#E8F5E9' ]
						ifFalse: [ Color fromHexString: '#FBE9E7' ]);
					when: BlClickEvent do: [ :evt |
						evt consumed: true.
						evt currentTarget phlow spawnObject: word ].
				word isKnown ifTrue: [
					chip addAptitude: (BrGlamorousWithTooltipAptitude content: [
						BrLabel new aptitude: BrGlamorousLabelAptitude new;
							text: word definition ]) ].
				chip addChild: (BrLabel new
					aptitude: (BrGlamorousLabelAptitude new fontSize: 50);
					text: (word toneColoredText fontName: cjkFont)).
				word isKnown ifTrue: [
					chip addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new fontSize: 20);
						text: ((word bopomofo asRopedText fontName: cjkFont) foreground: Color gray)) ].
				flow addChild: chip ].
			flow ]
]

{ #category : 'gt-views' }
ChineseClipboard >> gtWordListFor: aView [
	<gtView>
	| cjkFont |
	words ifNil: [ ^ aView empty ].
	cjkFont := CeDictEntry cjkFontName.
	^ aView columnedList
		title: 'Word list';
		priority: 5;
		updateWhen: ValueChanged in: [ self announcer ];
		items: [ words select: #isKnown ];
		column: 'Word' text: [ :w |
			(w toneColoredText fontName: cjkFont) fontSize: 20 ] width: 120;
		column: 'BoPoMoFo' text: [ :w |
			(w bopomofo asRopedText fontName: cjkFont) fontSize: 14 ] width: 120;
		column: 'Definition' text: [ :w | w definition ]
]

{ #category : 'printing' }
ChineseClipboard >> printOn: aStream [
	aStream nextPutAll: 'ChineseClipboard'.
	lastText ifNotNil: [
		aStream nextPutAll: '('; nextPutAll: (lastText first: (20 min: lastText size)); nextPutAll: '...)' ]
]

{ #category : 'actions' }
ChineseClipboard >> processText: aString [
	"I segment Chinese text and store the results."
	lastText := aString.
	words := dict segment: aString.
	self announcer announce: ValueChanged new
]

{ #category : 'actions' }
ChineseClipboard >> readClipboard [
	"I read the clipboard and process it if it contains Chinese."
	| text |
	text := Clipboard clipboardText asString.
	(text ~= lastText and: [ self containsChinese: text ])
		ifTrue: [ self processText: text ]
]

{ #category : 'actions' }
ChineseClipboard >> startPolling [
	"I start polling the clipboard every second. Process auto-terminates on GC."
	| weak |
	self stopPolling.
	weak := self asWeakReference.
	pollingProcess := [
		[ weak first notNil ] whileTrue: [
			[ weak first ifNotNil: [ :tool | tool readClipboard ] ]
				on: Error do: [ ].
			1 second wait ] ] fork
]

{ #category : 'actions' }
ChineseClipboard >> stopPolling [
	pollingProcess ifNotNil: [ :p |
		p terminate.
		pollingProcess := nil ]
]

{ #category : 'accessing' }
ChineseClipboard >> words [
	^ words
]
