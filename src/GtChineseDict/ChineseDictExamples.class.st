Class {
	#name : 'ChineseDictExamples',
	#superclass : 'Object',
	#category : 'GtChineseDict-Examples',
	#package : 'GtChineseDict',
	#tag : 'Examples'
}

{ #category : 'examples - bopomofo' }
ChineseDictExamples >> bopomofoTones [
	<gtExample>
	"I prove all 5 tones convert correctly, including retroflex."
	| tones retroflex |
	tones := #('ma1' 'ma2' 'ma3' 'ma4' 'ma5') collect: [ :s |
		PinyinBopomofo convertSyllable: s ].
	self assert: tones first equals: 'ㄇㄚ'.
	self assert: tones second equals: 'ㄇㄚˊ'.
	self assert: tones third equals: 'ㄇㄚˇ'.
	self assert: tones fourth equals: 'ㄇㄚˋ'.
	self assert: tones fifth equals: 'ㄇㄚ˙'.
	retroflex := PinyinBopomofo convert: 'zhi1 chi1 shi4 ri4'.
	self assert: (retroflex includesSubstring: 'ㄓ').
	self assert: (retroflex includesSubstring: 'ㄔ').
	^ tones
]

{ #category : 'examples - entry' }
ChineseDictExamples >> entryFromLine [
	<gtExample>
	"I parse a CC-CEDICT line and verify all fields including bopomofo."
	| entry |
	entry := CeDictEntry fromLine: '你好 你好 [ni3 hao3] /hello/hi/how are you/'.
	self assert: entry traditional equals: '你好'.
	self assert: entry simplified equals: '你好'.
	self assert: entry pinyin equals: 'ni3 hao3'.
	self assert: entry bopomofo equals: 'ㄋㄧˇ ㄏㄠˇ'.
	self assert: entry definitions size equals: 3.
	^ entry
]

{ #category : 'examples - entry' }
ChineseDictExamples >> entryMultipleDefinitions [
	<gtExample>
	| entry |
	entry := CeDictEntry fromLine: '好 好 [hao3] /good/well/proper/easy to/'.
	self assert: entry definitions size equals: 4.
	self assert: entry traditional equals: '好'.
	^ entry
]

{ #category : 'examples - dict' }
ChineseDictExamples >> smallDict [
	<gtExample>
	| dict |
	dict := CeDict new.
	dict addEntry: (CeDictEntry fromLine: '你 你 [ni3] /you/').
	dict addEntry: (CeDictEntry fromLine: '好 好 [hao3] /good/well/').
	dict addEntry: (CeDictEntry fromLine: '你好 你好 [ni3 hao3] /hello/').
	dict addEntry: (CeDictEntry fromLine: '今天 今天 [jin1 tian1] /today/').
	dict addEntry: (CeDictEntry fromLine: '天 天 [tian1] /day/sky/').
	dict addEntry: (CeDictEntry fromLine: '今 今 [jin1] /now/present/').
	self assert: dict size equals: 6.
	^ dict
]

{ #category : 'examples - dict' }
ChineseDictExamples >> lookupTraditional [
	<gtExample>
	| results |
	results := self smallDict lookup: '你好'.
	self assert: results size equals: 1.
	self assert: results first definitions first equals: 'hello'.
	^ results first
]

{ #category : 'examples - segmentation' }
ChineseDictExamples >> segmentGreedyLongestMatch [
	<gtExample>
	"I prove greedy longest-match: 你好 preferred over 你 + 好."
	| words |
	words := self smallDict segment: '你好'.
	self assert: words size equals: 1.
	self assert: words first text equals: '你好'.
	self assert: words first isKnown.
	^ words
]

{ #category : 'examples - segmentation' }
ChineseDictExamples >> segmentUnknownCharacter [
	<gtExample>
	"I prove unknown characters are preserved."
	| words |
	words := self smallDict segment: '你啊'.
	self assert: words first isKnown.
	self assert: words second isKnown not.
	self assert: words second text equals: '啊'.
	^ words
]

{ #category : 'examples - tone color' }
ChineseDictExamples >> toneColors [
	<gtExample>
	"I prove each tone gets a distinct color, and pinyin lookup matches."
	| colors |
	colors := (1 to: 5) collect: [ :t | ChineseToneColor colorForTone: t ].
	self assert: colors first ~= colors second.
	self assert: colors second ~= colors third.
	self assert: colors third ~= colors fourth.
	self assert: colors fifth equals: Color gray.
	self assert: (ChineseToneColor colorForPinyin: 'ma1') equals: colors first.
	self assert: (ChineseToneColor colorForPinyin: 'ma3') equals: colors third.
	^ colors
]

{ #category : 'examples - word' }
ChineseDictExamples >> wordToneColoredText [
	<gtExample>
	"I prove per-character tone coloring on a segmented word."
	| words colored |
	words := self segmentGreedyLongestMatch.
	colored := words first toneColoredText.
	self assert: colored size equals: 2.
	^ colored
]

{ #category : 'examples - clipboard' }
ChineseDictExamples >> clipboardProcessText [
	<gtExample>
	| tool |
	tool := ChineseClipboard new dict: self smallDict.
	self assert: (tool containsChinese: '你好world').
	self assert: (tool containsChinese: 'hello world') not.
	tool processText: '今天你好'.
	self assert: tool words size equals: 2.
	self assert: tool words first text equals: '今天'.
	^ tool
]

{ #category : 'examples - history' }
ChineseDictExamples >> historyWithEntries [
	<gtExample>
	"I compose on clipboardProcessText's clipboard, process two new texts."
	| tool history |
	tool := self clipboardProcessText.
	history := ChineseClipboardHistory on: tool.
	tool processText: '你好世界'.
	tool processText: '天氣很好'.
	self assert: history entries size equals: 2.
	self assert: history entries first key equals: '你好世界'.
	^ history
]

{ #category : 'examples - font' }
ChineseDictExamples >> cjkFontName [
	<gtExample>
	| name |
	name := CeDictEntry cjkFontName.
	self assert: name isNotNil.
	self assert: name isNotEmpty.
	^ name
]
