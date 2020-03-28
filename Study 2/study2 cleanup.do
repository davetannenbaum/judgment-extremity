** ======================================
** This file: study2 cleanup.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/Study 2/"
import delimited "study2 raw data.csv", delimiter(comma) varnames(1) clear

** Clean up
** ---------------------------------------
// droping extra row of labels
drop in 1
// converting string to numeric data
quietly destring, replace
// compressing data
compress

** Generating probability items
** ---------------------------------------
egen prob1 = rowfirst(rain1 rain2)
egen prob2 = rowfirst(temp1 temp2)
egen prob3 = rowfirst(political1 political2)
egen prob4 = rowfirst(football1 football2)
egen prob5 = rowfirst(baseball1 baseball2)
egen prob6 = rowfirst(movies1 movies2)
egen prob7 = rowfirst(housing1 housing2)
egen prob8 = rowfirst(crime1 crime2)
egen prob9 = rowfirst(geo1 geo2)
egen prob10 = rowfirst(pop1 pop2)
egen prob11 = rowfirst(soccer1 soccer2)
egen prob12 = rowfirst(ocean1 ocean2)

** Generating focal and foil strength ratings
** ---------------------------------------
generate focal1 = s_chicago if target1 == "Rain A"
replace focal1 = s_minn if target1 == "Rain B"
generate focal2 = s_portland if target2 == "Temperature A"
replace focal2 = s_pitt if target2 == "Temperature B"
generate focal3 = s_obama if target3 == "US President A"
replace focal3 = s_romney if target3 == "US President B"
generate focal4 = s_49ers if target4 == "Football A"
replace focal4 = s_cardinals if target4 == "Football B"
generate focal5 = s_cubs if target5 == "Baseball A"
replace focal5 = s_dodgers if target5 == "Baseball B"
generate focal6 = s_spiderman if target6 == "Box Office A"
replace focal6 = s_batman if target6 == "Box Office B"
generate focal7 = s_nashville if target7 == "Housing Prices A"
replace focal7 = s_atlanta if target7 == "Housing Prices B"
generate focal8 = s_detroit if target8 == "Crime A"
replace focal8 = s_columbus if target8 == "Crime B"
generate focal9 = s_nevada if target9 == "State Size A"
replace focal9 = s_wyoming if target9 == "State Size B"
generate focal10 = s_istanbul if target10 == "Population A"
replace focal10 = s_shanghai if target10 == "Population B"
generate focal11 = s_italy if target11 == "Soccer A"
replace focal11 = s_germany if target11 == "Soccer B"
generate focal12 = s_atlantic if target12 == "Ocean Size A"
replace focal12 = s_indian if target12 == "Ocean Size B"
generate foil1 = s_chicago if target1 == "Rain B"
replace foil1 = s_minn if target1 == "Rain A"
generate foil2 = s_portland if target2 == "Temperature B"
replace foil2 = s_pitt if target2 == "Temperature A"
generate foil3 = s_obama if target3 == "US President B"
replace foil3 = s_romney if target3 == "US President A"
generate foil4 = s_49ers if target4 == "Football B"
replace foil4 = s_cardinals if target4 == "Football A"
generate foil5 = s_cubs if target5 == "Baseball B"
replace foil5 = s_dodgers if target5 == "Baseball A"
generate foil6 = s_spiderman if target6 == "Box Office B"
replace foil6 = s_batman if target6 == "Box Office A"
generate foil7 = s_nashville if target7 == "Housing Prices B"
replace foil7 = s_atlanta if target7 == "Housing Prices A"
generate foil8 = s_detroit if target8 == "Crime B"
replace foil8 = s_columbus if target8 == "Crime A"
generate foil9 = s_nevada if target9 == "State Size B"
replace foil9 = s_wyoming if target9 == "State Size A"
generate foil10 = s_istanbul if target10 == "Population B"
replace foil10 = s_shanghai if target10 == "Population A"
generate foil11 = s_italy if target11 == "Soccer B"
replace foil11 = s_germany if target11 == "Soccer A"
generate foil12 = s_atlantic if target12 == "Ocean Size B"
replace foil12 = s_indian if target12 == "Ocean Size A"

** Generating knowledge ratings
** ---------------------------------------
egen know1 = rowfirst(k_rain v150)
egen know2 = rowfirst(k_temp v152)
egen know3 = rowfirst(k_presiden v153)
egen know4 = rowfirst(k_football v156)
egen know5 = rowfirst(k_baseball v158)
egen know6 = rowfirst(k_movies v160)
egen know7 = rowfirst(k_housing v162)
egen know8 = rowfirst(k_crime v164)
egen know9 = rowfirst(k_geo v166)
egen know10 = rowfirst(k_populat v168)
egen know11 = rowfirst(k_soccer v170)
egen know12 = rowfirst(k_ocean v172)

** Generating E and A ratings
** ---------------------------------------
egen ea_rain1 = rowfirst(e_rain1 e_rain5)
egen ea_rain2 = rowfirst(e_rain2 e_rain6)
egen ea_rain3 = rowfirst(e_rain3 e_rain7)
egen ea_rain4 = rowfirst(e_rain4 e_rain8)
egen ea_temp1 = rowfirst(e_temp1 e_temp5)
egen ea_temp2 = rowfirst(e_temp2 e_temp6)
egen ea_temp3 = rowfirst(e_temp3 e_temp7)
egen ea_temp4 = rowfirst(e_temp4 e_temp8)
egen ea_politics1 = rowfirst(e_politics1 e_politics5)
egen ea_politics2 = rowfirst(e_politics2 e_politics6)
egen ea_politics3 = rowfirst(e_politics3 e_politics7)
egen ea_politics4 = rowfirst(e_politics4 e_politics8)
egen ea_football1 = rowfirst(e_football1 e_football5)
egen ea_football2 = rowfirst(e_football2 e_football6)
egen ea_football3 = rowfirst(e_football3 e_football7)
egen ea_football4 = rowfirst(e_football4 e_football8)
egen ea_baseball1 = rowfirst(e_baseball1 e_baseball5)
egen ea_baseball2 = rowfirst(e_baseball2 e_baseball6)
egen ea_baseball3 = rowfirst(e_baseball3 e_baseball7)
egen ea_baseball4 = rowfirst(e_baseball4 e_baseball8)
egen ea_movies1 = rowfirst(e_movies1 e_movies5)
egen ea_movies2 = rowfirst(e_movies2 e_movies6)
egen ea_movies3 = rowfirst(e_movies3 e_movies7)
egen ea_movies4 = rowfirst(e_movies4 e_movies8)
egen ea_housing1 = rowfirst(e_housing1 e_housing5)
egen ea_housing2 = rowfirst(e_housing2 e_housing6)
egen ea_housing3 = rowfirst(e_housing3 e_housing7)
egen ea_housing4 = rowfirst(e_housing4 e_housing8)
egen ea_crime1 = rowfirst(e_crime1 e_crime5)
egen ea_crime2 = rowfirst(e_crime2 e_crime6)
egen ea_crime3 = rowfirst(e_crime3 e_crime7)
egen ea_crime4 = rowfirst(e_crime4 e_crime8)
egen ea_geo1 = rowfirst(e_geo1 e_geo5)
egen ea_geo2 = rowfirst(e_geo2 e_geo6)
egen ea_geo3 = rowfirst(e_geo3 e_geo7)
egen ea_geo4 = rowfirst(e_geo4 e_geo8)
egen ea_pop1 = rowfirst(e_pop1 e_pop5)
egen ea_pop2 = rowfirst(e_pop2 e_pop6)
egen ea_pop3 = rowfirst(e_pop3 e_pop7)
egen ea_pop4 = rowfirst(e_pop4 e_pop8)
egen ea_soccer1 = rowfirst(e_soccer1 e_soccer5)
egen ea_soccer2 = rowfirst(e_soccer2 e_soccer6)
egen ea_soccer3 = rowfirst(e_soccer3 e_soccer7)
egen ea_soccer4 = rowfirst(e_soccer4 e_soccer8)
egen ea_ocean1 = rowfirst(e_ocean1 e_ocean5)
egen ea_ocean2 = rowfirst(e_ocean2 e_ocean6)
egen ea_ocean3 = rowfirst(e_ocean3 e_ocean7)
egen ea_ocean4 = rowfirst(e_ocean4 e_ocean8)

alpha ea_rain1 ea_rain3, item gen(e1) asis
alpha ea_temp1 ea_temp3, item gen(e2) asis
alpha ea_politics1 ea_politics3, item gen(e3) asis
alpha ea_football1 ea_football3, item gen(e4) asis
alpha ea_baseball1 ea_baseball3, item gen(e5) asis
alpha ea_movies1 ea_movies3, item gen(e6) asis
alpha ea_housing1 ea_housing3, item gen(e7) asis
alpha ea_crime1 ea_crime3, item gen(e8) asis
alpha ea_geo1 ea_geo3, item gen(e9) asis
alpha ea_pop1 ea_pop3, item gen(e10) asis
alpha ea_soccer1 ea_soccer3, item gen(e11) asis
alpha ea_ocean1 ea_ocean3, item gen(e12) asis

alpha ea_rain2 ea_rain4, item gen(a1) asis
alpha ea_temp2 ea_temp4, item gen(a2) asis
alpha ea_politics2 ea_politics4, item gen(a3) asis
alpha ea_football2 ea_football4, item gen(a4) asis
alpha ea_baseball2 ea_baseball4, item gen(a5) asis
alpha ea_movies2 ea_movies4, item gen(a6) asis
alpha ea_housing2 ea_housing4, item gen(a7) asis
alpha ea_crime2 ea_crime4, item gen(a8) asis
alpha ea_geo2 ea_geo4, item gen(a9) asis
alpha ea_pop2 ea_pop4, item gen(a10) asis
alpha ea_soccer2 ea_soccer4, item gen(a11) asis
alpha ea_ocean2 ea_ocean4, item gen(a12) asis

** Reverse scoring aleatory items
** ---------------------------------------
foreach var of varlist ea_rain2 ea_rain4 ea_temp2 ea_temp4 ea_politics2 ea_politics4 ea_football2 ea_football4 ea_baseball2 ea_baseball4 ea_movies2 ea_movies4 ea_housing2 ea_housing4 ea_crime2 ea_crime4 ea_geo2 ea_geo4 ea_pop2 ea_pop4 ea_soccer2 ea_soccer4 ea_ocean2 ea_ocean4 {
	replace `var' = 8 - `var'
}

** Generate Epistemicness Ratings
** ---------------------------------------
alpha ea_rain*, item gen(ea1) asis
alpha ea_temp*, item gen(ea2) asis
alpha ea_politics*, item gen(ea3) asis
alpha ea_football*, item gen(ea4) asis
alpha ea_baseball*, item gen(ea5) asis
alpha ea_movies*, item gen(ea6) asis
alpha ea_housing*, item gen(ea7) asis
alpha ea_crime*, item gen(ea8) asis
alpha ea_geo*, item gen(ea9) asis
alpha ea_pop*, item gen(ea10) asis
alpha ea_soccer*, item gen(ea11) asis
alpha ea_ocean*, item gen(ea12) asis

** Pruning data set and sorting variables
** ---------------------------------------
drop e_* k_* s_* rain1-ocean2 ea_* dcheck2*
order _all, seq
gen id = _n

** Reshaping data into long format
** ---------------------------------------
reshape long prob focal foil target know ea e a, i(id) j(domain)
label define domainl 1"rain" 2"temp" 3"politics" 4"football" 5"baseball" 6"movies" 7"housing" 8"crime" 9"geography" 10 "population" 11"soccer" 12"oceans"

** Some additional small cleanup
** ---------------------------------------
label val domain domainl
destring age, ignore(Male) replace
// removing subject who reported using outside sources
drop if outside_sources == 1
replace know = know - 1
// removing non-responses
drop if prob == .  
keep id prob domain e a ea target focal foil know gender age outside_sources
// dropped for inappropriate use of probability scale
drop if prob > 100 
replace prob = prob * .01 
// dropped for inappropriate use of support scale
drop if focal == 0  
// dropped for inappropriate use of support scale
drop if foil == 0 

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

// dropping temp variables
drop _*

** Dropping subjects with negative Ks
** ---------------------------------------
generate coeff = .
levelsof id, local(list)
foreach item in `list' {
	capture regress dv c.support if id == `item'
	capture replace coeff = _b[support] if id == `item'
}
drop if coeff < 0 | coeff == .

** Generateerating extremity measures
** ---------------------------------------
generate extremity = abs(.50 - prob)
generate umedian = prob if prob > .50
generate lmedian = prob if prob < .50
generate p100 = inrange(prob,0,0) | inrange(prob,1,1)

** Generateerating variables for accuracy analysis
** ---------------------------------------
// judged probability
generate jp = abs(prob - .50) + .50

// outcome variable
generate outcome = .
replace outcome = 0 if domain == 1 & target == "Rain A" // chicago
replace outcome = 1 if domain == 1 & target == "Rain B" // minneapolis
replace outcome = 0 if domain == 2 & target == "Temperature A" // portland
replace outcome = 1 if domain == 2 & target == "Temperature B" // pittsburgh
replace outcome = 1 if domain == 3 & target == "US President A" // Obama
replace outcome = 0 if domain == 3 & target == "US President B" // Romney
replace outcome = 1 if domain == 4 & target == "Football A" // 49ers
replace outcome = 0 if domain == 4 & target == "Football B" // Cardinals
replace outcome = 0 if domain == 5 & target == "Baseball A" // Cubs
replace outcome = 1 if domain == 5 & target == "Baseball B" // Dodgers
replace outcome = 0 if domain == 6 & target == "Box Office A" // Spiderman
replace outcome = 1 if domain == 6 & target == "Box Office B" // Batman
replace outcome = 1 if domain == 7 & target == "Housing Prices A" // Nashville
replace outcome = 0 if domain == 7 & target == "Housing Prices B" // Atlanta
replace outcome = 1 if domain == 8 & target == "Crime A" // Detroit
replace outcome = 0 if domain == 8 & target == "Crime B" // Columbus
replace outcome = 1 if domain == 9 & target == "State Size A" // Nevada
replace outcome = 0 if domain == 9 & target == "State Size B" // Wyoming
replace outcome = 0 if domain == 10 & target == "Population A" // Istanbul
replace outcome = 1 if domain == 10 & target == "Population B" // Shanghai
replace outcome = 1 if domain == 11 & target == "Soccer A"  // Italy
replace outcome = 0 if domain == 11 & target == "Soccer B" // Germany
replace outcome = 1 if domain == 12 & target == "Ocean Size A" // Atlantic
replace outcome = 0 if domain == 12 & target == "Ocean Size B" // Indian

// accuracy score/hit rate
set seed 12345
generate pc = 1 if prob > .5 & outcome == 1
replace pc = 0 if prob < .5 & outcome == 1
replace pc = 1 if prob < .5 & outcome == 0
replace pc = 0 if prob > .5 & outcome == 0
replace pc = int((1+1)*runiform()) if prob == .5

// item difficulty
generate diff = .
forvalues i = 1/12 {
	summarize pc if domain == `i'
	replace diff = r(mean) if domain == `i'
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

** Pruning and reordering data set
** ---------------------------------------
keep id domain prob extremity umedian lmedian p100 dv support coeff ea brier resolution reliability age focal foil  gender know target jp outcome pc diff bin Oj outcomevar
order id domain prob extremity umedian lmedian p100 dv support coeff ea brier resolution reliability age focal foil  gender know target jp outcome pc diff bin Oj outcomevar

** Exporting data
** ---------------------------------------
export delimited using "study2 final data.csv", replace