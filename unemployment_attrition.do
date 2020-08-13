* attrition_weights(revised).do
* Do-file to test for attrition on observables and reweight using inverse probability weights
* Written by Nakhate Anand Theertha
* Date: 05 May 2020


set more on
#delimit cr

global data "<insert location of folder where you have saved Attrition_Unemployment.dta" 

use "$data\attr_example", clear

gen A=1 if pcx96~=.& split==0			/* Note that A=0 for households which remain in the sample between 1996 and 2006, and A=1 for household that attrit */
replace A=0 if pcx07~=. & split==0
tab A

sum agehh
scalar meanage=r(mean)
disp meanage
gen agehh2=(agehh-meanage)^2

*create globals

global headchar agehh agehh2 educ_h
global demog p0_4 p5_14 p15_19 p35_54 p55p   
global educ educ_h
global baselinevars  $headchar hhsize $demog 
global attritvars  emp1

sum  $headchar1 hhsize $demog
sum $attritvars

**** Unemployment

* Calculate unrestricted attrition probit
#delimit ;
xi: probit A $headchar hhsize $demog emp1, robust cluster(st)
#delimit cr

* Wald test for whether attrition is random
test  $headchar $demog emp1 
test emp1

test  agehh agehh2 educ_h p0_4 p5_14 p15_19 p35_54 p55p  emp1 
test emp1

* BGLW test for attrition (F-test)

#delimit ;
xi i.A*agehh i.A*agehh2 i.A*educ_h i.A*p0_4 i.A*p5_14 i.A*p15_19 i.A*p35_54 i.A*p55p i.A*emp1, prefix(I) ;
#delimit cr; 

#delimit ;
xi: reg emp1 hhsize agehh agehh2 educ_h p0_4 p5_14 p15_19 p35_54 p55p A IAX*  , robust cluster(st) ;
#delimit ;
testparm A  IAXagehh_1 IAXagehha1  IAXeduc__1 IAXp0_4_1 IAXp5_14_1 IAXp15_1_1 IAXp35_5_1 IAXp55p_1; 
#delimit cr

* Calculate inverse probability weights

gen R=-A
replace R=R+1				/* Note that R=1 for households which remain in the sample, and R=0 for those that attrit */

#delimit ;
xi: probit R agehh agehh2 educ_h hhsize p0_4 p5_14 p15_19 p35_54 p55p emp1, robust cluster(st);
#delimit cr

capture drop sample
gen sample=e(sample)
tab sample

capture drop pxav
predict pxav


xi: probit R hhsize emp1 if sample==1, robust cluster(st)

capture drop pxres
predict pxres

cap drop attwght
gen attwght=pxres/pxav
label var attwght "Attrition (inverse probabilty)weight for unemployment"
sum attwght, d

* drop if attwght==.




*without inverse probability weights
xi: reg emp12 agehh agehh2 educ_h hhsize p0_4 p5_14 p15_19 p35_54 p55p emp1 if sample==1, robust cluster(st)

*with inverse probability weights
xi: reg emp12 agehh agehh2 educ_h hhsize p0_4 p5_14 p15_19 p35_54 p55p emp1  [pw=attwght] if sample==1, robust cluster(st)

* Hausman test
xi: reg emp12 agehh agehh2 educ_h hhsize p0_4 p5_14 p15_19 p35_54 p55p emp1  if sample==1
estimates store unweighted

xi: reg emp12 agehh agehh2 educ_h hhsize p0_4 p5_14 p15_19 p35_54 p55p emp1 if sample==1 [aw=attwght1]
estimates store weighted

hausman unweighted weighted

