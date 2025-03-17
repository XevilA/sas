/* นำเข้าข้อมูลข้อมูลการท่องเที่ยวภายในประเทศ.xlsx */
PROC IMPORT DATAFILE="/home/u64189031/ข้อมูลการท่องเที่ยวภายในประเทศ.xlsx"
    DBMS=XLSX
    OUT=domestic_tourism
    REPLACE;
RUN;

/* นำเข้าข้อมูลสถิตินักท่องเที่ยว_2566.xlsx */
PROC IMPORT DATAFILE="/home/u64189031/สถิตินักท่องเที่ยว_2566.xlsx"
    DBMS=XLSX
    OUT=tourist_stats_2066
    REPLACE;
RUN;

/* นำเข้าข้อมูลสถิตินักท่องเที่ยว_2567.xlsx */
PROC IMPORT DATAFILE="/home/u64189031/สถิตินักท่องเที่ยว_2567.xlsx"
    DBMS=XLSX
    OUT=tourist_stats_2067
    REPLACE;
RUN;

/* ตรวจสอบโครงสร้างข้อมูล */
PROC CONTENTS DATA=domestic_tourism; RUN;
PROC CONTENTS DATA=tourist_stats_2066; RUN;
PROC CONTENTS DATA=tourist_stats_2067; RUN;
