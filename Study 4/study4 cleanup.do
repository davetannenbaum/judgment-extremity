** =======================================
** This file: study4 cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 4/"
import delimited "study4 raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// droping extra row of labels
drop in 1
// converting string to numeric data
quietly destring, replace
// compressing data
compress

** renaming variables and general clean-up
** note: requires 'encoder' program from SSC
** ---------------------------------------
gen id = _n
encoder cond, replace
rename v8 startdate
rename v9 enddate
rename score prac_score
rename score3 block1score
rename score5 block2score
rename v1722 knowledge
rename q45_1 age
rename v1733 gender
rename v1734 english
rename q7* prac_response*
rename q23* prac_correct*
rename fixed? block1_response?
rename fixed?? block1_response??
rename q34* block1_correct*
rename random? block2_response?
rename random?? block2_response??
rename q40* block2_correct*
rename q38_1* prob*
rename q29_* strength*
rename q47_* knowledge*

** generating new id variable
** ---------------------------------------
drop id
generate id = _n

** recoding variables
** ---------------------------------------
// practice responses
foreach var of varlist prac_response* {
	replace `var' = `var' - 1
}
// # of correct responses in practice block
foreach var of varlist prac_correct* {
	replace `var' = 0 if `var' == .
}
// block 1 responses
foreach var of varlist block1_response* {
	replace `var' = `var' - 2
}
// # of correct responses in block 1
foreach var of varlist block1_correct* {
	replace `var' = 0 if `var' == .
}
// block 2 responses
foreach var of varlist block2_response* {
	replace `var' = `var' - 2
}
// # of correct responses in block 2
foreach var of varlist block2_correct* {
	replace `var' = 0 if `var' == .
}

** renaming epistemicness variables
** ---------------------------------------
forvalues i = 1/28 {
	rename q42_1`i' ea`i'1
	rename q42_2`i' ea`i'2
	rename q42_3`i' ea`i'3
	rename q42_4`i' ea`i'4
	rename q42_5`i' ea`i'5
	rename q42_6`i' ea`i'6
	rename q42_7`i' ea`i'7
	rename q42_8`i' ea`i'8
	rename q42_9`i' ea`i'9
	rename q42_10`i' ea`i'10
}

** examine factor structure
** ---------------------------------------
preserve
egen ea1 = rowmean(ea*1)
egen ea2 = rowmean(ea*2)
egen ea3 = rowmean(ea*3)
egen ea4 = rowmean(ea*4)
egen ea5 = rowmean(ea*5)
egen ea6 = rowmean(ea*6)
egen ea7 = rowmean(ea*7)
egen ea8 = rowmean(ea*8)
egen ea9 = rowmean(ea*9)
egen ea10 = rowmean(ea*10)
factor ea1-ea10, ipf factors(2)
rotate, oblique quartimin
estat common
restore

** generating E and A items
** ---------------------------------------
forvalues i = 1/28 {
	alpha ea`i'1 ea`i'3 ea`i'5 ea`i'8 ea`i'9 ea`i'10, gen(e`i') asis
}
forvalues i = 1/28 {
	alpha ea`i'2 ea`i'4 ea`i'6 ea`i'7, gen(a`i') asis
}

** reverse coding aleatory items
** ---------------------------------------
forvalues i = 1/28 {
	replace ea`i'2 = 8 - ea`i'2
	replace ea`i'4 = 8 - ea`i'4
	replace ea`i'6 = 8 - ea`i'6
	replace ea`i'7 = 8 - ea`i'7
}

** generating epistemicness items
** ---------------------------------------
forvalues i = 1/28 {
	alpha ea`i'1 ea`i'2 ea`i'3 ea`i'4 ea`i'5 ea`i'6 ea`i'7 ea`i'8 ea`i'9 ea`i'10, gen(epistem`i') asis
}

** generating focal and foil items
** ---------------------------------------
generate focal1 = strength1 if target == 1
generate focal2 = strength1 if target == 1
generate focal3 = strength4 if target == 1
generate focal4 = strength1 if target == 1
generate focal5 = strength1 if target == 1
generate focal6 = strength1 if target == 1
generate focal7 = strength1 if target == 1
generate focal8 = strength3 if target == 1
generate focal9 = strength4 if target == 1
generate focal10 = strength2 if target == 1
generate focal11 = strength6 if target == 1
generate focal12 = strength2 if target == 1
generate focal13 = strength8 if target == 1
generate focal14 = strength4 if target == 1
generate focal15 = strength3 if target == 1
generate focal16 = strength3 if target == 1
generate focal17 = strength3 if target == 1
generate focal18 = strength8 if target == 1
generate focal19 = strength4 if target == 1
generate focal20 = strength6 if target == 1
generate focal21 = strength7 if target == 1
generate focal22 = strength4 if target == 1
generate focal23 = strength5 if target == 1
generate focal24 = strength5 if target == 1
generate focal25 = strength5 if target == 1
generate focal26 = strength7 if target == 1
generate focal27 = strength8 if target == 1
generate focal28 = strength8 if target == 1

generate foil1 = strength2 if target == 1
generate foil2 = strength3 if target == 1
generate foil3 = strength1 if target == 1
generate foil4 = strength5 if target == 1
generate foil5 = strength6 if target == 1
generate foil6 = strength7 if target == 1
generate foil7 = strength8 if target == 1
generate foil8 = strength2 if target == 1
generate foil9 = strength2 if target == 1
generate foil10 = strength5 if target == 1
generate foil11 = strength2 if target == 1
generate foil12 = strength7 if target == 1
generate foil13 = strength2 if target == 1
generate foil14 = strength3 if target == 1
generate foil15 = strength5 if target == 1
generate foil16 = strength6 if target == 1
generate foil17 = strength7 if target == 1
generate foil18 = strength3 if target == 1
generate foil19 = strength5 if target == 1
generate foil20 = strength4 if target == 1
generate foil21 = strength4 if target == 1
generate foil22 = strength8 if target == 1
generate foil23 = strength6 if target == 1
generate foil24 = strength7 if target == 1
generate foil25 = strength8 if target == 1
generate foil26 = strength6 if target == 1
generate foil27 = strength6 if target == 1
generate foil28 = strength7 if target == 1

replace focal1 = strength2 if target == 0
replace focal2 = strength3 if target == 0
replace focal3 = strength1 if target == 0
replace focal4 = strength5 if target == 0
replace focal5 = strength6 if target == 0
replace focal6 = strength7 if target == 0
replace focal7 = strength8 if target == 0
replace focal8 = strength2 if target == 0
replace focal9 = strength2 if target == 0
replace focal10 = strength5 if target == 0
replace focal11 = strength2 if target == 0
replace focal12 = strength7 if target == 0
replace focal13 = strength2 if target == 0
replace focal14 = strength3 if target == 0
replace focal15 = strength5 if target == 0
replace focal16 = strength6 if target == 0
replace focal17 = strength7 if target == 0
replace focal18 = strength3 if target == 0
replace focal19 = strength5 if target == 0
replace focal20 = strength4 if target == 0
replace focal21 = strength4 if target == 0
replace focal22 = strength8 if target == 0
replace focal23 = strength6 if target == 0
replace focal24 = strength7 if target == 0
replace focal25 = strength8 if target == 0
replace focal26 = strength6 if target == 0
replace focal27 = strength6 if target == 0
replace focal28 = strength7 if target == 0

replace foil1 = strength1 if target == 0
replace foil2 = strength1 if target == 0
replace foil3 = strength4 if target == 0
replace foil4 = strength1 if target == 0
replace foil5 = strength1 if target == 0
replace foil6 = strength1 if target == 0
replace foil7 = strength1 if target == 0
replace foil8 = strength3 if target == 0
replace foil9 = strength4 if target == 0
replace foil10 = strength2 if target == 0
replace foil11 = strength6 if target == 0
replace foil12 = strength2 if target == 0
replace foil13 = strength8 if target == 0
replace foil14 = strength4 if target == 0
replace foil15 = strength3 if target == 0
replace foil16 = strength3 if target == 0
replace foil17 = strength3 if target == 0
replace foil18 = strength8 if target == 0
replace foil19 = strength4 if target == 0
replace foil20 = strength6 if target == 0
replace foil21 = strength7 if target == 0
replace foil22 = strength4 if target == 0
replace foil23 = strength5 if target == 0
replace foil24 = strength5 if target == 0
replace foil25 = strength5 if target == 0
replace foil26 = strength7 if target == 0
replace foil27 = strength8 if target == 0
replace foil28 = strength8 if target == 0

** Pruning data set
** ---------------------------------------
keep id cond target order epistem1-epistem28 e1-e28 a1-a28 prac_response* prac_correct* block1_response* block1_correct* block2_response* block2_correct* prob* focal* foil* strength* knowledge age gender english startdate enddate
order id cond target order epistem1-epistem28 e1-e28 a1-a28 prac_response* prac_correct* block1_response* block1_correct* block2_response* block2_correct* prob* focal* foil* strength* knowledge age gender english startdate enddate

** Reshaping data
** ---------------------------------------
reshape long prob focal foil epistem e a strength prac_response prac_correct block1_response block1_correct block2_response block2_correct, i(id) j(blocktrial)

** Generating target variables
** ---------------------------------------
generate teamA = "New York" if inlist(blocktrial,1,2,4,5,6,7) & target == 1 & prob != .
replace teamA = "Austin" if inlist(blocktrial,3,9,14,19,22) & target == 1 & prob != .
replace teamA = "San Francisco" if inlist(blocktrial,8,15,16,17) & target == 1 & prob != .
replace teamA = "San Diego" if inlist(blocktrial,10,12) & target == 1 & prob != .
replace teamA = "CO Springs" if inlist(blocktrial,11,20) & target == 1 & prob != .
replace teamA = "Wichita" if inlist(blocktrial,13,18,27,28) & target == 1 & prob != .
replace teamA = "Albuquerque" if inlist(blocktrial,23,24,25) & target == 1 & prob != .
replace teamA = "Tulsa" if inlist(blocktrial,21,26) & target == 1 & prob != .
replace teamA = "New York" if inlist(blocktrial,3) & target == 0 & prob != .
replace teamA = "Austin" if inlist(blocktrial,20,21) & target == 0 & prob != .
replace teamA = "San Francisco" if inlist(blocktrial,2,14,18) & target == 0 & prob != .
replace teamA = "San Diego" if inlist(blocktrial,1,8,9,11,13) & target == 0 & prob != .
replace teamA = "CO Springs" if inlist(blocktrial,5,16,23,26,27) & target == 0 & prob != .
replace teamA = "Wichita" if inlist(blocktrial,7,22,25) & target == 0 & prob != .
replace teamA = "Albuquerque" if inlist(blocktrial,4,10,15,19) & target == 0 & prob != .
replace teamA = "Tulsa" if inlist(blocktrial,6,12,17,24,28) & target == 0 & prob != .

generate teamB = "New York" if inlist(blocktrial,3) & target == 1 & prob != .
replace teamB = "Austin" if inlist(blocktrial,20,21) & target == 1 & prob != .
replace teamB = "San Francisco" if inlist(blocktrial,2,14,18) & target == 1 & prob != .
replace teamB = "San Diego" if inlist(blocktrial,1,8,9,11,13) & target == 1 & prob != .
replace teamB = "CO Springs" if inlist(blocktrial,5,16,23,26,27) & target == 1 & prob != .
replace teamB = "Wichita" if inlist(blocktrial,7,22,25) & target == 1 & prob != .
replace teamB = "Albuquerque" if inlist(blocktrial,4,10,15,19) & target == 1 & prob != .
replace teamB = "Tulsa" if inlist(blocktrial,6,12,17,24,28) & target == 1 & prob != .
replace teamB = "New York" if inlist(blocktrial,1,2,4,5,6,7) & target == 0 & prob != .
replace teamB = "Austin" if inlist(blocktrial,3,9,14,19,22) & target == 0 & prob != .
replace teamB = "San Francisco" if inlist(blocktrial,8,15,16,17) & target == 0 & prob != .
replace teamB = "San Diego" if inlist(blocktrial,10,12) & target == 0 & prob != .
replace teamB = "CO Springs" if inlist(blocktrial,11,20) & target == 0 & prob != .
replace teamB = "Wichita" if inlist(blocktrial,13,18,27,28) & target == 0 & prob != .
replace teamB = "Albuquerque" if inlist(blocktrial,23,24,25) & target == 0 & prob != .
replace teamB = "Tulsa" if inlist(blocktrial,21,26) & target == 0 & prob != .

** generating question variables
** ---------------------------------------
generate question = .
replace question = 1 if teamA == "Albuquerque" & teamB == "Austin"
replace question = 1 if teamB == "Albuquerque" & teamA == "Austin"
replace question = 2 if teamA == "Albuquerque" & teamB == "CO Springs"
replace question = 2 if teamB == "Albuquerque" & teamA == "CO Springs"
replace question = 3 if teamA == "Albuquerque" & teamB == "New York"
replace question = 3 if teamB == "Albuquerque" & teamA == "New York"
replace question = 4 if teamA == "Albuquerque" & teamB == "San Diego"
replace question = 4 if teamB == "Albuquerque" & teamA == "San Diego"
replace question = 5 if teamA == "Albuquerque" & teamB == "San Francisco"
replace question = 5 if teamB == "Albuquerque" & teamA == "San Francisco"
replace question = 6 if teamA == "Albuquerque" & teamB == "Tulsa"
replace question = 6 if teamB == "Albuquerque" & teamA == "Tulsa"
replace question = 7 if teamA == "Albuquerque" & teamB == "Wichita"
replace question = 7 if teamB == "Albuquerque" & teamA == "Wichita"
replace question = 8 if teamA == "Austin" & teamB == "CO Springs"
replace question = 8 if teamB == "Austin" & teamA == "CO Springs"
replace question = 9 if teamA == "Austin" & teamB == "New York"
replace question = 9 if teamB == "Austin" & teamA == "New York"
replace question = 10 if teamA == "Austin" & teamB == "San Diego"
replace question = 10 if teamB == "Austin" & teamA == "San Diego"
replace question = 11 if teamA == "Austin" & teamB == "San Francisco"
replace question = 11 if teamB == "Austin" & teamA == "San Francisco"
replace question = 12 if teamA == "Austin" & teamB == "Tulsa"
replace question = 12 if teamB == "Austin" & teamA == "Tulsa"
replace question = 13 if teamA == "Austin" & teamB == "Wichita"
replace question = 13 if teamB == "Austin" & teamA == "Wichita"
replace question = 14 if teamA == "CO Springs" & teamB == "New York"
replace question = 14 if teamB == "CO Springs" & teamA == "New York"
replace question = 15 if teamA == "CO Springs" & teamB == "San Diego"
replace question = 15 if teamB == "CO Springs" & teamA == "San Diego"
replace question = 16 if teamA == "CO Springs" & teamB == "San Francisco"
replace question = 16 if teamB == "CO Springs" & teamA == "San Francisco"
replace question = 17 if teamA == "CO Springs" & teamB == "Tulsa"
replace question = 17 if teamB == "CO Springs" & teamA == "Tulsa"
replace question = 18 if teamA == "CO Springs" & teamB == "Wichita"
replace question = 18 if teamB == "CO Springs" & teamA == "Wichita"
replace question = 19 if teamA == "New York" & teamB == "San Diego"
replace question = 19 if teamB == "New York" & teamA == "San Diego"
replace question = 20 if teamA == "New York" & teamB == "San Francisco"
replace question = 20 if teamB == "New York" & teamA == "San Francisco"
replace question = 21 if teamA == "New York" & teamB == "Tulsa"
replace question = 21 if teamB == "New York" & teamA == "Tulsa"
replace question = 22 if teamA == "New York" & teamB == "Wichita"
replace question = 22 if teamB == "New York" & teamA == "Wichita"
replace question = 23 if teamA == "San Diego" & teamB == "San Francisco"
replace question = 23 if teamB == "San Diego" & teamA == "San Francisco"
replace question = 24 if teamA == "San Diego" & teamB == "Tulsa"
replace question = 24 if teamB == "San Diego" & teamA == "Tulsa"
replace question = 25 if teamA == "San Diego" & teamB == "Wichita"
replace question = 25 if teamB == "San Diego" & teamA == "Wichita"
replace question = 26 if teamA == "San Francisco" & teamB == "Tulsa"
replace question = 26 if teamB == "San Francisco" & teamA == "Tulsa"
replace question = 27 if teamA == "San Francisco" & teamB == "Wichita"
replace question = 27 if teamB == "San Francisco" & teamA == "Wichita"
replace question = 28 if teamA == "Tulsa" & teamB == "Wichita"
replace question = 28 if teamB == "Tulsa" & teamA == "Wichita"

** transforming probability variable
** ---------------------------------------
replace prob = prob * .01

** generating extremity measures
** ---------------------------------------
generate extremity = abs(.50 - prob)
generate upper = prob if prob > .50
generate lower = prob if prob < .50
generate p100 = inrange(prob,0,0) | inrange(prob,1,1)

** Generating Log Odds and Strength Ratios
** ---------------------------------------
// compressing probability scale (requires 'distinct' package)
tempvar prob2
generate `prob2' = prob
distinct id
replace `prob2' = [.5]/r(ndistinct) if `prob2' == 0
replace `prob2' = [(r(ndistinct) - 1) + .5]/r(ndistinct) if `prob2' == 1

// creating complement probability
tempvar c_prob
generate `c_prob' = 1 - `prob2'

// generating log odds
generate dv = ln(`prob2'/`c_prob')

// generating log strength ratios
generate support = ln(focal/foil)

** dropping subjects with negative Ks
** ---------------------------------------
generate coeff = .
levelsof id, local(list)
foreach item in `list' {
	capture regress dv support if id == `item'
	capture replace coeff = _b[support] if id == `item'
}
drop if coeff < 0

** Calibration analysis (note: weather data was collected from Wolfram Alpha)
** ---------------------------------------
// judged probability
generate jp = abs(prob - .50) + .50

// weather data
generate weatherA = 75 if teamA == "New York"
generate weatherB = 75 if teamB == "New York"
replace weatherA = 88 if teamA == "San Diego"
replace weatherB = 88 if teamB == "San Diego"
replace weatherA = 91 if teamA == "Austin"
replace weatherB = 91 if teamB == "Austin"
replace weatherA = 86 if teamA == "Albuquerque"
replace weatherB = 86 if teamB == "Albuquerque"
replace weatherA = 72 if teamA == "CO Springs"
replace weatherB = 72 if teamB == "CO Springs"
replace weatherA = 86 if teamA == "Tulsa"
replace weatherB = 86 if teamB == "Tulsa"
replace weatherA = 84 if teamA == "Wichita"
replace weatherB = 84 if teamB == "Wichita"
replace weatherA = 76 if teamA == "San Francisco"
replace weatherB = 76 if teamB == "San Francisco"
generate outcome = 1 if weatherA > weatherB & weatherA != .
replace outcome = 0 if weatherA <= weatherB & weatherA != .

//  hit rates
set seed 12345
generate pc = 1 if prob > .5 & outcome == 1
replace pc = 0 if prob < .5 & outcome == 1 
replace pc = 1 if prob < .5 & outcome == 0 
replace pc = 0 if prob > .5 & outcome == 0
replace pc = int((1+1)*runiform()) if prob == .5

// item difficulty
generate diff = .
forvalues i = 1/28 {
	sum pc if question == `i'
	replace diff = r(mean) if question == `i'
}

// brier score
generate brier = (prob - outcome)^2

// classifcation bins
egen bin = cut(prob), at(0[.100001]1.1) icode
table bin, c(min prob max prob)
generate Oj = . 
generate resolution = .
generate reliability = .
generate outcomevar = .

// Calibration and Discrimination
forvalues i = 0/9 {
	summarize outcome if bin == `i'
	replace Oj = r(mean) if bin == `i'
	replace reliability = (prob - Oj)^2 if bin == `i'
	summarize outcome, detail
	replace resolution = (Oj - r(mean))^2 if bin == `i'
	replace outcomevar = r(Var)
}

** pruning and reordering final data set
** --------------------------------------- 
keep id question cond target order prob extremity upper lower p100 dv support epistem e a focal foil coeff jp outcome diff pc brier bin Oj resolution reliability outcomevar block1_response block1_correct block2_response block2_correct knowledge  focal foil teamA teamB age gender
order id question cond target order prob extremity upper lower p100 dv support epistem e a focal foil coeff jp outcome diff pc brier bin Oj resolution reliability outcomevar block1_response block1_correct block2_response block2_correct knowledge  focal foil teamA teamB age gender

** Exporting data
** --------------------------------------- 
export delimited using "study4 final data.csv", nolabel replace