** =======================================
** This file: study4 analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 4/"
import delimited "study4 final data.csv", delimiter(comma) varnames(1) clear

** Relabeling treatment variable
** ---------------------------------------
label define condl 1 "random prediction" 2 "pattern detection"
label val cond condl

** Table 1 descriptive stats
** ---------------------------------------
preserve
collapse (mean) epistem extremity p100 (sd) ea_sd = epistem (median) upper lower, by(cond)
order cond epistem ea_sd extremity upper lower p100
tabstat epistem ea_sd extremity upper lower p100, by(cond) format(%9.3f)
restore

** Judgment Extremity (OLS model)
** ---------------------------------------
// tests for extremity using mean absolute deviation from 1/2
xtreg extremity i.question i.cond, re i(id)
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
xtreg upper i.question i.cond, re i(id)
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
xtreg lower i.question i.cond, re i(id)
lincom 2.cond
display "p-value = " normal(r(estimate)/r(se))

// tests for extremity using judged probability of either 0 or 1
xtlogit p100 i.question i.cond, re i(id)
margins, dydx(cond)
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

** Judgment Extremity (Fractional Logit)
** ---------------------------------------
local link = "link(logit) family(binomial)"

// tests for extremity using mean absolute deviation from 1/2
glm extremity i.question i.cond, `link' cluster(id)
margins, dydx(cond)
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
glm upper i.question i.cond, `link' cluster(id)
margins, dydx(cond)
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
glm lower i.question i.cond, `link' cluster(id)
margins, dydx(cond)
lincom 2.cond
display "p-value = " normal(r(estimate)/r(se))

** Evidence Sensitivity (across trials)
** ---------------------------------------
xtreg dv i.question c.support##i.cond, cluster(id)
margins cond, dydx(support)
lincom 2.cond#c.support
display "p-value = " 1 - normal(r(estimate)/r(se))

** Evidence Sensitivity (across subjects)
** ---------------------------------------
preserve
collapse coeff, by(cond id)
reg coeff i.cond
margins cond
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))
restore

** Evidence Sensitivity (across items)
** ---------------------------------------
preserve
egen UniqueItems = group(question target)
collapse (median) dv support, by(UniqueItems question cond)
regress dv i.cond##c.support, cluster(question)
margins cond, dydx(support)
lincom 2.cond#c.support
display "p-value = " 1 - normal(r(estimate)/r(se))
restore

** Manipulation Check
** ---------------------------------------
xtreg epistem i.question i.cond, re i(id)
margins cond
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

** Manipulation Check (separately for Epistemic and Aleatory subscales)
** ---------------------------------------
pwcorr e a

xtreg e i.question i.cond, re i(id)
margins cond
lincom 2.cond
display "p-value = " 1 - normal(r(estimate)/r(se))

xtreg a i.question i.cond, re i(id)
margins cond
lincom 2.cond
display "p-value = " normal(r(estimate)/r(se))

** Relationship between Epistemicness and K
** ---------------------------------------
xtreg dv c.support##c.epistem, re i(id)
lincom c.support#c.epistem
display "p-value = " 1 - normal(r(estimate)/r(se))
summarize epistem
local low  = r(mean) - r(sd)
local med  = r(mean)
local high = r(mean) + r(sd)
margins, dydx(support) at(epistem = (`low' `med' `high'))

** Relationship between Epistemicness and K (using aleatory subscale)
** ---------------------------------------
xtreg dv c.support##c.a, re i(id)
lincom c.support#c.a
display "p-value = " normal(r(estimate)/r(se))
summarize a
local alow  = r(mean) - r(sd)
local amed  = r(mean)
local ahigh = r(mean) + r(sd)
margins, dydx(support) at(a = (`alow' `amed' `ahigh'))

** Footnote 25
** ---------------------------------------
// extremity not reliably affected by order of trial blocks
glm extremity i.question i.cond##i.order, `link' cluster(id)
margins order, dydx(cond)

// evidence sensitivity not reliably affected by order of trial blocks
xtreg dv i.question c.support##i.cond##i.order, cluster(id)
margins order#cond, dydx(support) post
lincom [0.order#2.cond] - [0.order#1.cond]
lincom [1.order#2.cond] - [1.order#1.cond]


** Analysis of Judgment Accuracy
** ---------------------------------------
local link = "link(logit) family(binomial)"

// Brier Score
quietly glm brier i.question c.epistem, `link' cluster(id)
margins, dydx(epistem)

// Hit Rates (proportion correct)
quietly glm pc i.question c.epistem, `link' cluster(id)
margins, dydx(epistem)

// Reliability Scores
quietly glm reliability i.question c.epistem, `link' cluster(id)
margins, dydx(epistem)

// Resolution Scores
quietly glm resolution i.question c.epistem, `link' cluster(id)
margins, dydx(epistem)

** Epistemicness Quartiles
** ---------------------------------------
preserve
xtile ea4 = epistem, nq(4)
collapse brier reliability resolution, by(ea4)
table ea4, c(mean brier mean reliability mean resolution)
restore

** Brier scores - hard easy effect
** ---------------------------------------
local link = "link(logit) family(binomial)"
quietly glm brier c.epistem##c.diff, `link' cluster(id)
lincom c.epistem#c.diff
display "p-value = " normal(r(estimate)/r(se))

** Figure 4
** ---------------------------------------
local link = "link(logit) family(binomial)"
quietly glm brier c.epistem##c.diff, `link' cluster(id)
quietly sum epistem
local low  = r(mean) - r(sd)
local med  = r(mean)
local high = r(mean) + r(sd)
quietly margins, at(diff = (0(.2)1) epistem = (`low' `med' `high'))
marginsplot, recast(line) noci title("Brier Scores", color(black)) xtitle("Proportion Correct") ytitle("") legend(row(1)) legend(order(1 "Low EA" 2 "Med EA" 3 "High EA")) xsize(4) ysize(5) yscale(range(0(.2)1)) ylabel(0(.2)1, nogrid)

** Knowledge and Sensitivity to Evidence Strength
** ---------------------------------------
preserve
collapse coeff knowledge epistem, by(id)
regress coeff c.knowledge##c.epistem
lincom c.knowledge#c.epistem
display "p-value = " 1 - normal(r(estimate)/r(se))
restore

** Figure 5
** ---------------------------------------
preserve
collapse coeff knowledge epistem, by(id)
regress coeff c.knowledge##c.epistem
sum epistem
local low  = r(mean) - r(sd)
local med  = r(mean)
local high = r(mean) + r(sd)
quietly margins, at(knowledge = (0(1)10) epistem = (`low' `med' `high'))
marginsplot, noci
restore

** differences in Strength Ratings (requires 'trimmean' package)
** ---------------------------------------
// Strength ratios
foreach var of varlist support focal foil {
	preserve
	generate w0 = .
	generate w50 = .
	generate w10 = .
	forvalues i = 1/2 {
		summarize `var' if cond == `i', detail
		replace w0 = abs(`var' - r(mean)) if cond == `i'
		replace w50 = abs(`var' - r(p50)) if cond == `i'
		trimmean `var' if cond == `i', p(10)
		replace w10 = abs(`var' - r(tmean10)) if cond == `i'
	}
	foreach var2 of varlist w0 w50 w10 {
		display `var'
		display `var2'
		regress `var2' i.cond, cluster(id)
	}
	restore
}

** Testing for Binary Complementarity
** ---------------------------------------
preserve
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if target == 1
quietly forvalues i = 1/28 {
	ttest prob if question == `i', by(target)
	replace tstat = r(t) if question == `i'
	replace pvalue = r(p) if question == `i'
}
separate prob, by(target)
collapse prob0 prob1 tstat pvalue, by(question)
tabstat prob0 prob1 tstat pvalue, by(question) format(%9.2f) nototal
restore