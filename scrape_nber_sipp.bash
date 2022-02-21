#!/bin/bash
# -------------------------------------------------------------------------------- #
# This program pulls the SIPP files from NBER and creates the .DTA for use         #
# -------------------------------------------------------------------------------- #

# tracking code
exec > >(tee pull_sipp_$(date +"%F")_$(date +"%H_%M_%S").txt)
exec 2>&1

# --------------------------------- USER OPTIONS --------------------------------- #
# SET THESE ACCORDING TO YOUR OPERATING SYSTEM!
# 1) OS should be: mac, linux, windows
os="linux"
# 2) Proxy settings (only change http_proxy if proxy=on)
proxy=off    																# on or off
http_proxy=""                             	# only set if ${proxy}="on"
# 3) How your machine calls Stata
stata="stata-se -b"
#4) Which panels for the SIPP?
panels="1996"

# --------------------------------- SYSTEM SET UP -------------------------------- #
# setting the proxy from above
if [ "${proxy}" == "on" ]; then
	export http_proxy=${http_proxy}
fi
# correcting the sed command across operating systems
if [ "${os}" == "mac" ]; then
	sed="sed -i.bak"
else
	sed="sed -i "
fi
# directories
sipp_pull="`pwd`"							# initialize in current folder
# links for NBER and Census datasites:
nber="http://data.nber.org/sipp"
echo "OS: ${os}; sed: ${sed}; proxy: ${proxy}; Stata: ${stata}"
# ------------------------------------------------------------------------------- #
# grab PCE data first and submit cleaning program
# source controls.bash
# while [ `ls -l pce.xlsx | wc -l` -lt 1 ]; do
# 	sleep 10
# done
#
# ${stata} do/controls.do

# Download and clean each panel individually to economize on disp space
for year in ${panels}; do
    cd ${sipp_pull}
    mkdir ${year}
    mkdir ${year}/components
		cd ${sipp_pull}

		## Download raw data files
# 		Download 1990-1993 panels
# 		if [ ${year} -lt 1996 ]; then
# 			yy=${year:2:2}
# 			cd ${year}/components
# 			core and topical module
# 			for i in {1..9}; do
# 				wget -r -nd ${nber}/${year}/sipp${yy}w${i}.dat.Z
# 				wget -r -nd ${nber}/${year}/sipp${yy}t${i}.dat.Z
# 
# 				wget -r -nd ${nber}/${year}/sip${yy}w${i}.do
# 				wget -r -nd ${nber}/${year}/sip${yy}w${i}.dct
# 				wget -r -nd ${nber}/${year}/sip${yy}t${i}.do
# 			  wget -r -nd ${nber}/${year}/sip${yy}t${i}.dct
# 			done
# 			full panel
# 			wget -r -nd ${nber}/${year}/sipp${yy}fp.dat.Z
# 			wget -r -nd ${nber}/${year}/sip${yy}fp.do
# 			wget -r -nd ${nber}/${year}/sip${yy}fp.dct
# 			job id
# 			wget -r -nd ${nber}/${year}/sipp_revised_jobid_file_${year}.zip
# 			wget -r -nd ${nber}/${year}/sip${yy}jid.do
# 			wget -r -nd ${nber}/${year}/sip${yy}jid.dct
# 
# 			gunzip -f *.Z
# 			unzip -o \*.zip
# 
# 			for f in $(ls *.dct *.do); do
# 				${sed} "s/\/home\/data\/sipp\/${year}\///g" ${f}
#     		${sed} "s/\/homes\/data\/sipp\/${year}\///g" ${f}
# 				${sed} "s/log/*log/g" ${f}
# 				${sed} "s/save/*save/g" ${f}
# 			done
# 
# 			turn core, topical, and full panel dat into dta
# 			cd ${sipp_pull}
# 			yy=${year:2:2}
# 			${sed} "s/.*local year =.*/local year = ${yy}/" do/dtamake.do
# 			${stata} $sipp_pull/do/dtamake.do &
# 
# 			rm *.Z
# 			rm *.zip
# 
# 		Download 1996 panel
# 		elif [ ${year} -eq 1996 ]; then
# 			cd ${year}
# 			core and topical modules
# 			for i in {1..12}; do
# 				wget -r -nd ${nber}/1996/sipp1996sip96w${i}d.dta
#  				wget -r -nd ${nber}/1996/sipp1996tm96puw${i}.dta
# 			done
# 			longitudinal weight
# 			wget -r -nd ${nber}/1996/sipp1996ctl_fer.dta
# 			wget -r -nd ${nber}/1996/sipp1996lrw96pnl.dta
# 			mv sipp1996ctl_fer.dta sipp96lw.dta
# 
# 		Download 2001 panel
# 		elif [ ${year} -eq 2001 ]; then
# 			cd ${year}
# 			core and topical modules
# 			for i in {1..9}; do
# 				wget -r -nd ${nber}/2001/sipp01w${i}.dta
# 				wget -r -nd ${nber}/2001/sipp01t${i}.dta
# 			done
# 			longitudinal weight
# 			wget -r -nd ${nber}/2001/sipp01lw9.dta
# 			mv sipp01lw9.dta sip01lw9.dta
# 
# 		Download 2004 and 2008 panels
# 		elif [ ${year} -eq 2004 ] || [ ${year} -eq 2008 ]; then
# 			cd ${year}
# 			yy = ${year:2:2}
# 			for i in {1..16}; do
# 				wget -r -nd ${nber}/${year}/sippl${yy}puw${i}.dta
# 				wget -r -nd ${nber}/${year}/sippp${yy}putm${i}.dta
# 				wget -r -nd ${nber}/${year}/sipplgtwgt${year}w{i}.dta.dta
# 			done
# 		fi

		### Make a single panel dta file
		if [ ${year} -eq 1993 ]; then
			cd ${pull_sipp}
			${stata} do/final_90_93.do &
			for yy in 90 91 92 93; do
				while [ `ls -l sipp${yy}.dta | wc -l` -lt 1 ]; do
					echo "wait to drop 19${yy}"
					sleep 100
				done
				${sed} "s/.*local panel =.*/local panel = 19${yy}/" do/extract_sipp_all.do
				${stata} do/extract_sipp_all.do &
				while [ `ls -l sip${yy}.dta | wc -l` -lt 1 ]; do
					sleep 100
				done
			done
		fi

		if [ ${year} -eq 1996 ] || [ ${year} -ge 2001 ]; then
			cd ${sipp_pull}
			${sed} "s/.*local panel =.*/local panel = ${year}/" do/extract_sipp_all.do
			${stata} -b do/extract_sipp_all.do &
			yy=${year:2:2}
			while [ `ls -l sip${yy}.dta | wc -l` -lt 1 ]; do
			 	echo "waiting to drop intermediate ${year} files..."
			 	sleep 100
			done
		fi
done

>&2
