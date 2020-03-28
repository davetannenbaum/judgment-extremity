** ======================================
** This file: study1 cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/Study 1/"
import delimited "study1 raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// droping extra row of labels
drop in 1
// converting string to numeric data
quietly destring, replace
// compressing data
compress

** Renaming variables
** ---------------------------------------
rename v8 startdate
rename v9 enddate
rename q27 screen1
rename q25 screen2
rename q31 screen3
rename q21 GamesPerWeek
rename q23 GamesThisSeason
rename v642 HoursPerWeek
rename v643 FavoriteTeam
rename q12 age
rename q16 gender 
rename v647 external_sources 
rename q32 comments

** Renaming probability judgments
** ---------------------------------------
rename q24* focal*
rename q26* foil*

** Generating new probability variables and
** dummy-coding focal target for each trial
** ---------------------------------------
forvalues i = 1/28 {
	egen prob`i' = rowfirst(focal`i' foil`i')
	generate focus`i' = inrange(focal`i',0,100)
}

** Renaming epistemicness ratings
** ---------------------------------------
forvalues i = 1/10 {
	forvalues j = 1/28 {
		rename q17_`i'`j' ea`i'_`j'
	}
}

** Reverse coding aleatory items
** ---------------------------------------
forvalues i = 1/28 {
	replace ea2_`i' = 8 - ea2_`i'
	replace ea4_`i' = 8 - ea4_`i'
	replace ea6_`i' = 8 - ea6_`i'
	replace ea7_`i' = 8 - ea7_`i'
}
 
** Looking at combined alpha
** ---------------------------------------
preserve
generate id = _n
reshape long prob focus sd ea1_ ea2_ ea3_ ea4_ ea5_ ea6_ ea7_ ea8_ ea9_ ea10_, i(id) j(game)
rename ea?_ ea?
rename ea??_ ea??
* overall alpha
alpha ea1-ea10, item asis
* factor analysis
factor ea1-ea10, factors(2) ipf
rotate, oblique quartimin
* correlation between E and A subscales
alpha ea2 ea4 ea6 ea7, asis gen(A)
alpha ea1 ea3 ea5 ea8 ea9 ea10, asis gen(E)
pwcorr E A
restore

** generating epistemicness indices
** ---------------------------------------
forvalues i = 1/28 {
	display "Game `i'"
	alpha ea*_`i', item gen(ea`i') asis
}

** generating epistemic subscale
** ---------------------------------------
forvalues i = 1/28 {
	display "Game `i'"
	alpha ea1_`i' ea3_`i' ea5_`i' ea8_`i' ea9_`i' ea10_`i', item gen(e`i') asis
}

** generating aleatory subscale
** ---------------------------------------
forvalues i = 1/28 {
	display "Game `i'"
	alpha ea2_`i' ea4_`i' ea6_`i' ea7_`i', item gen(a`i') asis
}

** pruning dataset
** ---------------------------------------
keep screen* Games* Hours Favorite age gender prob* focus* ea? ea?? e? e?? a? a??

** reshaping data and keeping only relevant variables
** ---------------------------------------
generate id = _n
reshape long prob focus ea e a, i(id) j(game)
compress

** generate tournament seeding data
** ---------------------------------------
generate seed = .
replace seed = game if inrange(game,1,5) & focus == 1
replace seed = game + 1 if inrange(game,6,7) & focus == 1
replace seed = game - 6 if inrange(game,8,14) & focus == 1
replace seed = game - 13 if inrange(game,15,21) & focus == 1
replace seed = game - 21 if inrange(game,22,26) & focus == 1
replace seed = game - 20 if inrange(game,27,28) & focus == 1
replace seed = 17 - (game) if inrange(game,1,5) & focus == 0
replace seed = 17 - (game + 1) if inrange(game,6,7) & focus == 0
replace seed = 17 - (game - 6) if inrange(game,8,14) & focus == 0
replace seed = 17 - (game - 13) if inrange(game,15,21) & focus == 0
replace seed = 17 - (game - 21) if inrange(game,22,26) & focus == 0
replace seed = 17 - (game - 20) if inrange(game,27,28) & focus == 0

** generating extremity measures
** ---------------------------------------
replace prob = prob * .01
generate extremity = abs(prob - .5)
generate upper = prob if prob > .5
generate lower = prob if prob < .5
generate p100 = inrange(prob,0,0) | inrange(prob,1,1)

** generating variables for accuracy analysis
** ---------------------------------------
// judged probability
generate jp = abs(prob - .50) + .50

// outcome variable
generate outcome = .
replace outcome = 1 if inrange(game,1,15) & focus == 1
replace outcome = 0 if game == 16 & focus == 1
replace outcome = 1 if inrange(game,17,18) & focus == 1
replace outcome = 0 if game == 19 & focus == 1
replace outcome = 1 if inrange(game,20,23) & focus == 1
replace outcome = 0 if game == 24 & focus == 1
replace outcome = 1 if inrange(game,25,26) & focus == 1
replace outcome = 0 if game == 27 & focus == 1
replace outcome = 1 if game == 28 & focus == 1
replace outcome = 0 if inrange(game,1,15) & focus == 0
replace outcome = 1 if game == 16 & focus == 0
replace outcome = 0 if inrange(game,17,18) & focus == 0
replace outcome = 1 if game == 19 & focus == 0
replace outcome = 0 if inrange(game,20,23) & focus == 0
replace outcome = 1 if game == 24 & focus == 0
replace outcome = 0 if inrange(game,25,26) & focus == 0
replace outcome = 1 if game == 27 & focus == 0
replace outcome = 0 if game == 28 & focus == 0

// accuracy score/hit rate
set seed 12345
generate pc = 1 if prob > .5 & outcome == 1
replace pc = 0 if prob < .5 & outcome == 1
replace pc = 1 if prob < .5 & outcome == 0
replace pc = 0 if prob > .5 & outcome == 0
replace pc = int((1+1)*runiform()) if prob == .5

// item difficulty
generate diff = .
forvalues i = 1/28 {
	summarize pc if game == `i'
 	replace diff = r(mean) if game == `i'
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

// calibration and resolution scores
forvalues i = 0/9 {
	summarize outcome if bin == `i'
 	replace Oj = r(mean) if bin == `i'
 	replace reliability = (prob - Oj)^2 if bin == `i'
 	summarize outcome, detail
 	replace resolution = (Oj - r(mean))^2 if bin == `i'
 	replace outcomevar = r(Var)
}

** Pruning and reordering variables
** ---------------------------------------
keep id game prob extremity upper lower p100 ea focus seed outcome pc diff brier bin Oj resolution reliability outcomevar screen1 screen2 screen3
order id game prob extremity upper lower p100 ea focus seed outcome pc diff brier bin Oj resolution reliability outcomevar screen1 screen2 screen3

** Exporting data
** ---------------------------------------
export delimited using "study1 final data.csv", replace