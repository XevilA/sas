/*--------------------------------------------------------------------------------------------------*/
/* นำเข้าไฟล์ สถิตินักท่องเที่ยว_2566.csv */
/*--------------------------------------------------------------------------------------------------*/
PROC IMPORT DATAFILE="/home/u64189031/สถิตินักท่องเที่ยว_2566.csv"
            OUT=TouristStats2023
            DBMS=CSV
            REPLACE;
    GETNAMES=YES;
    DATAROW=2;
    ENCODING='UTF-8';
RUN;

PROC CONTENTS DATA=TouristStats2023;
RUN;
PROC PRINT DATA=TouristStats2023(OBS=5);
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* นำเข้าไฟล์ สถิตินักท่องเที่ยว_2567.csv */
/*--------------------------------------------------------------------------------------------------*/
PROC IMPORT DATAFILE="/home/u64189031/สถิตินักท่องเที่ยว_2567.csv"
            OUT=TouristStats2024
            DBMS=CSV
            REPLACE;
    GETNAMES=YES;
    DATAROW=2;
    ENCODING='UTF-8';
RUN;

PROC CONTENTS DATA=TouristStats2024;
RUN;
PROC PRINT DATA=TouristStats2024(OBS=5);
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* นำเข้าไฟล์ ข้อมูลการท่องเที่ยวภายในประเทศ.csv */
/*--------------------------------------------------------------------------------------------------*/
PROC IMPORT DATAFILE="/home/u64189031/ข้อมูลการท่องเที่ยวภายในประเทศ.csv"
            OUT=DomesticTourismData
            DBMS=CSV
            REPLACE;
    GETNAMES=YES;
    DATAROW=2;
    ENCODING='UTF-8';
RUN;

PROC CONTENTS DATA=DomesticTourismData;
RUN;
PROC PRINT DATA=DomesticTourismData(OBS=5);
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* เริ่มการวิเคราะห์ข้อมูลตามโจทย์ */
/*--------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------*/
/* 1. จัดลำดับประเทศในแต่ละภูมิภาคที่มีนักท่องเที่ยวเข้าไทยมากที่สุด 2 อันดับแรก แต่ละปี */
/* และประเทศใดที่เข้าไทยมากใน 2 อันดับแรกในแต่ละภูมิภาคทั้ง 2 ปี พ.ศ. */
/* สมมติว่ามีตัวแปร: Year, Region, Country, NumberOfTourists */
/*--------------------------------------------------------------------------------------------------*/
DATA CombinedStats;
    SET TouristStats2023 TouristStats2024;
RUN;

PROC SORT DATA=CombinedStats OUT=SortedStats BY Year Region DESCENDING NumberOfTourists;
RUN;

DATA Top2Tourists;
    SET SortedStats;
    BY Year Region;
    IF _N_ LE 2;
RUN;

PROC PRINT DATA=Top2Tourists;
    BY Year Region;
    ID Country;
    VAR NumberOfTourists;
    TITLE '2 อันดับแรกของประเทศที่มีนักท่องเที่ยวเข้าไทยมากที่สุดในแต่ละภูมิภาคและแต่ละปี';
RUN;

PROC SQL;
    CREATE TABLE Top2BothYears AS
    SELECT t1.Region, t1.Country
    FROM Top2Tourists AS t1
    INNER JOIN Top2Tourists AS t2
        ON t1.Region = t2.Region AND t1.Country = t2.Country
    WHERE t1.Year = 2566 AND t2.Year = 2567
    GROUP BY t1.Region, t1.Country;
QUIT;

PROC PRINT DATA=Top2BothYears;
    TITLE 'ประเทศที่อยู่ใน 2 อันดับแรกของแต่ละภูมิภาคทั้ง 2 ปี พ.ศ.';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 2. แสดงแนวโน้มจำนวนนักท่องเที่ยวเข้าไทยมากที่สุดจากแต่ละภูมิภาค 2 อันดับแรก เป็นรายเดือน */
/* ของปี พ.ศ 2566 และ 2567 และสรุปว่านักท่องเที่ยวจากแต่ละประเทศจะเข้าประเทศไทยมากในช่วงเดือนใด */
/* สมมติว่ามีตัวแปร: Year, Region, Country, Month, NumberOfTourists */
/*--------------------------------------------------------------------------------------------------*/
DATA MonthlyStats;
    SET TouristStats2023 TouristStats2024;
RUN;

PROC SORT DATA=MonthlyStats OUT=RankedMonthlyStats BY Year Region DESCENDING NumberOfTourists;
RUN;

DATA Top2Monthly;
    SET RankedMonthlyStats;
    BY Year Region;
    IF _N_ LE 2;
RUN;

PROC SGPLOT DATA=Top2Monthly;
    SERIES X=Month Y=NumberOfTourists / GROUP=Country LINEATTRS=(THICKNESS=2);
    BY Year Region;
    XAXIS LABEL='เดือน';
    YAXIS LABEL='จำนวนนักท่องเที่ยว';
    TITLE 'แนวโน้มจำนวนนักท่องเที่ยวรายเดือน (2 อันดับแรก) ในแต่ละภูมิภาค ปี 2566 และ 2567';
    KEYLEGEND / TITLE='ประเทศ';
RUN;

PROC MEANS DATA=Top2Monthly NOPRINT;
    CLASS Year Region Country Month;
    VAR NumberOfTourists;
    OUTPUT OUT=MonthlySummary MAX(NumberOfTourists)=MaxTourists Month(MAX(NumberOfTourists))=PeakMonth;
RUN;

PROC PRINT DATA=MonthlySummary;
    TITLE 'เดือนที่มีนักท่องเที่ยวมากที่สุดสำหรับแต่ละประเทศในแต่ละภูมิภาค';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 3. จงทดสอบสัดส่วนการเปลี่ยนแปลงของนักท่องเที่ยวต่างชาติที่เข้าไทยปี 65 ไป 66 และ 66 ไป 67 */
/* ของประเทศที่มีนักท่องเที่ยวเข้าไทยมากที่สุด 2 อันดับแรก ในช่วง high season and low season */
/* หมายเหตุ: คุณมีข้อมูลเพียงปี 2566 และ 2567 ดังนั้นจะทดสอบแค่การเปลี่ยนแปลงระหว่างสองปีนี้ */
/* สมมติว่ามีตัวแปร: Year, Country, Month, NumberOfTourists และคุณได้สร้างตัวแปร Season แล้ว */
/*--------------------------------------------------------------------------------------------------*/
/* **สมมติ:** มีตัวแปร `Season` ใน TouristStats2023 และ TouristStats2024 ที่ระบุ High/Low Season */
PROC SORT DATA=CombinedStats OUT=SortedForSeason BY Country NumberOfTourists Year Season;
RUN;

DATA Top2CountriesBySeason;
    SET SortedForSeason;
    BY Country Year;
    IF _N_ LE 2;
RUN;

PROC FREQ DATA=Top2CountriesBySeason;
    TABLE Season * Year / CHISQ;
    BY Country;
    TITLE 'การทดสอบสัดส่วนการเปลี่ยนแปลงนักท่องเที่ยว (ปี 2566 ไป 2567) ในแต่ละฤดูกาล (แยกตามประเทศ)';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 4. จงเปรียบเทียบสัดส่วนของนักท่องเที่ยวชาวจีน ชาวอินเดีย ชาวอเมริกัน ที่เยี่ยมเยือนแต่ละสถานที่ */
/* กรุงเทพมหานคร เชียงใหม่ ภูเก็ต ช่วง high season ปี 67 มีความแตกต่างอย่างมีนัยสำคัญทางสถิติ หรือไม่ */
/* สมมติว่ามีตัวแปร: Year, Country, City, Season ใน TouristStats2024 */
/*--------------------------------------------------------------------------------------------------*/
DATA HighSeason2024;
    SET TouristStats2024;
    WHERE Year = 2567 AND Season = 'High';
RUN;

DATA SelectedNationalitiesHS2024;
    SET HighSeason2024;
    WHERE Country IN ('China', 'India', 'United States');
RUN;

PROC FREQ DATA=SelectedNationalitiesHS2024;
    TABLE Country * City / CHISQ;
    TITLE 'การเปรียบเทียบสัดส่วนนักท่องเที่ยวชาวจีน อินเดีย อเมริกัน ในแต่ละสถานที่ (High Season ปี 2567)';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 5. จงเปรียบเทียบสัดส่วนของนักท่องเที่ยวชาวจีน ชาวอินเดีย ชาวอเมริกัน ที่เยี่ยมเยือนแต่ละสถานที่ */
/* กรุงเทพมหานคร เชียงใหม่ ภูเก็ต มีความแตกต่างระหว่าง low season กับ high season ปี 67 อย่างมีนัยสำคัญทางสถิติ หรือไม่ */
/* สมมติว่ามีตัวแปร: Year, Country, City, Season ใน TouristStats2024 */
/*--------------------------------------------------------------------------------------------------*/
DATA Year2024SelectedNationalities;
    SET TouristStats2024;
    WHERE Year = 2567 AND Country IN ('China', 'India', 'United States');
RUN;

PROC FREQ DATA=Year2024SelectedNationalities;
    TABLE Season * City / CHISQ;
    BY Country;
    TITLE 'การเปรียบเทียบสัดส่วนนักท่องเที่ยวระหว่าง Low Season กับ High Season ปี 2567 (แยกตามประเทศ)';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 6. จงทดสอบค่าเฉลี่ยประมาณการณ์รายได้จากนักท่องเที่ยวชาวมาเลเซีย ที่มาเยี่ยมเยือนแต่ละสถานที่ในภาคใต้ */
/* จังหวัดสงขลา จังหวัดภูเก็ต มีความแตกต่างระหว่างปี 2566 กับปี 2567 มีความแตกต่างอย่างมีนัยสำคัญทางสถิติ หรือไม่ */
/* สมมติว่ามีตัวแปร: Year, Country, City, Revenue ใน CombinedStats */
/*--------------------------------------------------------------------------------------------------*/
DATA MalaysiaSouth;
    SET CombinedStats;
    WHERE Country = 'Malaysia' AND City IN ('สงขลา', 'ภูเก็ต');
RUN;

PROC TTEST DATA=MalaysiaSouth;
    CLASS Year;
    VAR Revenue;
    WHERE City = 'สงขลา';
    TITLE 'การทดสอบค่าเฉลี่ยรายได้นักท่องเที่ยวมาเลเซียในสงขลาระหว่างปี 2566 กับ 2567';
RUN;

PROC TTEST DATA=MalaysiaSouth;
    CLASS Year;
    VAR Revenue;
    WHERE City = 'ภูเก็ต';
    TITLE 'การทดสอบค่าเฉลี่ยรายได้นักท่องเที่ยวมาเลเซียในภูเก็ตระหว่างปี 2566 กับ 2567';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 7. จงทดสอบค่าเฉลี่ยประมาณการณ์รายได้จากนักท่องเที่ยวที่มาเยี่ยมเยือนแต่ละสถานที่ในภาคอีสาน */
/* จังหวัดอุดรธานี จังหวัดนครราชสีมา จังหวัดหนองคาย มีความแตกต่างระหว่างนักท่องเที่ยวชาวเยอรมัน ฝรั่งเศส และชาวอเมริกัน ใน */
/* ปี 2566 และในปี 2567 อย่างมีนัยสำคัญทางสถิติ หรือไม่ */
/* สมมติว่ามีตัวแปร: Year, Country, City, Revenue ใน CombinedStats */
/*--------------------------------------------------------------------------------------------------*/
DATA EuropeAmericaEast;
    SET CombinedStats;
    WHERE Country IN ('Germany', 'France', 'United States') AND City IN ('อุดรธานี', 'นครราชสีมา', 'หนองคาย');
RUN;

PROC ANOVA DATA=EuropeAmericaEast;
    CLASS Country City;
    MODEL Revenue = Country City;
    WHERE Year = 2566;
    TITLE 'การทดสอบค่าเฉลี่ยรายได้นักท่องเที่ยว (เยอรมัน, ฝรั่งเศส, อเมริกัน) ในภาคอีสาน ปี 2566';
    MEANS Country City / TUKEY;
RUN;

PROC ANOVA DATA=EuropeAmericaEast;
    CLASS Country City;
    MODEL Revenue = Country City;
    WHERE Year = 2567;
    TITLE 'การทดสอบค่าเฉลี่ยรายได้นักท่องเที่ยว (เยอรมัน, ฝรั่งเศส, อเมริกัน) ในภาคอีสาน ปี 2567';
    MEANS Country City / TUKEY;
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 8. จงหาความสัมพันธ์ระหว่างรายได้นักท่องเที่ยวต่างชาติ กับ รายได้จากนักท่องเที่ยวไทย ปี 66 และ 67 */
/* และแยกตามฤดูกาลท่องเที่ยวของปี 66 และ 67 */
/* **สมมติ:** มี Dataset ชื่อ RevenueData ที่มีตัวแปร Year, Season, ForeignRevenue, ThaiRevenue */
/* **หมายเหตุ:** คุณอาจต้องรวมข้อมูลจาก DomesticTourismData เข้ากับ TouristStats เพื่อให้มีข้อมูลรายได้ */
/*--------------------------------------------------------------------------------------------------*/
PROC CORR DATA=RevenueData;
    VAR ForeignRevenue ThaiRevenue;
    WHERE Year = 2566 AND Season = 'High';
    TITLE 'ความสัมพันธ์รายได้ต่างชาติและไทย ปี 2566 (High Season)';
RUN;

PROC CORR DATA=RevenueData;
    VAR ForeignRevenue ThaiRevenue;
    WHERE Year = 2566 AND Season = 'Low';
    TITLE 'ความสัมพันธ์รายได้ต่างชาติและไทย ปี 2566 (Low Season)';
RUN;

PROC CORR DATA=RevenueData;
    VAR ForeignRevenue ThaiRevenue;
    WHERE Year = 2567 AND Season = 'High';
    TITLE 'ความสัมพันธ์รายได้ต่างชาติและไทย ปี 2567 (High Season)';
RUN;

PROC CORR DATA=RevenueData;
    VAR ForeignRevenue ThaiRevenue;
    WHERE Year = 2567 AND Season = 'Low';
    TITLE 'ความสัมพันธ์รายได้ต่างชาติและไทย ปี 2567 (Low Season)';
RUN;

/*--------------------------------------------------------------------------------------------------*/
/* 9. ถ้าท่านเป็น ททท ต้องการดึงลูกค้านักท่องเที่ยวต่างชาติเข้าไทย เพื่อสร้างรายได้ ท่านคิดว่าจะดึงนักท่องเที่ยวจากชาติใด */
/* จงแสดงให้เห็นแนวโน้มการเข้าไทย 2 ปี พ.ศ และ ทดสอบเปอร์เซ็นต์การเปลี่ยนแปลงการเข้าไทยระหว่าง 2 ปี พ.ศ */
/* และระหว่างฤดูกาลท่องเที่ยวของ 2 ปี พ.ศ. ประเทศดังกล่าวเป็นประเทศร่ำรวย */
/* สมมติว่ามีตัวแปร: Year, Country, NumberOfTourists, Season */
/*--------------------------------------------------------------------------------------------------*/
PROC MEANS DATA=CombinedStats NOPRINT;
    CLASS Year Country;
    VAR NumberOfTourists;
    OUTPUT OUT=CountryTrends SUM=TotalTourists;
RUN;

PROC PRINT DATA=CountryTrends;
    TITLE 'แนวโน้มจำนวนนักท่องเที่ยวจากแต่ละประเทศ (ปี 2566 และ 2567)';
RUN;

PROC SORT DATA=CountryTrends OUT=SortedTrends BY Country Year;
RUN;

DATA ChangeAnalysis;
    SET SortedTrends;
    BY Country;
    LAG_Tourists = LAG(TotalTourists);
    IF LAG_Tourists NE . THEN PercentageChange = (TotalTourists - LAG_Tourists) / LAG_Tourists * 100;
    IF Year = 2567;
RUN;

PROC PRINT DATA=ChangeAnalysis;
    WHERE PercentageChange IS NOT NULL;
    TITLE 'เปอร์เซ็นต์การเปลี่ยนแปลงจำนวนนักท่องเที่ยวระหว่างปี 2566 และ 2567';
    ID Country;
    VAR PercentageChange;
RUN;

/* **สมมติ:** มีตัวแปร `Month` และ `Season` ใน MonthlyStats */
PROC MEANS DATA=MonthlyStats NOPRINT;
    CLASS Year Country Season;
    VAR NumberOfTourists;
    OUTPUT OUT=SeasonalTrends SUM=TotalTourists;
RUN;

PROC PRINT DATA=SeasonalTrends;
    TITLE 'จำนวนนักท่องเที่ยวในแต่ละฤดูกาลของแต่ละประเทศ (ปี 2566 และ 2567)';
RUN;

/* (ส่วนการวิเคราะห์เชิงคุณภาพเพื่อเลือกประเทศเป้าหมาย คุณจะต้องพิจารณาจากผลลัพธ์และข้อมูลประเทศร่ำรวย) */

/*--------------------------------------------------------------------------------------------------*/
/* 10. ในเดือนเมษายน 2568 ที่จะมาถึง ท่านจะขายโปรแกรมท่องเที่ยวให้กับนักท่องเที่ยวชาติใด โดยดูจากข้อมูลที่มี */
/* นักท่องเที่ยวชาติที่เข้าไทยมาก 5 ลำดับแรก ในเดือนเมษายน ปี 66 และ 67 และ ทดสอบ % การเปลี่ยนแปลงรายได้ */
/* จากปี 66 มา 67 เพิ่มขึ้นอย่างมีนัยสำคัญทางสถิติหรือไม่ */
/* สมมติว่ามีตัวแปร: Year, Month, Country, NumberOfTourists ใน MonthlyStats และมี Dataset MonthlyRevenueData */
/* ที่มีตัวแปร Year, Month, Country, Revenue */
/*--------------------------------------------------------------------------------------------------*/
DATA AprilStats;
    SET MonthlyStats;
    WHERE Month = 4 AND Year IN (2566, 2567);
RUN;

PROC SORT DATA=AprilStats OUT=RankedApril BY Year DESCENDING NumberOfTourists;
RUN;

PROC RANK DATA=RankedApril OUT=Top5April GROUPS=5;
    BY Year;
    VAR NumberOfTourists;
RUN;

PROC PRINT DATA=Top5April;
    WHERE RANK <= 5;
    BY Year;
    TITLE '5 อันดับแรกของประเทศที่มีนักท่องเที่ยวเข้าไทยมากที่สุดในเดือนเมษายน (ปี 2566 และ 2567)';
RUN;

DATA AprilRevenue;
    SET MonthlyRevenueData; /* **สมมติ:** มี Dataset นี้ */
    WHERE Month = 4 AND Year IN (2566, 2567);
RUN;

PROC TTEST DATA=AprilRevenue;
    CLASS Year;
    VAR Revenue;
    TITLE 'การทดสอบค่าเฉลี่ยรายได้ในเดือนเมษายนระหว่างปี 2566 กับ 2567';
RUN;

/* (พิจารณาประเทศ 5 อันดับแรกและผลการทดสอบรายได้เพื่อตัดสินใจ) */

/*--------------------------------------------------------------------------------------------------*/
/* หมายเหตุสำคัญ: โปรดตรวจสอบความถูกต้องของข้อมูล โดยเฉพาะอย่างยิ่งข้อมูลรายได้ในเดือนมีนาคมและเมษายน */
/* ตามที่ระบุไว้ในรูปภาพที่คุณแนบมา */
/*--------------------------------------------------------------------------------------------------*/
