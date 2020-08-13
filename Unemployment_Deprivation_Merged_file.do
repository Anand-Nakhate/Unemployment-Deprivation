*Unemp_Deprivation.do
*Do-File for unemployment deprivation according to religious gropus - Buddhist
*Author: Nakhate Anand Theertha
*Date: 20 April 2020


global data "<insert location of folder where you have saved Gardin_unemp_1.dta" 

use "$data\Gardin_unemp", clear


	desc
	unemp unemployed [aw=w] , hid(hid) gamma(1)
	unemp hgap [aw=w] , hid(hid)
	ret list
	gen hs=1
	unemp hgap [aw=w], hid(hid) hs(hs)
	unemp hgap [aw=w], hid(hid) hs(hsize)
	unemp hgap [aw=w] , hid(hid) hs(hsize) gen(u)
	desc u_*
	gen mu_2=-u_2
	glcurve u_2 [aw=w*hsize] , sort(mu_2)
	akdensity u_1 if u_1>0 [aw=w*hsize], at(u_1)
	unemp hgap [aw=w] if country==1, hid(hid) hs(hsize) th(.2) gamma(0 1 2 3) alpha(1 2 3 4)
	 unemp unemployed [aw=w], hid(hid) g(1) a(1)
	unemp unemployed [aw=w] if head==1 , hid(hid) g(1) a(1)
	unemp unemployed [aw=w] if head==1 , hid(hid) hs(hsize) g(1) a(1)
	unemp unemployed [aw=w] if head==1 , hid(hid) hs(hsize) g(1) a(1)
	 unemp unemployed [aw=w], hid(hid) hs(hsize) thao(1) g(1) a(1)
	 unemp hgap [aw=w], hid(hid) hs(hsize) decomp
	 cap program drop hhu

        program def hhu

        unemp hgap [aw=w], hid(hid) hs(hsize)

        end

        bootstrap r(U_0_2) r(U_1_2) r(U_2_2) if country==1, reps(10): hhu

        estat bootstrap
