Class {
	#name : 'BaselineOfGtChineseDict',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGtChineseDict',
	#package : 'BaselineOfGtChineseDict'
}

{ #category : 'baselines' }
BaselineOfGtChineseDict >> baseline: spec [
	<baseline>
	spec for: #common do: [
		spec package: 'GtChineseDict' ]
]
