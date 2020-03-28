** ======================================
** This file: study2 analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/Study 2/"
import delimited "study2 final data.csv", delimiter(comma) varnames(1) clear

** Encode domain variable
** ---------------------------------------
encode domain, gen(newdomain)
drop domain
rename newdomain domain

** Table 1 descriptive stats (reqires 'egenmore' package)
** ---------------------------------------
preserve
collapse (mean) ea extremity p100 (sd) ea_sd = ea (median) umedian lmedian, by(domain)
egen mean_ea = mean(-ea), by(domain)
egen Domain = axis(mean_ea domain), label(domain)
tabstat ea ea_sd extremity umedian lmedian p100, by(Domain) format(%9.2f)
restore

** Judgment extremity (across domains)
** ---------------------------------------
preserve
collapse (mean) ea extremity p100 (sd) ea_sd = ea (median) umedian lmedian, by(domain)
pwcorr ea extremity umedian lmedian p100, sig
restore

** Epistemicness and evidence sensitivity (across domains)
** ---------------------------------------
preserve
xtreg dv c.support##i.domain, re i(id)
margins domain, dydx(support) post
matrix coeff = e(b)'
collapse ea, by(domain)
svmat coeff
rename coeff k
pwcorr k ea, sig
restore

** Figure 3
** ---------------------------------------
preserve
quietly xtreg dv c.support##i.domain, re i(id)
quietly margins domain, dydx(support) post
matrix coeff = e(b)'
collapse ea, by(domain)
svmat coeff
rename coeff k
order domain ea k
graph twoway scatter k ea, mlab(domain) mlabposition(10) mcolor(black) mlabcolor(black) || lfit k ea, legend(off) ylabel(, nogrid) xsize(5) ysize(5) graphregion(color(white)) title("Estimates of Evidence Sensitivity", color(black) margin(0 0 5 0)) xtitle("Average Epistemicness Score", margin(0 0 0 2)) ytitle("")
restore

** Judgment extremity (within-participants)
** ---------------------------------------
preserve
generate corr = .
levelsof id, local(list)
foreach n of local list {
	capture spearman ea extremity if id == `n' 
	capture replace corr = r(rho) if id == `n'
}
collapse corr, by(id)
summarize corr, detail
signrank corr = 0
restore

** Epistemicness and evidence sensitivity (within-participants)
** ---------------------------------------
preserve
generate k = dv/support
generate corr = .
levelsof id, local(list)
foreach i of local list {
	capture spearman k extremity if id == `i' 
	capture replace corr = r(rho) if id == `i'
}
collapse corr, by(id)
summarize corr, detail
signrank corr = 0
restore

** Analysis of Judgment Accuracy
** ---------------------------------------
local link = "link(logit) family(binomial)"

// Brier Score
quietly glm brier c.ea i.domain, `link' cluster(id)
margins, dydx(ea)

// Hit Rates (proportion correct)
quietly glm pc c.ea i.domain, `link' cluster(id)
margins, dydx(ea)

// Reliability Scores
quietly glm reliability c.ea i.domain, `link' cluster(id)
margins, dydx(ea)

// Resolution Scores
quietly glm resolution c.ea i.domain, `link' cluster(id)
margins, dydx(ea)

** Epistemicness Quartiles
** ---------------------------------------
preserve
xtile ea4 = ea, nq(4)
collapse brier reliability resolution, by(ea4)
table ea4, c(mean brier mean reliability mean resolution) format(%9.3f)
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
// looking at rank-order correlations by knowledge quartiels
preserve
drop if know == .
collapse know ea coeff, by(id)
xtile know4 = know, nq(4)
bysort know4: spearman ea coeff
restore

// alternative analysis using analytic K
preserve
drop if know == .
generate k = dv/support
rreg k c.ea##c.know
lincom c.ea#c.know
display "p-value = " 1 - normal(r(estimate)/r(se))
quietly sum know
local low = r(mean) - r(sd)
local med = r(mean)
local high = r(mean) + r(sd)
margins, dydx(ea) at(know = (`low' `med' `high'))
restore

** Testing for Binary Complementarity 
** ---------------------------------------
preserve
rencode target, replace
generate cond = 0 if inlist(target,1,3,5,7,9,11,13,15,17,19,21,23)
replace cond = 1 if inlist(target,2,4,6,8,10,12,14,16,18,20,22,24)
generate trial = .
replace trial = 1  if inlist(target,1,2)
replace trial = 2  if inlist(target,3,4)
replace trial = 3  if inlist(target,5,6)
replace trial = 4  if inlist(target,7,8)
replace trial = 5  if inlist(target,9,10)
replace trial = 6  if inlist(target,11,12)
replace trial = 7  if inlist(target,13,14)
replace trial = 8  if inlist(target,15,16)
replace trial = 9  if inlist(target,17,18)
replace trial = 10 if inlist(target,19,20)
replace trial = 11 if inlist(target,21,22)
replace trial = 12 if inlist(target,23,24)
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if cond == 1
quietly forvalues i = 1/12 {
	ttest prob if trial == `i', by(cond) 
	replace tstat = r(t) if trial == `i' 
	replace pvalue = r(p) if trial == `i'
}
separate prob, by(cond)
collapse prob0 prob1 tstat pvalue, by(trial)
tabstat prob0 prob1 tstat pvalue, by(trial) format(%9.2f) nototal
restore