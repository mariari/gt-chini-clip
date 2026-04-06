Class {
	#name : 'ChineseDictExamples',
	#superclass : 'Object',
	#category : 'GtChineseDict-Examples',
	#package : 'GtChineseDict',
	#tag : 'Examples'
}

{ #category : 'examples - bopomofo' }
ChineseDictExamples >> bopomofoConversion [
	<gtExample>
	| result |
	result := PinyinBopomofo convert: 'ni3 hao3'.
	self assert: result equals: 'ㄋㄧˇ ㄏㄠˇ'.
	^ result
]

{ #category : 'examples - bopomofo' }
ChineseDictExamples >> bopomofoRetroflex [
	<gtExample>
	"Retroflex initials: zh ch sh r"
	| result |
	result := PinyinBopomofo convert: 'zhi1 chi1 shi4 ri4'.
	self assert: (result includesSubstring: 'ㄓ').
	self assert: (result includesSubstring: 'ㄔ').
	self assert: (result includesSubstring: 'ㄕ').
	self assert: (result includesSubstring: 'ㄖ').
	^ result
]

{ #category : 'examples - bopomofo' }
ChineseDictExamples >> bopomofoTones [
	<gtExample>
	| tones |
	tones := #('ma1' 'ma2' 'ma3' 'ma4' 'ma5') collect: [ :s |
		PinyinBopomofo convertSyllable: s ].
	self assert: tones first equals: 'ㄇㄚ'.
	self assert: tones second equals: 'ㄇㄚˊ'.
	self assert: tones third equals: 'ㄇㄚˇ'.
	self assert: tones fourth equals: 'ㄇㄚˋ'.
	self assert: tones fifth equals: 'ㄇㄚ˙'.
	^ tones
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
ChineseDictExamples >> historyOpen [
	<gtExample>
	| history |
	history := ChineseClipboardHistory on: (ChineseClipboard new dict: self smallDict).
	self assert: history entries isEmpty.
	self assert: history clipboard notNil.
	^ history
]

{ #category : 'examples - history' }
ChineseDictExamples >> historyWithEntries [
	<gtExample>
	| history |
	history := self historyOpen.
	history clipboard processText: '今天你好'.
	history clipboard processText: '天氣很好'.
	self assert: history entries size equals: 2.
	^ history
]

{ #category : 'examples - entry' }
ChineseDictExamples >> entryBopomofo [
	<gtExample>
	| entry |
	entry := self entryFromLine.
	self assert: entry bopomofo equals: 'ㄋㄧˇ ㄏㄠˇ'.
	^ entry
]

{ #category : 'examples - entry' }
ChineseDictExamples >> entryFromLine [
	<gtExample>
	| entry |
	entry := CeDictEntry fromLine: '你好 你好 [ni3 hao3] /hello/hi/how are you/'.
	self assert: entry traditional equals: '你好'.
	self assert: entry simplified equals: '你好'.
	self assert: entry pinyin equals: 'ni3 hao3'.
	self assert: entry definitions size equals: 3.
	self assert: entry definitions first equals: 'hello'.
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
ChineseDictExamples >> lookupTraditional [
	<gtExample>
	| dict results |
	dict := self smallDict.
	results := dict lookup: '你好'.
	self assert: results size equals: 1.
	self assert: results first definitions first equals: 'hello'.
	^ results first
]

{ #category : 'examples - segmentation' }
ChineseDictExamples >> segmentGreedyLongestMatch [
	<gtExample>
	"Greedy longest-match: 你好 is preferred over 你 + 好"
	| dict words |
	dict := self smallDict.
	words := dict segment: '你好'.
	self assert: words size equals: 1.
	self assert: words first text equals: '你好'.
	self assert: words first isKnown.
	^ words
]

{ #category : 'examples - segmentation' }
ChineseDictExamples >> segmentMultipleWords [
	<gtExample>
	| dict words |
	dict := self smallDict.
	words := dict segment: '今天你好'.
	self assert: words size equals: 2.
	self assert: words first text equals: '今天'.
	self assert: words second text equals: '你好'.
	^ words
]

{ #category : 'examples - segmentation' }
ChineseDictExamples >> segmentUnknownCharacter [
	<gtExample>
	| dict words |
	dict := self smallDict.
	words := dict segment: '你啊'.
	self assert: words size equals: 2.
	self assert: words first isKnown.
	self assert: words second isKnown not.
	self assert: words second text equals: '啊'.
	^ words
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

{ #category : 'examples - tone color' }
ChineseDictExamples >> toneColorFromPinyin [
	<gtExample>
	| c1 c3 |
	c1 := ChineseToneColor colorForPinyin: 'ma1'.
	c3 := ChineseToneColor colorForPinyin: 'ma3'.
	self assert: c1 equals: (ChineseToneColor colorForTone: 1).
	self assert: c3 equals: (ChineseToneColor colorForTone: 3).
	^ { c1. c3 }
]

{ #category : 'examples - tone color' }
ChineseDictExamples >> toneColors [
	<gtExample>
	| colors |
	colors := (1 to: 5) collect: [ :t | ChineseToneColor colorForTone: t ].
	self assert: colors first ~= colors second.
	self assert: colors second ~= colors third.
	self assert: colors third ~= colors fourth.
	self assert: colors fifth equals: Color gray.
	^ colors
]

{ #category : 'examples - word' }
ChineseDictExamples >> wordToneColoredText [
	<gtExample>
	| dict words colored |
	dict := self smallDict.
	words := dict segment: '今天'.
	colored := words first toneColoredText.
	self assert: colored size equals: 2.
	^ colored
]
