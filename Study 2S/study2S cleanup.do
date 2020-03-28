** ======================================
** This file: study2S cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 2S/"
import delimited "study2S raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// converting string to numeric data
quietly destring, replace
// compressing data
compress

** Remove two duplicate rows
** (requires 'duplicate' package)
** ---------------------------------------
duplicates drop sessn_id, force

** Dropping one subject for using external sources
** ---------------------------------------
drop if external == 1

** Renaming variables
** ---------------------------------------
foreach var of varlist domain focal foil prob {
	rename `var' `var'0
}
order _all, sequential
gen id = _n

** Reverse coding aleatory items
** ---------------------------------------
foreach var of varlist *_ea04 *_ea05 *_ea06 *_ea07 {
	replace `var' = 8 - `var'
}

** Generating epistemiciness scores
** ---------------------------------------
alpha bball_ea*, gen(bball_ea)
alpha geo_ea*, gen(geo_ea)
alpha temp_ea*, gen(temp_ea)

** Reshaping data
** ---------------------------------------
reshape long domain focal foil prob, i(id) j(trial)

** Some small additional cleanup
** ---------------------------------------
replace trial = trial + 1
encode domain, gen(newdomain)
drop domain
rename newdomain domain
recode domain (1 = 0 "basketball") (2 = 2 "geography") (3 = 1 "temp"), gen(domain2)
drop domain
rename domain2 domain

** Generating strength rating items
** ---------------------------------------
encode focal if domain == 0, gen(focala)
encode focal if domain == 1, gen(focalb)
encode focal if domain == 2, gen(focalc)
bysort id: gen Focal = focala if focala != .
bysort id: replace Focal = focalb if focalb != .
bysort id: replace Focal = focalc if focalc != .
drop focala focalb focalc
rencode foil if domain == 0, gen(foila)
rencode foil if domain == 1, gen(foilb)
rencode foil if domain == 2, gen(foilc)
bysort id: gen Foil = foila if foila != .
bysort id: replace Foil = foilb if foilb != .
bysort id: replace Foil = foilc if foilc != .
drop foila foilb foilc
generate support_focal = strength_bball1 if domain == 0 & Focal == 2
replace support_focal = strength_bball2 if domain == 0 & Focal == 6
replace support_focal = strength_bball3 if domain == 0 & Focal == 3
replace support_focal = strength_bball4 if domain == 0 & Focal == 5
replace support_focal = strength_bball5 if domain == 0 & Focal == 4
replace support_focal = strength_bball6 if domain == 0 & Focal == 8
replace support_focal = strength_bball7 if domain == 0 & Focal == 1
replace support_focal = strength_bball8 if domain == 0 & Focal == 7
replace support_focal = strength_temp1 if domain == 1 & Focal == 1
replace support_focal = strength_temp2 if domain == 1 & Focal == 2
replace support_focal = strength_temp3 if domain == 1 & Focal == 3
replace support_focal = strength_temp4 if domain == 1 & Focal == 5
replace support_focal = strength_temp5 if domain == 1 & Focal == 4
replace support_focal = strength_temp6 if domain == 1 & Focal == 6
replace support_focal = strength_temp7 if domain == 1 & Focal == 7
replace support_focal = strength_temp8 if domain == 1 & Focal == 8
replace support_focal = strength_geo1 if domain == 2 & Focal == 1
replace support_focal = strength_geo2 if domain == 2 & Focal == 2
replace support_focal = strength_geo3 if domain == 2 & Focal == 3
replace support_focal = strength_geo4 if domain == 2 & Focal == 4
replace support_focal = strength_geo5 if domain == 2 & Focal == 5
replace support_focal = strength_geo6 if domain == 2 & Focal == 6
replace support_focal = strength_geo7 if domain == 2 & Focal == 7
replace support_focal = strength_geo8 if domain == 2 & Focal == 8
generate support_foil = strength_bball1 if domain == 0 & Foil == 2
replace support_foil = strength_bball2 if domain == 0 & Foil == 6
replace support_foil = strength_bball3 if domain == 0 & Foil == 3
replace support_foil = strength_bball4 if domain == 0 & Foil == 5
replace support_foil = strength_bball5 if domain == 0 & Foil == 4
replace support_foil = strength_bball6 if domain == 0 & Foil == 8
replace support_foil = strength_bball7 if domain == 0 & Foil == 1
replace support_foil = strength_bball8 if domain == 0 & Foil == 7
replace support_foil = strength_temp1 if domain == 1 & Foil == 1
replace support_foil = strength_temp2 if domain == 1 & Foil == 2
replace support_foil = strength_temp3 if domain == 1 & Foil == 3
replace support_foil = strength_temp4 if domain == 1 & Foil == 5
replace support_foil = strength_temp5 if domain == 1 & Foil == 4
replace support_foil = strength_temp6 if domain == 1 & Foil == 6
replace support_foil = strength_temp7 if domain == 1 & Foil == 7
replace support_foil = strength_temp8 if domain == 1 & Foil == 8
replace support_foil = strength_geo1 if domain == 2 & Foil == 1
replace support_foil = strength_geo2 if domain == 2 & Foil == 2
replace support_foil = strength_geo3 if domain == 2 & Foil == 3
replace support_foil = strength_geo4 if domain == 2 & Foil == 4
replace support_foil = strength_geo5 if domain == 2 & Foil == 5
replace support_foil = strength_geo6 if domain == 2 & Foil == 6
replace support_foil = strength_geo7 if domain == 2 & Foil == 7
replace support_foil = strength_geo8 if domain == 2 & Foil == 8

** Remove responses that fall outside prob scale
** or incorrect use of strength ratings
** ---------------------------------------
drop if prob > 100
drop if support_focal == 0 
drop if support_foil == 0

** Rescaling probability judgments
** ---------------------------------------
replace prob = prob * .01 

** Knowledge Ratings
** ---------------------------------------
gen knowledge = .
replace knowledge = know_bball if domain == 0
replace knowledge = know_temp if domain == 1
replace knowledge = know_geo if domain == 2

** Epistemicness Ratings
** ---------------------------------------
gen epistemicness = .
replace epistemicness = bball_ea if domain == 0
replace epistemicness = temp_ea if domain == 1
replace epistemicness = geo_ea if domain == 2

** Pruning data set and ordering variables
** ---------------------------------------
keep id trial epistemicness prob support* knowledge Focal Foil focal foil domain age gender
order id trial epistemicness prob support* knowledge Focal Foil focal foil domain age gender

** Generating question item
** ---------------------------------------
rename focal targetA
rename foil targetB
rename Focal focal
rename Foil foil

egen pair = group(focal foil) if domain == 0
gen question = 1 if pair == 1 | pair == 9 & domain == 0
replace question = 2 if pair == 2 | pair == 17 & domain == 0
replace question = 3 if pair == 3 | pair == 25 & domain == 0
replace question = 4 if pair == 4 | pair == 29 & domain == 0
replace question = 5 if pair == 5 | pair == 10 & domain == 0
replace question = 6 if pair == 6 | pair == 18 & domain == 0
replace question = 7 if pair == 7 | pair == 26 & domain == 0
replace question = 8 if pair == 8 | pair == 30 & domain == 0
replace question = 9 if pair == 11 | pair == 13 & domain == 0
replace question = 10 if pair == 12 | pair == 21 & domain == 0
replace question = 11 if pair == 14 | pair == 19 & domain == 0
replace question = 12 if pair == 15 | pair == 27 & domain == 0
replace question = 13 if pair == 16 | pair == 31 & domain == 0
replace question = 14 if pair == 20 | pair == 22 & domain == 0
replace question = 15 if pair == 23 | pair == 28 & domain == 0
replace question = 16 if pair == 24 | pair == 32 & domain == 0
drop pair
egen pair = group(focal foil) if domain == 1
replace question = 1 if pair == 1 | pair == 17 & domain == 1
replace question = 2 if pair == 2 | pair == 21 & domain == 1
replace question = 3 if pair == 3 | pair == 25 & domain == 1
replace question = 4 if pair == 4 | pair == 29 & domain == 1
replace question = 5 if pair == 5 | pair == 18 & domain == 1
replace question = 6 if pair == 6 | pair == 22 & domain == 1
replace question = 7 if pair == 7 | pair == 26 & domain == 1
replace question = 8 if pair == 8 | pair == 30 & domain == 1
replace question = 9 if pair == 9 | pair == 19 & domain == 1
replace question = 10 if pair == 10 | pair == 23 & domain == 1
replace question = 11 if pair == 11 | pair == 27 & domain == 1
replace question = 12 if pair == 12 | pair == 31 & domain == 1
replace question = 13 if pair == 13 | pair == 20 & domain == 1
replace question = 14 if pair == 14 | pair == 24 & domain == 1
replace question = 15 if pair == 15 | pair == 28 & domain == 1
replace question = 16 if pair == 16 | pair == 32 & domain == 1
drop pair
egen pair = group(focal foil) if domain == 2 
replace question = 1 if pair == 1 | pair == 9 & domain == 2
replace question = 2 if pair == 2 | pair == 13 & domain == 2
replace question = 3 if pair == 3 | pair == 25 & domain == 2
replace question = 4 if pair == 4 | pair == 29 & domain == 2
replace question = 5 if pair == 5 | pair == 10 & domain == 2
replace question = 6 if pair == 6 | pair == 14 & domain == 2
replace question = 7 if pair == 7 | pair == 26 & domain == 2
replace question = 8 if pair == 8 | pair == 30 & domain == 2
replace question = 9 if pair == 11 | pair == 17 & domain == 2
replace question = 10 if pair == 12 | pair == 21 & domain == 2
replace question = 11 if pair == 15 | pair == 18 & domain == 2
replace question = 12 if pair == 16 | pair == 22 & domain == 2
replace question = 13 if pair == 19 | pair == 27 & domain == 2
replace question = 14 if pair == 20 | pair == 31 & domain == 2
replace question = 15 if pair == 23 | pair == 28 & domain == 2
replace question = 16 if pair == 24 | pair == 32 & domain == 2
drop pair

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
generate support = ln(support_focal/support_foil)

** Dropping subjects with negative Ks
** (requires 'xfill' package)
** ---------------------------------------
generate coeff = .
forvalues i = 1/36 {
	forvalues j = 0/2 {
		regress dv support if id == `i' & domain == `j'
		replace coeff = _b[support] if id == `i' & domain == `j'
	}
}
tempvar flag
generate `flag' = 1 if coeff < 0
xfill `flag', i(id)
drop if `flag' == 1

// dropping temp variables
drop _*

** Generating extremity measures
** ---------------------------------------
generate extremity = abs(.50 - prob)
generate upper = prob if prob > .50 & prob != .
generate lower = prob if prob < .50
generate p100 = inrange(prob,0,0) | inrange(prob,1,1)

** ordering variables
** --------------------------------------- 
order id trial domain question prob extremity upper lower p100 dv support epistemicness support_focal support_foil knowledge focal foil targetA targetB age gender

** Exporting data
** ---------------------------------------
export delimited using "study2S final data.csv", nolabel replace