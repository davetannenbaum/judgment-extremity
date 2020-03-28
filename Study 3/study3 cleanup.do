** =======================================
** This file: study3 cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 3/"
import delimited "study3 raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// droping extra row of labels
drop in 1
// converting string to numeric data
quietly destring, replace
// compressing data
compress

** renaming variables
** ---------------------------------------
rename know1 knowledge
rename q12_1 age
rename q16 gender
rename dobrfl_103 blockorder
rename v445 external_sources
rename q35 comments

** drop subjects who report using external sources
** ---------------------------------------
drop if external_sources == 1

** generating probability judgments
** ---------------------------------------
forvalues i = 1/15 {
	rename q17_2`i' avg`i'a
	rename q2_1`i' avg`i'b
	rename q82_2`i' random`i'a
	rename q83_1`i' random`i'b
} 
forvalues i = 1/15 {
	egen avg`i' = rowfirst(avg`i'a avg`i'b)
	egen random`i' = rowfirst(random`i'a random`i'b)
}

** renaming epistemicness ratings
** ---------------------------------------
forvalues i = 1/15 {
	rename q64_1`i' avg_ea`i'_1
	rename q64_2`i' avg_ea`i'_2
	rename q64_3`i' avg_ea`i'_3
	rename q64_4`i' avg_ea`i'_4
	rename q64_5`i' avg_ea`i'_5
	rename q64_6`i' avg_ea`i'_6
	rename q64_7`i' avg_ea`i'_7
	rename q64_8`i' avg_ea`i'_8
	rename q64_9`i' avg_ea`i'_9
	rename q64_10`i' avg_ea`i'_10 
	rename q86_1`i' random_ea`i'_1
	rename q86_2`i' random_ea`i'_2
	rename q86_3`i' random_ea`i'_3
	rename q86_4`i' random_ea`i'_4
	rename q86_5`i' random_ea`i'_5
	rename q86_6`i' random_ea`i'_6
	rename q86_7`i' random_ea`i'_7
	rename q86_8`i' random_ea`i'_8
	rename q86_9`i' random_ea`i'_9
	rename q86_10`i' random_ea`i'_10
}

** Reverse coding aleatory items
** ---------------------------------------
forvalues i = 1/15 {
	foreach var of varlist *ea`i'_2 *ea`i'_4 *ea`i'_6 *ea`i'_7 {
		replace `var' = 8 - `var'
	}
}

** Creating epistemicness indices
** ---------------------------------------
forvalues i = 1/15 {
	alpha avg_ea`i'_*, gen(avg_EA`i') asis
	alpha random_ea`i'_*, gen(random_EA`i') asis
}

** pruning data set and reshaping data
** ---------------------------------------
drop avg*a avg*b random*a random*b avg_ea*_* random_ea*_*
keep order blockorder avg* random* avg_* random_* strength* knowledge gender age comments
gen id = _n
reshape long avg random avg_EA random_EA, i(id) j(trial)

** further reshaping
** ---------------------------------------
rename avg prob1
rename random prob2
rename avg_EA ea1
rename random_EA ea2
generate j = _n
reshape long prob ea, i(j) j(task)
replace task = task - 1
label define taskl 0 "average" 1 "random day"
label val task taskl
drop j

** strength ratios
** ---------------------------------------
rename strength_1 anchorage
rename strength_2 indianapolis
rename strength_3 minneapolis
rename strength_4 phoenix
rename strength_5 sandiego
rename strength_6 sanfran
generate cityA = .
replace cityA = indianapolis if trial == 1
replace cityA = anchorage if trial == 2
replace cityA = phoenix if trial == 3
replace cityA = sandiego if trial == 4
replace cityA = sanfran if trial == 5
replace cityA = indianapolis if trial == 6
replace cityA = indianapolis if trial == 7
replace cityA = indianapolis if trial == 8
replace cityA = sanfran if trial == 9
replace cityA = phoenix if trial == 10
replace cityA = minneapolis if trial == 11
replace cityA = minneapolis if trial == 12
replace cityA = phoenix if trial == 13
replace cityA = phoenix if trial == 14
replace cityA = sandiego if trial == 15
generate cityB = .
replace cityB = anchorage if trial == 1
replace cityB = minneapolis if trial == 2
replace cityB = anchorage if trial == 3
replace cityB = anchorage if trial == 4
replace cityB = anchorage if trial == 5
replace cityB = minneapolis if trial == 6
replace cityB = phoenix if trial == 7
replace cityB = sandiego if trial == 8
replace cityB = indianapolis if trial == 9
replace cityB = minneapolis if trial == 10
replace cityB = sandiego if trial == 11
replace cityB = sanfran if trial == 12
replace cityB = sandiego if trial == 13
replace cityB = sanfran if trial == 14
replace cityB = sanfran if trial == 15
generate focal = .
replace focal = cityA if order == 0
replace focal = cityB if order == 1
generate foil = .
replace foil = cityB if order == 0
replace foil = cityA if order == 1

** generating block order
** ---------------------------------------
encode blockorder, gen(newblockorder)
drop blockorder
rename newblockorder blockorder
replace blockorder = blockorder - 1
generate block = .
replace block = 1 if task == 0 & blockorder == 0
replace block = 1 if task == 1 & blockorder == 1
replace block = 2 if task == 0 & blockorder == 1
replace block = 2 if task == 1 & blockorder == 0

** recoding probility judgments
** ---------------------------------------
replace prob = prob * .01

** Generating extremity measures
** ---------------------------------------
generate extremity = abs(.50 - prob)
generate upper = prob if prob > .50 & prob != .
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

// dropping incorrect use of support scale
drop if focal == 0
drop if foil == 0

** more renaming
** ---------------------------------------
rename trial question
rename order target

** dropping subjects with negative Ks (requires 'xfill' package)
** ---------------------------------------
drop if support == .
egen pairing = group(id task)
generate coeff = .
levelsof pairing, local(list)
foreach item in `list' {
	capture regress dv support if pairing == `item'
	capture replace coeff = _b[support] if pairing == `item'
}
tempvar flag
generate `flag' = 1 if coeff < 0
xfill `flag', i(id)
drop if `flag' == 1

// removing temp variables
drop _*

** pruning and reordering final data set
** --------------------------------------- 
keep id task question target prob extremity upper lower p100 dv ea focal foil support pairing coeff knowledge age gender block
order id task question target prob extremity upper lower p100 dv ea focal foil support pairing coeff knowledge age gender block

** Exporting data
** --------------------------------------- 
export delimited using "study3 final data.csv", nolabel replace