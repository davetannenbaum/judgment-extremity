** =======================================
** This file: NBA study cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/NBA study/"
import delimited "NBA study raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// droping extra row of labels
drop in 1
// converting string to numeric data
quietly destring, replace
// removing incomplete rows/drop-outs
drop if v10 == 0
// compressing data
compress

** renaming variables
** ---------------------------------------
replace cond = "distributional" if cond == "aleatory"
replace cond = "singular" if cond == "epistemic"
rename q6_? ea?
rename q7_? support?
rename q17_* favorite*
rename q23* age
rename q25 gender
rename q11_1 GamesWeek
rename q13_1 GamesSeason
rename q15_1 SportsNews
replace GamesWeek = "6" if GamesWeek == "5-7"
destring GamesWeek, replace

** generating probability items
** ---------------------------------------
egen prob1 = rowfirst(q1_*)
egen prob2 = rowfirst(q2_*)
egen prob3 = rowfirst(q4_*)

** generating focal item
** ---------------------------------------
generate focal1 = inrange(q1_11,0,100)
generate focal2 = inrange(q2_11,0,100)
generate focal3 = inrange(q4_11,0,100)

** labeling variables
** ---------------------------------------
encode cond, gen(newcond)
drop cond
rename newcond cond
label define focal1l 0 "Pistons" 1 "Bulls"
label define focal2l 0 "Hornets" 1 "Raptors"
label define focal3l 0 "Clippers" 1 "Grizzlies"
label val focal1 focal1l
label val focal2 focal2l
label val focal3 focal3l

** pruning data set
** ---------------------------------------
keep cond prob* ea* focal* support* age gender Games* Sports*
order cond prob* ea* focal* support* age gender Games* Sports*

** creating epistemicness index
** ---------------------------------------
alpha ea*, item reverse(ea1 ea3) gen(ea)

** generate strength ratings
** ---------------------------------------
generate strength1 = .
generate strength2 = .
generate strength3 = .
replace strength1 = ln(support1/support2) if focal1 == 1
replace strength1 = ln(support2/support1) if focal1 == 0
replace strength2 = ln(support5/support6) if focal2 == 1
replace strength2 = ln(support6/support5) if focal2 == 0
replace strength3 = ln(support3/support4) if focal3 == 1
replace strength3 = ln(support4/support3) if focal3 == 0

** reshaping data
** ---------------------------------------
generate id = _n
reshape long prob focal strength, i(id) j(trial)

** rescaling probability judgments
** ---------------------------------------
replace prob = prob * .01

** Exporting data
** ---------------------------------------	
export delimited using "NBA study final data.csv", replace