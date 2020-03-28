** ======================================
** This file: study1 analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/Study 1/"
import delimited "study1 final data.csv", delimiter(comma) varnames(1) clear

** Table 1 descriptive stats
** ---------------------------------------
preserve
xtile ea4 = ea, nq(4)
collapse (mean) ea extremity p100 (sd) ea_sd = ea (median) upper lower, by(ea4)
tabstat ea ea_sd extremity upper lower p100, by(ea4) format(%9.2f) nototal
restore

** Estimating judgment extremity (OLS model)
** ---------------------------------------
// tests for extremity using mean absolute deviation from 1/2
quietly xtreg extremity i.game c.ea, re i(id)
lincom ea
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
quietly xtreg upper i.game c.ea, re i(id)
lincom ea
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
quietly xtreg lower i.game c.ea, re i(id)
lincom ea
display "p-value = " normal(r(estimate)/r(se))

// tests for extremity using judged probability of either 0 or 1
quietly xtlogit p100 i.game c.ea, re i(id)
quietly margins, dydx(ea) predict(pu0) post
lincom ea
display "p-value = " 1 - normal(r(estimate)/r(se))

** Estimating judgment extremity (fractional logit model)
** ---------------------------------------
local link = "link(logit) family(binomial)"

// tests for extremity using mean absolute deviation from 1/2
quietly glm extremity i.game c.ea, `link' cluster(id)
quietly margins, dydx(ea) post
lincom ea
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
quietly glm upper i.game c.ea, `link' cluster(id)
quietly margins, dydx(ea) post
lincom ea
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
quietly glm lower i.game c.ea, `link' cluster(id)
quietly margins, dydx(ea) post
lincom ea
display "p-value = " normal(r(estimate)/r(se))

** Figure 1
** ---------------------------------------
preserve
drop if ea == .
replace seed = 17 - seed
generate low = .
generate high = .
forvalues i = 1/16 {
	summarize ea if seed == `i', detail
	replace low = prob if ea < r(p25) & seed == `i'
	replace high = prob if ea > r(p75) & seed == `i'
}
collapse (median) low high, by(seed)
glm low c.seed, family(binomial) link(logit)
predict yhat
glm high c.seed, family(binomial) link(logit)
predict yhat2
graph twoway scatter low seed || line yhat seed || scatter high seed || line yhat2 seed, legend(off) xsize(3) ysize(4)
restore


** Analysis of Judgment Accuracy
** ---------------------------------------
local link = "link(logit) family(binomial)"

// Brier Scores
quietly glm brier i.game c.ea, `link' cluster(id)
margins, dydx(ea)

// Hit Rates (proportion correct)
quietly glm pc i.game c.ea, `link' cluster(id)
margins, dydx(ea)

// Reliability Scores
quietly glm reliability i.game c.ea, `link' cluster(id)
margins, dydx(ea)

// Resolution Scores
quietly glm resolution i.game c.ea, `link' cluster(id)
margins, dydx(ea)

** Accuracy by Epistemicness Quartiles
** ---------------------------------------
preserve
xtile ea4 = ea, nq(4)
collapse brier reliability resolution, by(ea4)
table ea4, c(mean brier mean reliability mean resolution)
restore

** Brier scores - hard easy effect
** ---------------------------------------
local link = "link(logit) family(binomial)"
quietly glm brier c.ea##c.diff, `link' cluster(id)
lincom c.ea#c.diff
display "p-value = " normal(r(estimate)/r(se))

** Figure 4
** ---------------------------------------
quietly glm brier c.ea##c.diff, `link' cluster(id)
quietly sum ea
local low = r(mean) - r(sd)
local med = r(mean)
local high = r(mean) + r(sd)
quietly margins, at(diff = (0(.2)1) ea = (`low' `med' `high'))
marginsplot, recast(line) noci title("Brier Scores", color(black)) xtitle("Proportion Correct") ytitle("") legend(row(1)) legend(order(1 "Low EA" 2 "Med EA" 3 "High EA")) xsize(4) ysize(5) yscale(range(0(.2)1)) ylabel(0(.2)1, nogrid)

** Knowledge and Sensitivity to Evidence Strength (from Supplemental Materials)
** ---------------------------------------
alpha screen1 screen2 screen3, gen(knowledge)
xtreg extremity i.game c.ea##c.knowledge, re i(id)
lincom c.ea#c.knowledge
display "p-value = " 1 - normal(r(estimate)/r(se))
sum knowledge
local low = r(mean) - r(sd)
local med = r(mean)
local high = r(mean) + r(sd)
margins, dydx(ea) at(know = (`low' `med' `high'))

** Testing for Binary Complementarity (from Supplemental Materials)
** ---------------------------------------
preserve
generate tstat = .
generate pvalue  = .
quietly replace prob = 1 - prob if focus == 0
quietly forvalues i = 1/28 {
	ttest prob if game == `i', by(focus)
	replace tstat = r(t) if game == `i'
	replace pvalue = r(p) if game == `i'
}
separate prob, by(focus)
collapse prob1 prob0 tstat pvalue, by(game)
tabstat prob1 prob0 tstat pvalue, by(game) format(%9.2f) nototal
restore