** ======================================
** This file: NBA study analysis.do
** Format: Stata 13 do-file
** Author: David Tannenbaum <david.tannenbaum@utah.edu>
** =======================================

** Calling data
** ---------------------------------------
version 13.1
cd "~/Github/judgment-extremity/NBA study/"
import delimited "NBA study final data.csv", delimiter(comma) varnames(1) clear

** Encode condition variable
** ---------------------------------------
encode cond, gen(newcond)
drop cond
rename newcond cond

** Demographics
** ---------------------------------------
tabulate gender
summarize age gamesweek gamesseason sportsnews, detail

** Extremity
** ---------------------------------------
generate extremity = abs(prob - .5)
table trial cond, c(mean extremity) format(%9.3f)
table trial cond focal, c(mean prob) format(%9.3f)
xtreg extremity i.trial i.cond, re i(id)