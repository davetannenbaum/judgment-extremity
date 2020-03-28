** =======================================
** This file: study3 analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 3/"
import delimited "study3 final data.csv", delimiter(comma) varnames(1) clear

** Recode/relabel task
** ---------------------------------------
replace task = 1 - task
label define taskl 0 "single day" 1 "yearlong average"
label val task taskl

** Table 1 descriptive stats
** ---------------------------------------
preserve
collapse (mean) ea extremity p100 (sd) ea_sd = ea (median) upper lower, by(task)
order task ea ea_sd extremity upper lower p100
tabstat ea ea_sd extremity upper lower p100, by(task) format(%9.2f)
restore

** Manipulation Check
** ---------------------------------------
xtreg ea i.task, re i(id)

** Manipulation Check (within-participants)
** ---------------------------------------
preserve
separate ea, by(task)
collapse ea0 ea1, by(id)
generate diff = ea1 - ea0
signrank diff = 0
display r(N_pos)/(r(N_pos) + r(N_neg) + r(N_tie))
restore

** Judgment Extremity (OLS model)
** ---------------------------------------
// tests for extremity using mean absolute deviation from 1/2
xtreg extremity i.question i.task, re i(id)
lincom 1.task
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
xtreg upper i.question i.task, re i(id)
lincom 1.task
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
xtreg lower i.question i.task, re i(id)
lincom 1.task
display "p-value = " normal(r(estimate)/r(se))

// tests for extremity using judged probability of either 0 or 1
xtlogit p100 i.question i.task, re i(id)
margins, dydx(task)
lincom 1.task
display "p-value = " 1 - normal(r(estimate)/r(se))

** Judgment Extremity (Fractional Logit)
** ---------------------------------------
local link = "link(logit) family(binomial)"

// tests for extremity using mean absolute deviation from 1/2
glm extremity i.question i.task, `link' cluster(id)
margins, dydx(task)
lincom 1.task
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability > 1/2
glm upper i.question i.task, `link' cluster(id)
margins, dydx(task)
lincom 1.task
display "p-value = " 1 - normal(r(estimate)/r(se))

// tests for extremity using judged probability < 1/2
glm lower i.question i.task, `link' cluster(id)
margins, dydx(task)
lincom 1.task
display "p-value = " normal(r(estimate)/r(se))

** Judgment Extremity (within-participants)
** ---------------------------------------
preserve
separate extremity, by(task)
collapse extremity0 extremity1, by(id)
generate diff = extremity1 - extremity0
signrank diff = 0
restore

** Evidence Sensitivity (across trials)
** ---------------------------------------
xtreg dv i.question c.support##i.task, re i(id)
margins task, dydx(support)

** Evidence Sensitivity (across participants)
** ---------------------------------------
preserve
generate k = coeff
separate k, by(task)
collapse k0 k1, by(id)
ttest k1 == k0
restore

** Evidence Sensitivity (across items)
** ---------------------------------------
preserve
egen UniqueItems = group(question target)
collapse (median) dv support, by(UniqueItems question task)
xtreg dv i.task##c.support, re i(question)
margins task, dydx(support)
restore

** Evidence Sensitivity (within-participants)
** ---------------------------------------
preserve
generate k = coeff
separate k, by(task)
collapse k0 k1, by(id)
generate diff = k1 - k0
signrank diff = 0
restore

** epistemicness and evidence sensitivity
** ---------------------------------------
xtreg dv i.question c.support##c.ea, re i(id)

** epistemicness and evidence sensitivity (within-participants)
** ---------------------------------------
preserve
generate k = coeff
separate k, by(task)
separate ea, by (task)
collapse k0 k1 ea0 ea1, by(id)
generate kdiff = k1 - k0
generate eadiff = ea1 - ea0
spearman kdiff eadiff
pwcorr kdiff eadiff, sig
restore

** epistemicness and K (within-participants nonparametric)
** ---------------------------------------
preserve
generate k = coeff
collapse k ea, by(task id)
reshape wide k ea, i(id) j(task)
drop if ea0 == .
drop if ea1 == .
generate k =  1 if k0 < k1
replace k =  0 if k0 == k1
replace k = -1 if k0 > k1
generate ea =  1 if ea0 < ea1
replace ea =  0 if ea0 == ea1
replace ea = -1 if ea0 > ea1
tabulate k ea
generate coincide = 1 if k == ea
replace coincide = 0 if k != ea
bitest coincide == .5
restore

** Testing for Binary Complementarity
** ---------------------------------------
preserve
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if target == 1
quietly forvalues i = 1/15 {
	ttest prob if question == `i', by(target)
	replace tstat = r(t) if question == `i'
	replace pvalue = r(p) if question == `i'
}
separate prob, by(target)
collapse prob0 prob1 tstat pvalue, by(question)
tabstat prob0 prob1 tstat pvalue, by(question) format(%9.2f) nototal
restore