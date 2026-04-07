Class {
	#name : 'PinyinBopomofo',
	#superclass : 'Object',
	#classVars : [
		'Table'
	],
	#category : 'GtChineseDict-Model',
	#package : 'GtChineseDict',
	#tag : 'Model'
}

{ #category : 'initialization' }
PinyinBopomofo class >> buildTable [
	"I return a Dictionary mapping pinyin base syllables to BoPoMoFo."
	| t |
	t := Dictionary new.
	"Initials"
	#(
		('b' 'ㄅ') ('p' 'ㄆ') ('m' 'ㄇ') ('f' 'ㄈ')
		('d' 'ㄉ') ('t' 'ㄊ') ('n' 'ㄋ') ('l' 'ㄌ')
		('g' 'ㄍ') ('k' 'ㄎ') ('h' 'ㄏ')
		('j' 'ㄐ') ('q' 'ㄑ') ('x' 'ㄒ')
		('zh' 'ㄓ') ('ch' 'ㄔ') ('sh' 'ㄕ') ('r' 'ㄖ')
		('z' 'ㄗ') ('c' 'ㄘ') ('s' 'ㄙ')
	) do: [ :pair | t at: pair first put: pair second ].
	"Finals and combinations - comprehensive mapping"
	#(
		('a' 'ㄚ') ('o' 'ㄛ') ('e' 'ㄜ') ('ai' 'ㄞ') ('ei' 'ㄟ')
		('ao' 'ㄠ') ('ou' 'ㄡ') ('an' 'ㄢ') ('en' 'ㄣ') ('ang' 'ㄤ')
		('eng' 'ㄥ') ('er' 'ㄦ')
		('yi' 'ㄧ') ('ya' 'ㄧㄚ') ('ye' 'ㄧㄝ') ('yao' 'ㄧㄠ')
		('you' 'ㄧㄡ') ('yan' 'ㄧㄢ') ('yin' 'ㄧㄣ') ('yang' 'ㄧㄤ')
		('ying' 'ㄧㄥ') ('yong' 'ㄩㄥ') ('yu' 'ㄩ') ('yue' 'ㄩㄝ')
		('yuan' 'ㄩㄢ') ('yun' 'ㄩㄣ')
		('wu' 'ㄨ') ('wa' 'ㄨㄚ') ('wo' 'ㄨㄛ') ('wai' 'ㄨㄞ')
		('wei' 'ㄨㄟ') ('wan' 'ㄨㄢ') ('wen' 'ㄨㄣ') ('wang' 'ㄨㄤ')
		('weng' 'ㄨㄥ')
		('ba' 'ㄅㄚ') ('bo' 'ㄅㄛ') ('bai' 'ㄅㄞ') ('bei' 'ㄅㄟ')
		('bao' 'ㄅㄠ') ('ban' 'ㄅㄢ') ('ben' 'ㄅㄣ') ('bang' 'ㄅㄤ')
		('beng' 'ㄅㄥ') ('bi' 'ㄅㄧ') ('bie' 'ㄅㄧㄝ') ('biao' 'ㄅㄧㄠ')
		('bian' 'ㄅㄧㄢ') ('bin' 'ㄅㄧㄣ') ('bing' 'ㄅㄧㄥ') ('bu' 'ㄅㄨ')
		('pa' 'ㄆㄚ') ('po' 'ㄆㄛ') ('pai' 'ㄆㄞ') ('pei' 'ㄆㄟ')
		('pao' 'ㄆㄠ') ('pou' 'ㄆㄡ') ('pan' 'ㄆㄢ') ('pen' 'ㄆㄣ')
		('pang' 'ㄆㄤ') ('peng' 'ㄆㄥ') ('pi' 'ㄆㄧ') ('pie' 'ㄆㄧㄝ')
		('piao' 'ㄆㄧㄠ') ('pian' 'ㄆㄧㄢ') ('pin' 'ㄆㄧㄣ') ('ping' 'ㄆㄧㄥ')
		('pu' 'ㄆㄨ')
		('ma' 'ㄇㄚ') ('mo' 'ㄇㄛ') ('me' 'ㄇㄜ') ('mai' 'ㄇㄞ')
		('mei' 'ㄇㄟ') ('mao' 'ㄇㄠ') ('mou' 'ㄇㄡ') ('man' 'ㄇㄢ')
		('men' 'ㄇㄣ') ('mang' 'ㄇㄤ') ('meng' 'ㄇㄥ') ('mi' 'ㄇㄧ')
		('mie' 'ㄇㄧㄝ') ('miao' 'ㄇㄧㄠ') ('miu' 'ㄇㄧㄡ') ('mian' 'ㄇㄧㄢ')
		('min' 'ㄇㄧㄣ') ('ming' 'ㄇㄧㄥ') ('mu' 'ㄇㄨ')
		('fa' 'ㄈㄚ') ('fo' 'ㄈㄛ') ('fei' 'ㄈㄟ') ('fou' 'ㄈㄡ')
		('fan' 'ㄈㄢ') ('fen' 'ㄈㄣ') ('fang' 'ㄈㄤ') ('feng' 'ㄈㄥ')
		('fu' 'ㄈㄨ')
		('da' 'ㄉㄚ') ('de' 'ㄉㄜ') ('dai' 'ㄉㄞ') ('dei' 'ㄉㄟ')
		('dao' 'ㄉㄠ') ('dou' 'ㄉㄡ') ('dan' 'ㄉㄢ') ('den' 'ㄉㄣ')
		('dang' 'ㄉㄤ') ('deng' 'ㄉㄥ') ('di' 'ㄉㄧ') ('die' 'ㄉㄧㄝ')
		('diao' 'ㄉㄧㄠ') ('diu' 'ㄉㄧㄡ') ('dian' 'ㄉㄧㄢ') ('ding' 'ㄉㄧㄥ')
		('du' 'ㄉㄨ') ('duo' 'ㄉㄨㄛ') ('dui' 'ㄉㄨㄟ') ('duan' 'ㄉㄨㄢ')
		('dun' 'ㄉㄨㄣ') ('dong' 'ㄉㄨㄥ')
		('ta' 'ㄊㄚ') ('te' 'ㄊㄜ') ('tai' 'ㄊㄞ') ('tao' 'ㄊㄠ')
		('tou' 'ㄊㄡ') ('tan' 'ㄊㄢ') ('tang' 'ㄊㄤ') ('teng' 'ㄊㄥ')
		('ti' 'ㄊㄧ') ('tie' 'ㄊㄧㄝ') ('tiao' 'ㄊㄧㄠ') ('tian' 'ㄊㄧㄢ')
		('ting' 'ㄊㄧㄥ') ('tu' 'ㄊㄨ') ('tuo' 'ㄊㄨㄛ') ('tui' 'ㄊㄨㄟ')
		('tuan' 'ㄊㄨㄢ') ('tun' 'ㄊㄨㄣ') ('tong' 'ㄊㄨㄥ')
		('na' 'ㄋㄚ') ('ne' 'ㄋㄜ') ('nai' 'ㄋㄞ') ('nei' 'ㄋㄟ')
		('nao' 'ㄋㄠ') ('nou' 'ㄋㄡ') ('nan' 'ㄋㄢ') ('nen' 'ㄋㄣ')
		('nang' 'ㄋㄤ') ('neng' 'ㄋㄥ') ('ni' 'ㄋㄧ') ('nie' 'ㄋㄧㄝ')
		('niao' 'ㄋㄧㄠ') ('niu' 'ㄋㄧㄡ') ('nian' 'ㄋㄧㄢ') ('nin' 'ㄋㄧㄣ')
		('niang' 'ㄋㄧㄤ') ('ning' 'ㄋㄧㄥ') ('nu' 'ㄋㄨ') ('nuo' 'ㄋㄨㄛ')
		('nuan' 'ㄋㄨㄢ') ('nong' 'ㄋㄨㄥ') ('nv' 'ㄋㄩ') ('nve' 'ㄋㄩㄝ')
		('la' 'ㄌㄚ') ('lo' 'ㄌㄛ') ('le' 'ㄌㄜ') ('lai' 'ㄌㄞ')
		('lei' 'ㄌㄟ') ('lao' 'ㄌㄠ') ('lou' 'ㄌㄡ') ('lan' 'ㄌㄢ')
		('lang' 'ㄌㄤ') ('leng' 'ㄌㄥ') ('li' 'ㄌㄧ') ('lie' 'ㄌㄧㄝ')
		('liao' 'ㄌㄧㄠ') ('liu' 'ㄌㄧㄡ') ('lian' 'ㄌㄧㄢ') ('lin' 'ㄌㄧㄣ')
		('liang' 'ㄌㄧㄤ') ('ling' 'ㄌㄧㄥ') ('lu' 'ㄌㄨ') ('luo' 'ㄌㄨㄛ')
		('luan' 'ㄌㄨㄢ') ('lun' 'ㄌㄨㄣ') ('long' 'ㄌㄨㄥ')
		('lv' 'ㄌㄩ') ('lve' 'ㄌㄩㄝ')
		('ga' 'ㄍㄚ') ('ge' 'ㄍㄜ') ('gai' 'ㄍㄞ') ('gei' 'ㄍㄟ')
		('gao' 'ㄍㄠ') ('gou' 'ㄍㄡ') ('gan' 'ㄍㄢ') ('gen' 'ㄍㄣ')
		('gang' 'ㄍㄤ') ('geng' 'ㄍㄥ') ('gu' 'ㄍㄨ') ('gua' 'ㄍㄨㄚ')
		('guo' 'ㄍㄨㄛ') ('guai' 'ㄍㄨㄞ') ('gui' 'ㄍㄨㄟ') ('guan' 'ㄍㄨㄢ')
		('gun' 'ㄍㄨㄣ') ('guang' 'ㄍㄨㄤ') ('gong' 'ㄍㄨㄥ')
		('ka' 'ㄎㄚ') ('ke' 'ㄎㄜ') ('kai' 'ㄎㄞ') ('kei' 'ㄎㄟ')
		('kao' 'ㄎㄠ') ('kou' 'ㄎㄡ') ('kan' 'ㄎㄢ') ('ken' 'ㄎㄣ')
		('kang' 'ㄎㄤ') ('keng' 'ㄎㄥ') ('ku' 'ㄎㄨ') ('kua' 'ㄎㄨㄚ')
		('kuo' 'ㄎㄨㄛ') ('kuai' 'ㄎㄨㄞ') ('kui' 'ㄎㄨㄟ') ('kuan' 'ㄎㄨㄢ')
		('kun' 'ㄎㄨㄣ') ('kuang' 'ㄎㄨㄤ') ('kong' 'ㄎㄨㄥ')
		('ha' 'ㄏㄚ') ('he' 'ㄏㄜ') ('hai' 'ㄏㄞ') ('hei' 'ㄏㄟ')
		('hao' 'ㄏㄠ') ('hou' 'ㄏㄡ') ('han' 'ㄏㄢ') ('hen' 'ㄏㄣ')
		('hang' 'ㄏㄤ') ('heng' 'ㄏㄥ') ('hu' 'ㄏㄨ') ('hua' 'ㄏㄨㄚ')
		('huo' 'ㄏㄨㄛ') ('huai' 'ㄏㄨㄞ') ('hui' 'ㄏㄨㄟ') ('huan' 'ㄏㄨㄢ')
		('hun' 'ㄏㄨㄣ') ('huang' 'ㄏㄨㄤ') ('hong' 'ㄏㄨㄥ')
		('ji' 'ㄐㄧ') ('jia' 'ㄐㄧㄚ') ('jie' 'ㄐㄧㄝ') ('jiao' 'ㄐㄧㄠ')
		('jiu' 'ㄐㄧㄡ') ('jian' 'ㄐㄧㄢ') ('jin' 'ㄐㄧㄣ') ('jiang' 'ㄐㄧㄤ')
		('jing' 'ㄐㄧㄥ') ('ju' 'ㄐㄩ') ('jue' 'ㄐㄩㄝ') ('juan' 'ㄐㄩㄢ')
		('jun' 'ㄐㄩㄣ') ('jiong' 'ㄐㄩㄥ')
		('qi' 'ㄑㄧ') ('qia' 'ㄑㄧㄚ') ('qie' 'ㄑㄧㄝ') ('qiao' 'ㄑㄧㄠ')
		('qiu' 'ㄑㄧㄡ') ('qian' 'ㄑㄧㄢ') ('qin' 'ㄑㄧㄣ') ('qiang' 'ㄑㄧㄤ')
		('qing' 'ㄑㄧㄥ') ('qu' 'ㄑㄩ') ('que' 'ㄑㄩㄝ') ('quan' 'ㄑㄩㄢ')
		('qun' 'ㄑㄩㄣ') ('qiong' 'ㄑㄩㄥ')
		('xi' 'ㄒㄧ') ('xia' 'ㄒㄧㄚ') ('xie' 'ㄒㄧㄝ') ('xiao' 'ㄒㄧㄠ')
		('xiu' 'ㄒㄧㄡ') ('xian' 'ㄒㄧㄢ') ('xin' 'ㄒㄧㄣ') ('xiang' 'ㄒㄧㄤ')
		('xing' 'ㄒㄧㄥ') ('xu' 'ㄒㄩ') ('xue' 'ㄒㄩㄝ') ('xuan' 'ㄒㄩㄢ')
		('xun' 'ㄒㄩㄣ') ('xiong' 'ㄒㄩㄥ')
		('zha' 'ㄓㄚ') ('zhe' 'ㄓㄜ') ('zhi' 'ㄓ') ('zhai' 'ㄓㄞ')
		('zhei' 'ㄓㄟ') ('zhao' 'ㄓㄠ') ('zhou' 'ㄓㄡ') ('zhan' 'ㄓㄢ')
		('zhen' 'ㄓㄣ') ('zhang' 'ㄓㄤ') ('zheng' 'ㄓㄥ') ('zhu' 'ㄓㄨ')
		('zhua' 'ㄓㄨㄚ') ('zhuo' 'ㄓㄨㄛ') ('zhuai' 'ㄓㄨㄞ') ('zhui' 'ㄓㄨㄟ')
		('zhuan' 'ㄓㄨㄢ') ('zhun' 'ㄓㄨㄣ') ('zhuang' 'ㄓㄨㄤ') ('zhong' 'ㄓㄨㄥ')
		('cha' 'ㄔㄚ') ('che' 'ㄔㄜ') ('chi' 'ㄔ') ('chai' 'ㄔㄞ')
		('chao' 'ㄔㄠ') ('chou' 'ㄔㄡ') ('chan' 'ㄔㄢ') ('chen' 'ㄔㄣ')
		('chang' 'ㄔㄤ') ('cheng' 'ㄔㄥ') ('chu' 'ㄔㄨ') ('chua' 'ㄔㄨㄚ')
		('chuo' 'ㄔㄨㄛ') ('chuai' 'ㄔㄨㄞ') ('chui' 'ㄔㄨㄟ') ('chuan' 'ㄔㄨㄢ')
		('chun' 'ㄔㄨㄣ') ('chuang' 'ㄔㄨㄤ') ('chong' 'ㄔㄨㄥ')
		('sha' 'ㄕㄚ') ('she' 'ㄕㄜ') ('shi' 'ㄕ') ('shai' 'ㄕㄞ')
		('shei' 'ㄕㄟ') ('shao' 'ㄕㄠ') ('shou' 'ㄕㄡ') ('shan' 'ㄕㄢ')
		('shen' 'ㄕㄣ') ('shang' 'ㄕㄤ') ('sheng' 'ㄕㄥ') ('shu' 'ㄕㄨ')
		('shua' 'ㄕㄨㄚ') ('shuo' 'ㄕㄨㄛ') ('shuai' 'ㄕㄨㄞ') ('shui' 'ㄕㄨㄟ')
		('shuan' 'ㄕㄨㄢ') ('shun' 'ㄕㄨㄣ') ('shuang' 'ㄕㄨㄤ')
		('re' 'ㄖㄜ') ('ri' 'ㄖ') ('rao' 'ㄖㄠ') ('rou' 'ㄖㄡ')
		('ran' 'ㄖㄢ') ('ren' 'ㄖㄣ') ('rang' 'ㄖㄤ') ('reng' 'ㄖㄥ')
		('ru' 'ㄖㄨ') ('rua' 'ㄖㄨㄚ') ('ruo' 'ㄖㄨㄛ') ('rui' 'ㄖㄨㄟ')
		('ruan' 'ㄖㄨㄢ') ('run' 'ㄖㄨㄣ') ('rong' 'ㄖㄨㄥ')
		('za' 'ㄗㄚ') ('ze' 'ㄗㄜ') ('zi' 'ㄗ') ('zai' 'ㄗㄞ')
		('zei' 'ㄗㄟ') ('zao' 'ㄗㄠ') ('zou' 'ㄗㄡ') ('zan' 'ㄗㄢ')
		('zen' 'ㄗㄣ') ('zang' 'ㄗㄤ') ('zeng' 'ㄗㄥ') ('zu' 'ㄗㄨ')
		('zuo' 'ㄗㄨㄛ') ('zui' 'ㄗㄨㄟ') ('zuan' 'ㄗㄨㄢ') ('zun' 'ㄗㄨㄣ')
		('zong' 'ㄗㄨㄥ')
		('ca' 'ㄘㄚ') ('ce' 'ㄘㄜ') ('ci' 'ㄘ') ('cai' 'ㄘㄞ')
		('cao' 'ㄘㄠ') ('cou' 'ㄘㄡ') ('can' 'ㄘㄢ') ('cen' 'ㄘㄣ')
		('cang' 'ㄘㄤ') ('ceng' 'ㄘㄥ') ('cu' 'ㄘㄨ') ('cuo' 'ㄘㄨㄛ')
		('cui' 'ㄘㄨㄟ') ('cuan' 'ㄘㄨㄢ') ('cun' 'ㄘㄨㄣ') ('cong' 'ㄘㄨㄥ')
		('sa' 'ㄙㄚ') ('se' 'ㄙㄜ') ('si' 'ㄙ') ('sai' 'ㄙㄞ')
		('sao' 'ㄙㄠ') ('sou' 'ㄙㄡ') ('san' 'ㄙㄢ') ('sen' 'ㄙㄣ')
		('sang' 'ㄙㄤ') ('seng' 'ㄙㄥ') ('su' 'ㄙㄨ') ('suo' 'ㄙㄨㄛ')
		('sui' 'ㄙㄨㄟ') ('suan' 'ㄙㄨㄢ') ('sun' 'ㄙㄨㄣ') ('song' 'ㄙㄨㄥ')
	) do: [ :pair | t at: pair first put: pair second ].
	^ t
]

{ #category : 'conversion' }
PinyinBopomofo class >> convert: pinyinString [
	"I convert a pinyin string like 'ni3 hao3' to BoPoMoFo."
	^ ' ' join: ((Character space split: pinyinString)
		collect: [ :syl | self convertSyllable: syl ])
]

{ #category : 'conversion' }
PinyinBopomofo class >> convertSyllable: aString [
	"I convert a single pinyin syllable like 'hao3' to BoPoMoFo. CC-CEDICT writes ü as 'u:' (e.g. 'nu:3'); I normalise that to 'v' so the existing nv/lv table entries match."
	| lower tone base bpmf |
	lower := aString asLowercase copyReplaceAll: 'u:' with: 'v'.
	tone := lower last isDigit
		ifTrue: [ lower last digitValue ]
		ifFalse: [ 5 ].
	base := lower last isDigit
		ifTrue: [ lower allButLast ]
		ifFalse: [ lower ].
	bpmf := self table at: base ifAbsent: [ ^ aString ].
	^ bpmf , (self toneMarkFor: tone)
]

{ #category : 'initialization' }
PinyinBopomofo class >> initialize [
	Table := nil
]

{ #category : 'accessing' }
PinyinBopomofo class >> table [
	^ Table ifNil: [ Table := self buildTable ]
]

{ #category : 'conversion' }
PinyinBopomofo class >> toneMarkFor: aToneNumber [
	aToneNumber = 1 ifTrue: [ ^ '' ].
	aToneNumber = 2 ifTrue: [ ^ 'ˊ' ].
	aToneNumber = 3 ifTrue: [ ^ 'ˇ' ].
	aToneNumber = 4 ifTrue: [ ^ 'ˋ' ].
	^ '˙'
]
