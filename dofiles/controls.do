clear
set more off 
version 12
cap log close

*-----------------------------PCE DEFLATOR: MONTHLY----------------------------*
* BEA spreadsheet is messy so find the appropriate range first
import excel pce.xlsx, cellrange(C8:ABS9) sheet(T20805-M)
local c=1
foreach v of varlist _all {
	rename `v' v`c'
	local ++c
}
replace v1 = "date" if  _n==1
replace v1 = "pce" if _n==2
rename v1 var 
sxpose, clear
nrow
destring pce, replace 
gen ym = ym(real(substr(date, 1, 4)), real(substr(date, -2,2)))
format ym %tm
drop date 
gen date = dofm(ym)
format date %d
gen h_year = year(date)
gen h_month = month(date)
format ym %tm
drop date 

* index to January 2007 (doesn't really matter)
gen index_t = pce if h_year==2007 & h_month==1
egen index = max(index_t)
drop index_t
gen pce_i = 100*pce/index

* rename time variables to match SIPP
keep if inrange(h_year,1989,2014)
rename pce pce_unindexed
rename pce_i pce
order ym h_year h_month 
saveold pce, replace
erase pce.xlsx
*------------------------------------------------------------------------------*
