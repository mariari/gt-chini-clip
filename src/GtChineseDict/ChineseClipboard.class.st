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
ChineseClipboard >> buildWordChipsIn: aPane font: cjkFont charSize: charSize bopoSize: bopoSize chipMap: chipMap list: listRef detailPane: detailPane [
	| flow highlightColor |
	highlightColor := (Color fromHexString: '#FFEB3B') alpha: 0.3.
	flow := BrHorizontalFlow new
			hMatchParent;
			vFitContent;
			padding: (BlInsets all: 8).
	words
		do: [ :word | 
			| chip |
			chip := BrVerticalPane new
					fitContent;
					alignCenter;
					padding: (BlInsets all: 3);
					margin: (BlInsets all: 1);
					when: BlDoubleClickEvent
						do: [ :evt | 
							evt consumed: true.
							evt currentTarget phlow spawnObject: word ];
					when: BlClickEvent
						do: [ :evt | 
							evt consumed: true.
							chipMap
								ifNotNil: [ chipMap valuesDo: [ :c | c background: Color transparent ].
									chip background: highlightColor ].
							detailPane
								ifNotNil: [ self
										updateDetailPane: detailPane
										with: word
										font: cjkFont ].
							(listRef notNil and: [ listRef first notNil ])
								ifTrue: [ | list idx |
									list := listRef first.
									idx := list items indexOf: word.
									idx > 0
										ifTrue: [ list deselectAll.
											list selectOne: idx ] ] ].
			word isKnown ifTrue: [ chip addAptitude: word tooltipAptitude ].
			chip
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new fontSize: charSize);
						text: (word toneColoredText fontName: cjkFont)).
			word isKnown
				ifTrue: [ chip
						addChild: (BrLabel new
								aptitude: (BrGlamorousLabelAptitude new fontSize: bopoSize);
								text: ((word bopomofo asRopedText fontName: cjkFont) foreground: Color gray)) ].
			chipMap ifNotNil: [ chipMap at: word put: chip ].
			flow addChild: chip ].
	aPane addChild: flow
]

{ #category : 'private' }
ChineseClipboard >> buildWordListIn: aPane font: cjkFont chipMap: chipMap listRef: listRef detailPane: detailPane [
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
	list addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination return;
		action: [ list selectedItemDo: [ :word |
			list phlow spawnObject: word ] ]).
	list when: BrSelectionChanged do: [ :evt |
		chipMap ifNotNil: [
			chipMap valuesDo: [ :c | c background: Color transparent ] ].
		evt selectedDo: [ :interval |
			| word idx |
			idx := interval isInteger ifTrue: [ interval ] ifFalse: [ interval first ].
			word := list items at: idx.
			chipMap ifNotNil: [
				(chipMap at: word ifAbsent: [ nil ]) ifNotNil: [ :chip |
					chip background: highlightColor ] ].
			detailPane ifNotNil: [
				self updateDetailPane: detailPane with: word font: cjkFont ] ] ].
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
			| pane cjkFont chipMap listRef detailPane |
			cjkFont := CeDictEntry cjkFontName.
			chipMap := IdentityDictionary new.
			listRef := Array new: 1.
			detailPane := BrHorizontalPane new
					hMatchParent;
					vFitContent;
					padding: (BlInsets all: 8);
					alignCenterLeft;
					background: (Color fromHexString: '#F5F5F5');
					border: (BlBorder paint: (Color gray alpha: 0.2) width: 1).
			pane := BrVerticalPane new matchParent.
			self
				buildWordChipsIn: pane
				font: cjkFont
				charSize: 30
				bopoSize: 10
				chipMap: chipMap
				list: listRef
				detailPane: detailPane.
			pane addChild: detailPane.
			self
				buildWordListIn: pane
				font: cjkFont
				chipMap: chipMap
				listRef: listRef
				detailPane: detailPane.
			listRef first ifNotNil: [ :list |
				list enqueueTask: (BlTaskAction new action: [
					list selectFirst.
					list requestFocus ]) ].
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
		stencil: [ | flow |
			flow := BrHorizontalFlow new
					matchParent;
					padding: (BlInsets all: 8).
			words
				do: [ :word | 
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
							when: BlClickEvent
								do: [ :evt | 
									evt consumed: true.
									evt currentTarget phlow spawnObject: word ].
					word isKnown
						ifTrue: [ chip
								addAptitude: (BrGlamorousWithExplicitTooltipAptitude
										content: [ BrLabel new
												aptitude: BrGlamorousLabelAptitude new;
												text: word definition ]) ].
					chip
						addChild: (BrLabel new
								aptitude: (BrGlamorousLabelAptitude new fontSize: 50);
								text: (word toneColoredText fontName: cjkFont)).
					word isKnown
						ifTrue: [ chip
								addChild: (BrLabel new
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

{ #category : 'private' }
ChineseClipboard >> updateDetailPane: detailPane with: word font: cjkFont [
	detailPane removeChildren.
	detailPane addChild: (BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: 36);
		text: (word toneColoredText fontName: cjkFont)).
	word isKnown ifTrue: [
		detailPane addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: ((word bopomofo asRopedText fontName: cjkFont) foreground: Color gray);
			margin: (BlInsets left: 12)).
		detailPane addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
			text: word definition;
			margin: (BlInsets left: 12)) ]
]

{ #category : 'accessing' }
ChineseClipboard >> words [
	^ words
]
