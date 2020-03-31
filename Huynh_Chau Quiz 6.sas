
libname classdat "C:\EPI5143 Course Material\datasets"; 
libname ex "C:\EPI5143 Course Material\EPI5143 exercise"; 

*Create dataset with only 2003; 
data nencounter;
set classdat.nencounter;
if year(datepart(EncStartDtm))=2003 then output; 
run; 

proc sort data=nencounter out=nencounters;
by EncPatWID;
run; 

*Creating my INPT flag;
data inpt;
set nencounter;
	by EncPatWID;
	if first.EncPatWID=1 then do; *intialize flag to 0 for first visit of each patient; 
	inpt=0;count=0; 
	end;
	if EncVisitTypeCd in:('INPT') then do; 
	inpt=1;count=count+1; *if statement becomes true, turn flag on=1; 
	end;
	if last.EncPatWID=1 then output; *outputs a single observation for each patient; 
	retain inpt count; *flag; 
run;

ods listing;
options formchar="|----|+|---+=|-/\<>*";
proc freq data=inpt;
tables inpt count;
run;
								  /* The FREQ Procedure 

                                                 Cumulative    Cumulative
                inpt    Frequency     Percent     Frequency      Percent
                ---------------------------------------------------------
                   0        1817       62.85          1817        62.85
                   1        1074       37.15          2891       100.00 */

data emerg;
set nencounter;
	by EncPatWID;
	if first.EncPatWID=1 then do;
	emerg=0;count=0; 
	end;
	if EncVisitTypeCd in:('EMERG') then do; 
	emerg=1;count=count+1;
	end;
	if last.EncPatWID=1 then output;
	retain emerg count; 
run;

ods listing;
options formchar="|----|+|---+=|-/\<>*";
proc freq data=emerg;
tables emerg count;
run;

                               /*  The FREQ Procedure
                                    Cumulative    Cumulative
                emerg    Frequency     Percent     Frequency      Percent
                ----------------------------------------------------------
                    0         913       31.58           913        31.58
                    1        1978       68.42          2891       100.00 */ 


proc transpose data=nencounters out=transposed prefix=encounters;
by EncPatWID;
var EncVisitTypeCd; *retaining the repeated encounter observations per patient; 
run; 

data INPTorEMERG;
set transposed;
inpatient_flag=0;
emergency_flag =0;
array encounters {12} encounters1-encounters12;
	do i=1 to 12;
		if encounters{i} in ('INPT') /*if any encounters in INPT, flag as 1*/ 
		then do inpatient_flag=1;  end; 
			else if encounters{i} in ('EMERG') /*if any encounters in EMERG, flag as 1*/ 
			then do emergency_flag = 1; end;
	total_flag=inpatient_flag + emergency_flag; *counts whether 1 patient had 1 flag or both; 
	end;
run;

proc freq data=INPTorEMERG;
tables total_flag;
run;

*To count the number of times INPT or EMERG appears, convert character to numeric, and sum the values; 
data total; 
set INPTorEMERG; 
array encounters {12} $ encounters1-encounters12; 
	do i=1 to 12;
	if encounters{i}='INPT' or encounters{i}='EMERG' then encounters{i}=1; else encounters{i}=0;
	end;
run; 

data quiz6; 
set total;
sum=sum(of encounters1-encounters12); 
run;

ods listing;
options formchar="|----|+|---+=|-/\<>*";
proc freq data=quiz6; 
table sum;
run;
     
%macro skip; 
a) 1074/2891 = 37.15% of patients had at least 1 inpatient encounter
b) 1978/2891 = 68.42% of patients had at least 1 emergency encounter; 
c) 2891 had at least 1 type of encounter (either inpatient or emergency)
d) 

This table counts for # of encounters for each patient: 
   
                                    The FREQ Procedure

                                                 Cumulative    Cumulative
                 sum    Frequency     Percent     Frequency      Percent
                 --------------------------------------------------------
                   1        2556       88.41          2556        88.41
                   2         270        9.34          2826        97.75
                   3          45        1.56          2871        99.31
                   4          14        0.48          2885        99.79
                   5           3        0.10          2888        99.90
                   6           1        0.03          2889        99.93
                   7           1        0.03          2890        99.97
                  12           1        0.03          2891       100.00


%mend skip; 
                                 

