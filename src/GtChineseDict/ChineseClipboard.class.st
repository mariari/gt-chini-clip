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

{ #category : 'instance creation' }
ChineseClipboard class >> openWith: aString [
	"I open a clipboard backed by a custom dictionary named aString, layered on the default CC-CEDICT."
	^ self new dict: (CustomDict named: aString)
]

{ #category : 'accessing' }
ChineseClipboard >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : 'private' }
ChineseClipboard >> buildChipFor: word charSize: charSize bopoSize: bopoSize select: selectWord chipsByWord: chipsByWord font: cjkFont [
	"I build a chip for one word, with optional expand-to-breakdown affordance."
	| chip mainBlock breakdownContainer expandable |
	chip := BrVerticalPane new
		fitContent; alignCenter;
		padding: (BlInsets all: 3);
		margin: (BlInsets all: 1).
	mainBlock := BrVerticalPane new
		fitContent; alignCenter;
		when: BlDoubleClickEvent do: [ :evt |
			evt consumed: true.
			evt currentTarget phlow spawnObject: word ];
		when: BlClickEvent do: [ :evt |
			evt consumed: true.
			selectWord value: word ].
	mainBlock addChild: (BrLabel new
		aptitude: (BrGlamorousLabelAptitude new fontSize: charSize);
		text: (word toneColoredText fontName: cjkFont)).
	word isKnown ifTrue: [
		mainBlock
			addAptitude: word tooltipAptitude;
			addChild: (BrLabel new
				aptitude: (BrGlamorousLabelAptitude new fontSize: bopoSize);
				text: ((word bopomofo asRopedText fontName: cjkFont) foreground: Color gray)) ].
	chipsByWord at: word put: mainBlock.
	chip addChild: mainBlock.
	expandable := word isKnown and: [ word text size > 1 ].
	expandable ifTrue: [
		breakdownContainer := BrHorizontalFlow new
			fitContent; padding: (BlInsets top: 2);
			visibility: BlVisibility gone.
		word breakdown do: [ :sub |
			breakdownContainer addChild: (self
				buildChipFor: sub
				charSize: charSize - 8
				bopoSize: bopoSize - 2
				select: selectWord
				chipsByWord: chipsByWord
				font: cjkFont) ].
		chip addChild: (BrButton new
			aptitude: BrGlamorousButtonWithIconAptitude;
			icon: BrGlamorousVectorIcons expandvertical;
			beTinySize;
			margin: (BlInsets top: 2);
			action: [ :btn |
				breakdownContainer visibility = BlVisibility gone
					ifTrue: [ breakdownContainer visibility: BlVisibility visible ]
					ifFalse: [ breakdownContainer visibility: BlVisibility gone ] ]).
		chip addChild: breakdownContainer ].
	^ chip
]

{ #category : 'private' }
ChineseClipboard >> buildChipsAreaSelect: selectWord on: anAnnouncer [
	"I build a scrollable chips area capped at half its parent's height. The cap is computed once on first layout."
	| chipsFlow chipsScroll wrap sized |
	chipsFlow := self
		buildWordChipsCharSize: 30
		bopoSize: 10
		select: selectWord
		on: anAnnouncer.
	chipsFlow hMatchParent; vFitContent.
	chipsScroll := BrScrollPane new
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		matchParent;
		content: chipsFlow.
	wrap := BrFrame new hMatchParent; vExact: 1; addChild: chipsScroll; yourself.
	sized := false.
	wrap addEventHandlerOn: BlElementLayoutComputedEvent do: [ :evt |
		sized ifFalse: [
			wrap parent ifNotNil: [ :parent |
				| parentH chipsH |
				parentH := parent extent y.
				chipsH := chipsFlow extent y.
				(parentH > 0 and: [ chipsH > 0 ]) ifTrue: [
					sized := true.
					wrap vExact: (chipsH min: parentH // 2).
					parent requestLayout ] ] ] ].
	^ wrap
]

{ #category : 'private' }
ChineseClipboard >> buildDetailPaneOn: anAnnouncer [
	| pane cjkFont |
	cjkFont := CeDictEntry cjkFontName.
	pane := BrHorizontalPane new
			hMatchParent;
			vFitContent;
			padding: (BlInsets all: 8);
			alignCenterLeft;
			background: (Color fromHexString: '#F5F5F5');
			border: (BlBorder paint: (Color gray alpha: 0.2) width: 1).
	anAnnouncer
		when: ChineseWordSelected
		do: [ :evt | 
			| word |
			word := evt word.
			pane removeChildren.
			pane
				addChild: (BrLabel new
						aptitude: (BrGlamorousLabelAptitude new fontSize: 36);
						text: (word toneColoredText fontName: cjkFont)).
			word isKnown
				ifTrue: [  "POS badge from MOEDICT, hover for English name"word moedictEntry
						ifNotNil: [ :e | 
							e posTags
								ifNotEmpty: [ :posTags | 
									pane
										addChild: ((BrLabel new
												aptitude: (BrGlamorousLabelAptitude new fontSize: 14);
												text: (('[' , (' ' join: posTags) , ']') asRopedText fontName: cjkFont);
												margin: (BlInsets left: 12))
												addAptitude: (BrGlamorousWithExplicitTooltipAptitude
														content: [ BrLabel new
																aptitude: BrGlamorousLabelAptitude new;
																text: ((', '
																		join: (posTags collect: [ :t | t , ' = ' , (MoedictEntry posNameFor: t) ]))
																		asRopedText fontName: cjkFont) ])) ] ].
					pane
						addChild: (BrLabel new
								aptitude: (BrGlamorousLabelAptitude new fontSize: 16);
								text: word definition;
								margin: (BlInsets left: 12)) ] ]
		for: self.
	^ pane
]

{ #category : 'private' }
ChineseClipboard >> buildReaderPane [
	"I assemble the Reader view: chips area on top, detail strip in the middle, word list at the bottom. All three are wired through a shared announcer + dedup'd selectWord block."
	| announcer current selectWord pane firstKnown |
	announcer := Announcer new.
	current := nil.
	selectWord := [ :word |
		current == word ifFalse: [
			current := word.
			announcer announce: (ChineseWordSelected word: word) ] ].
	pane := BrVerticalPane new matchParent
		addChild: (self buildChipsAreaSelect: selectWord on: announcer);
		addChild: (self buildDetailPaneOn: announcer);
		addChild: (self buildWordListSelect: selectWord on: announcer);
		yourself.
	firstKnown := words detect: #isKnown ifNone: [ nil ].
	firstKnown ifNotNil: [ selectWord value: firstKnown ].
	^ pane
]

{ #category : 'private' }
ChineseClipboard >> buildWordChipsCharSize: charSize bopoSize: bopoSize select: selectWord on: anAnnouncer [
	"I build a vertical stack of horizontal-flow rows, starting a new row on each CR/LF in the source text so paragraph structure survives into the reader. The word list below filters newline-only words out, so this is purely a visual change to the chips area."
	| container highlightColor chipsByWord cjkFont rows currentRow isNewline |
	cjkFont := CeDictEntry cjkFontName.
	highlightColor := (Color fromHexString: '#FFEB3B') alpha: 0.3.
	chipsByWord := IdentityDictionary new.
	isNewline := [ :w |
		w text size = 1 and: [
			w text first = Character lf or: [ w text first = Character cr ] ] ].
	rows := OrderedCollection new.
	currentRow := OrderedCollection new.
	words do: [ :word |
		(isNewline value: word)
			ifTrue: [
				currentRow isEmpty ifFalse: [
					rows add: currentRow.
					currentRow := OrderedCollection new ] ]
			ifFalse: [ currentRow add: word ] ].
	currentRow isEmpty ifFalse: [ rows add: currentRow ].
	container := BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 8).
	rows do: [ :row |
		| flow |
		flow := BrHorizontalFlow new
			hMatchParent;
			vFitContent;
			yourself.
		row do: [ :word |
			flow addChild: (self
				buildChipFor: word
				charSize: charSize
				bopoSize: bopoSize
				select: selectWord
				chipsByWord: chipsByWord
				font: cjkFont) ].
		container addChild: flow ].
	anAnnouncer when: ChineseWordSelected do: [ :evt |
		chipsByWord valuesDo: [ :c | c background: Color transparent ].
		(chipsByWord at: evt word ifAbsent: [ nil ]) ifNotNil: [ :c |
			c background: highlightColor.
			self scrollIntoView: c ] ] for: self.
	^ container
]

{ #category : 'private' }
ChineseClipboard >> buildWordListSelect: selectWord on: anAnnouncer [
	| list cjkFont labelStencil |
	cjkFont := CeDictEntry cjkFontName.
	labelStencil := [ :textBlock |
		[ :w :col | BrLabel new aptitude: BrGlamorousLabelAptitude new; text: (textBlock value: w) ] ].
	list := BrColumnedList new matchParent.
	list rowStencil: BrGlamorousColumnedListSelectableRowElementStencilBuilder new.
	(list column title: 'Word'; width: 120) stencil: (labelStencil value: [ :w |
		(w toneColoredText fontName: cjkFont) fontSize: 20 ]).
	(list column title: 'BoPoMoFo'; width: 120) stencil: (labelStencil value: [ :w |
		(w bopomofo asRopedText fontName: cjkFont) fontSize: 12 ]).
	(list column title: 'Definition') stencil: (labelStencil value: [ :w | w definition ]).
	list items: (words select: #isKnown).
	list when: BrSelectionDoubleClicked do: [ :evt |
		evt selection do: [ :each | list phlow spawnObject: (list items at: each) ] ].
	list addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination return;
		action: [ list selectedItemDo: [ :word | list phlow spawnObject: word ] ]).
	list when: BrSelectionChanged do: [ :evt |
		evt selectedDo: [ :interval |
			| idx |
			idx := interval isInteger ifTrue: [ interval ] ifFalse: [ interval first ].
			selectWord value: (list items at: idx) ] ].
	list addEventHandlerOn: BlElementAddedToSceneGraphEvent do: [ :evt | list requestFocus ].
	anAnnouncer when: ChineseWordSelected do: [ :evt |
		| idx |
		idx := list items indexOf: evt word.
		idx > 0 ifTrue: [
			list deselectAll.
			list selectOne: idx.
			(self list: list isItemAtIndexVisible: idx)
				ifFalse: [ list scrollToItem: evt word ].
			"Re-focus deferred so we win against the click event re-targeting focus."
			list space ifNotNil: [ :sp |
				sp enqueueTask: (BlTaskAction new action: [ list requestFocus ]) ] ] ] for: self.
	^ list
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
		stencil: [ self buildReaderPane ]
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

{ #category : 'private' }
ChineseClipboard >> list: aList isItemAtIndexVisible: anIndex [
	"I return true if the row at anIndex is currently rendered."
	^ aList
		allChildrenBreadthFirstDetect: [ :c | c isKindOf: BrInfiniteListElement ]
		ifFound: [ :i | (i findElementHolderForDataSourcePosition: anIndex) notNil ]
		ifNone: [ false ]
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

{ #category : 'private' }
ChineseClipboard >> scrollIntoView: anElement [
	"I find anElement's enclosing BlScrollableElement and scroll it just enough to make anElement visible."
	| scrollable elemY elemH viewportH |
	anElement ifNil: [ ^ self ].
	scrollable := anElement parent.
	[ scrollable notNil and: [ (scrollable isKindOf: BlScrollableElement) not ] ]
		whileTrue: [ scrollable := scrollable parent ].
	scrollable ifNil: [ ^ self ].
	viewportH := scrollable extent y.
	viewportH <= 0 ifTrue: [ ^ self ].
	elemY := (anElement localPointToGlobal: 0@0) y - (scrollable localPointToGlobal: 0@0) y.
	elemH := anElement extent y.
	elemY < 0 ifTrue: [ ^ scrollable scrollVerticallyBy: elemY negated ].
	elemY + elemH > viewportH ifTrue: [
		scrollable scrollVerticallyBy: viewportH - elemY - elemH ]
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
