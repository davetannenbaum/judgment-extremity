** =======================================
** This file: study2S analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
cd "~/Github/judgment-extremity/Study 2S/"
import delimited "study2S final data.csv", delimiter(comma) varnames(1) clear

** Labeling condition variable
** ---------------------------------------
label define domainl 0 "basketball" 1 "temp" 2 "geography"
label val domain domainl

** Table 1 descriptive stats (reqires 'egenmore' package)
** ---------------------------------------
preserve
collapse (mean) epistemicness extremity p100 (sd) ea_sd = epistemicness (median) upper lower, by(domain)
egen mean_ea = mean(-epistemicness), by(domain)
egen Domain = axis(mean_ea domain), label(domain)
tabstat epistemicness ea_sd extremity upper lower p100, by(Domain) format(%9.2f)
restore

** epistemicness ratings for each domain
** ---------------------------------------
xtreg epistemicness i.domain, re i(id)
margins domain
margins domain, pwcompare(effects)

** Estimating judgment extremity (OLS model)
** ---------------------------------------
// tests for extremity using mean absolute deviation from 1/2
quietly xtreg extremity i.domain i.question, re i(id)
margins domain
margins domain, pwcompare(effects)

// tests for extremity using judged probability > 1/2
quietly xtreg upper i.domain i.question, re i(id)
margins domain
margins domain, pwcompare(effects)

// tests for extremity using judged probability < 1/2
quietly xtreg lower i.domain i.question, re i(id)
margins domain
margins domain, pwcompare(effects)

// tests for extremity using judged probability of either 0 or 1
quietly xtlogit p100 i.domain i.question, re i(id)
margins domain
margins domain, pwcompare(effects)

** Estimating judgment extremity (fractional logit model)
** ---------------------------------------
local link = "link(logit) family(binomial)"

// tests for extremity using mean absolute deviation from 1/2
quietly glm extremity i.question i.domain, `link' cluster(id)
margins domain
margins domain, pwcompare(effects)

// tests for extremity using judged probability > 1/2
quietly glm upper i.question i.domain, `link' cluster(id)
margins domain
margins domain, pwcompare(effects)

// tests for extremity using judged probability < 1/2
quietly glm lower i.question i.domain, `link' cluster(id)
margins domain
margins domain, pwcompare(effects)

** Estimating Evidence Sensitivity (across trials)
** ---------------------------------------
quietly xtreg dv i.question c.support##i.domain , re i(id)
margins domain, dydx(support)
margins domain, dydx(support) pwcompare(effects)

** Analysis of K (across participants)
** ---------------------------------------
preserve
collapse coeff epistemicness, by(id domain)
quietly xtreg coeff i.domain, re i(id)
margins domain
margins domain, pwcompare(effects)
restore

** Analysis of K (across items)
** ---------------------------------------
preserve
egen UniqueItems = group(focal foil domain)
egen UniqueQuestions = group(question domain)
collapse (median) dv support epistemicness, by(UniqueItems UniqueQuestions domain)
quietly xtreg dv i.domain##c.support, re i(UniqueQuestions)
margins domain, dydx(support)
margins domain, dydx(support) pwcompare(effects)
restore

** Relationship between knowledge and K
** ---------------------------------------
preserve
collapse coeff epistemicness knowledge, by(id domain) 
xtreg coeff c.epistemicness##c.knowledge, re i(id)
lincom c.epistemicness#c.knowledge
display "p-value = " 1 - normal(r(estimate)/r(se))
restore

** Figure 5
** ---------------------------------------
preserve
collapse coeff epistemicness knowledge, by(id domain) 
quietly xtreg coeff c.epistemicness##c.knowledge, re i(id)
summarize epistemicness
local low = r(mean) - r(sd)
local med = r(mean)
local high = r(mean) + r(sd)
quietly margins, at(knowledge = (0(20)100) epistem = (`low' `med' `high')) post
marginsplot, noci title("Estimates of Evidence Sensitivity", color(black)) xtitle("Subjective Knowledge") ytitle("") legend(row(1)) legend(order(1 "Low EA" 2 "Med EA" 3 "High EA")) xsize(4) ysize(5) yscale(range(0(1)5)) ylabel(0(1)5, nogrid) scheme(s1color) plotopts(msymbol(i))
restore

** tests of binary complementarity
** ---------------------------------------
// Basektball
preserve
keep if domain == 0
egen pair = group(focal foil)
generate cond = 0 if pair >= 1 & pair <= 8
replace cond = 0 if pair >= 13 & pair <= 16
replace cond = 0 if pair >= 21 & pair <= 24
replace cond = 1 if pair >= 9 & pair <= 12
replace cond = 1 if pair >= 17 & pair <= 20
replace cond = 1 if pair >= 25 & pair <= 32
drop trial
generate trial = .
replace trial = 1 if pair == 1 | pair == 9
replace trial = 2 if pair == 2 | pair == 17
replace trial = 3 if pair == 3 | pair == 25
replace trial = 4 if pair == 4 | pair == 29
replace trial = 5 if pair == 5 | pair == 10
replace trial = 6 if pair == 6 | pair == 18
replace trial = 7 if pair == 7 | pair == 26
replace trial = 8 if pair == 8 | pair == 30
replace trial = 9 if pair == 13 | pair == 11
replace trial = 10 if pair == 14 | pair == 19
replace trial = 11 if pair == 15 | pair == 27
replace trial = 12 if pair == 16 | pair == 31
replace trial = 13 if pair == 21 | pair == 12
replace trial = 14 if pair == 22 | pair == 20
replace trial = 15 if pair == 23 | pair == 28
replace trial = 16 if pair == 24 | pair == 32
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if cond == 1
forvalues i = 1/16 {
	ttest prob if trial == `i', by(cond)
	replace tstat = r(t) if trial == `i'
	replace pvalue = r(p) if trial == `i'
}
separate prob, by(cond)
collapse prob0 prob1 tstat pvalue, by(trial)
tabstat prob0 prob1 tstat pvalue, by(trial) format(%9.2f) nototal
restore

// Weather
preserve
keep if domain == 1
egen pair = group(focal foil)
generate cond = 0 if pair >= 1 & pair <= 16
replace cond = 1 if pair >= 17 & pair <= 32
drop trial
generate trial = .
forvalues i = 1/16 {
	replace trial = `i' if pair == `i'
}
replace trial = 1 if pair == 17
replace trial = 2 if pair == 21
replace trial = 3 if pair == 25
replace trial = 4 if pair == 29
replace trial = 5 if pair == 18
replace trial = 6 if pair == 22
replace trial = 7 if pair == 26
replace trial = 8 if pair == 30
replace trial = 9 if pair == 19
replace trial = 10 if pair == 23
replace trial = 11 if pair == 27
replace trial = 12 if pair == 31
replace trial = 13 if pair == 20
replace trial = 14 if pair == 24
replace trial = 15 if pair == 28
replace trial = 16 if pair == 32
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if cond == 1
forvalues i = 1/16 {
	ttest prob if trial == `i', by(cond)
	replace tstat = r(t) if trial == `i'
	replace pvalue = r(p) if trial == `i'
}
separate prob, by(cond)
collapse prob0 prob1 tstat pvalue, by(trial)
tabstat prob0 prob1 tstat pvalue, by(trial) format(%9.2f) nototal
restore

// Geography
preserve
keep if domain == 2
egen pair = group(focal foil)
generate cond = 0 if pair >= 1 & pair <= 8
replace cond = 0 if pair >= 17 & pair <= 24
replace cond = 1 if pair >= 9 & pair <= 16
replace cond = 1 if pair >= 25 & pair <= 32
drop trial
generate trial = .
replace trial = 1 if pair == 1 | pair == 9
replace trial = 2 if pair == 2 | pair == 13
replace trial = 3 if pair == 3 | pair == 25
replace trial = 4 if pair == 4 | pair == 29
replace trial = 5 if pair == 5 | pair == 10
replace trial = 6 if pair == 6 | pair == 14
replace trial = 7 if pair == 7 | pair == 26
replace trial = 8 if pair == 8 | pair == 30
replace trial = 9 if pair == 17 | pair == 11
replace trial = 10 if pair == 18 | pair == 15
replace trial = 11 if pair == 19 | pair == 27
replace trial = 12 if pair == 20 | pair == 31
replace trial = 13 if pair == 21 | pair == 12
replace trial = 14 if pair == 22 | pair == 16
replace trial = 15 if pair == 23 | pair == 28
replace trial = 16 if pair == 24 | pair == 32
generate tstat = .
generate pvalue = .
replace prob = 1 - prob if cond == 1
forvalues i = 1/16 {
	ttest prob if trial == `i', by(cond)
	replace tstat = r(t) if trial == `i'
	replace pvalue = r(p) if trial == `i'
}
separate prob, by(cond)
collapse prob0 prob1 tstat pvalue, by(trial)
tabstat prob0 prob1 tstat pvalue, by(trial) format(%9.2f) nototal
restore