**คำถามข้อที่ 1:**

**1.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** รวมข้อมูลจากไฟล์ `TouristStats2023` และ `TouristStats2024` เข้าด้วยกัน เพื่อให้สามารถวิเคราะห์ข้อมูลข้ามปีได้
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA CombinedStats;
    SET TouristStats2023 TouristStats2024; /* รวมข้อมูลจากทั้งสองปี */
RUN;

```

**1.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   จัดลำดับประเทศตามจำนวนนักท่องเที่ยว (`NumberOfTourists`) มากไปน้อยในแต่ละภูมิภาค (`Region`) และแต่ละปี (`Year`) โดยใช้ `PROC SORT`
    -   เลือก 2 อันดับแรกในแต่ละกลุ่ม (ปีและภูมิภาค) โดยใช้ `DATA` step ร่วมกับ `BY` statement และตัวแปรอัตโนมัติ `_N_`
    -   เปรียบเทียบว่าประเทศใดบ้างที่อยู่ใน 2 อันดับแรกของแต่ละภูมิภาคทั้งสองปี โดยใช้ `PROC SQL` เพื่อทำการ `INNER JOIN` บน `Region` และ `Country` ที่มาจากข้อมูลของปี 2566 และ 2567
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ตาราง `Top2Tourists` จะแสดง 2 อันดับแรกของประเทศที่มีนักท่องเที่ยวเข้าไทยมากที่สุดในแต่ละภูมิภาคสำหรับปี 2566 และ 2567
    -   ตาราง `Top2BothYears` จะแสดงรายชื่อประเทศที่อยู่ใน 2 อันดับแรกของแต่ละภูมิภาคทั้งสองปี ซึ่งจะช่วยให้ทราบถึงกลุ่มประเทศหลักที่ยังคงเป็นแหล่งนักท่องเที่ยวสำคัญ

**คำถามข้อที่ 2:**

**2.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** รวมข้อมูลจากไฟล์ `TouristStats2023` และ `TouristStats2024` เข้าด้วยกัน
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA MonthlyStats;
    SET TouristStats2023 TouristStats2024;
RUN;

```

**2.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   จัดลำดับประเทศตามจำนวนนักท่องเที่ยว (`NumberOfTourists`) มากไปน้อยในแต่ละภูมิภาค (`Region`) และแต่ละปี (`Year`) โดยใช้ `PROC SORT`
    -   เลือก 2 อันดับแรกในแต่ละกลุ่ม (ปีและภูมิภาค) โดยใช้ `DATA` step
    -   แสดงแนวโน้มรายเดือน (`Month`) ของจำนวนนักท่องเที่ยวสำหรับ 2 อันดับแรกนี้ โดยใช้ `PROC SGPLOT` เพื่อสร้างกราฟเส้น
    -   สรุปเดือนที่นักท่องเที่ยวจากแต่ละประเทศเข้ามามากที่สุด โดยใช้ `PROC MEANS` เพื่อหาค่าสูงสุดของ `NumberOfTourists` และเดือนที่เกิดค่าสูงสุด
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   กราฟที่ได้จาก `PROC SGPLOT` จะแสดงให้เห็นแนวโน้มการเข้าไทยของนักท่องเที่ยว 2 อันดับแรกในแต่ละภูมิภาคเป็นรายเดือน ทำให้เห็นภาพรวมว่าช่วงใดของปีที่มีนักท่องเที่ยวจากประเทศนั้นๆ เข้ามามาก
    -   ตาราง `MonthlySummary` จะสรุปเดือนที่มีจำนวนนักท่องเที่ยวสูงสุดสำหรับแต่ละประเทศในแต่ละภูมิภาค ช่วยให้ระบุช่วงเวลาที่ควรให้ความสำคัญในการส่งเสริมการท่องเที่ยว

**คำถามข้อที่ 3:**

**3.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** รวมข้อมูลจากไฟล์ `TouristStats2023` และ `TouristStats2024` เข้าด้วยกัน และสมมติว่ามีตัวแปร `Season` ที่ระบุว่าเป็น High Season หรือ Low Season
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA CombinedStatsWithSeason;
    SET TouristStats2023 TouristStats2024;
    /* สมมติว่ามีตัวแปร Season อยู่แล้ว หากไม่มี อาจต้องสร้างจากข้อมูลเดือน */
RUN;

PROC SORT DATA=CombinedStatsWithSeason OUT=SortedForSeason BY Country NumberOfTourists Year Season;
RUN;

DATA Top2CountriesBySeason;
    SET SortedForSeason;
    BY Country Year;
    IF _N_ LE 2;
RUN;

```

**3.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC FREQ` เพื่อสร้างตาราง Crosstabulation ระหว่าง `Season` และ `Year` สำหรับแต่ละประเทศ (`Country`) ที่มีนักท่องเที่ยวมากที่สุด 2 อันดับแรก
    -   ทำการทดสอบ Chi-Square เพื่อดูว่าสัดส่วนของนักท่องเที่ยวในแต่ละฤดูกาลมีการเปลี่ยนแปลงอย่างมีนัยสำคัญระหว่างปี 2566 และ 2567 หรือไม่
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
PROC FREQ DATA=Top2CountriesBySeason;
    TABLE Season * Year / CHISQ;
    BY Country;
    TITLE 'การทดสอบสัดส่วนการเปลี่ยนแปลงนักท่องเที่ยว (ปี 2566 ไป 2567) ในแต่ละฤดูกาล (แยกตามประเทศ)';
RUN;

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC FREQ` จะแสดงค่า Chi-Square และค่า p-value หากค่า p-value มีค่าน้อยกว่าระดับนัยสำคัญ (เช่น 0.05) แสดงว่าสัดส่วนของนักท่องเที่ยวในแต่ละฤดูกาลมีการเปลี่ยนแปลงอย่างมีนัยสำคัญระหว่างปีสำหรับประเทศนั้นๆ

**คำถามข้อที่ 4:**

**4.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** กรองข้อมูลจาก `TouristStats2024` เฉพาะปี 2567 และช่วง High Season จากนั้นเลือกเฉพาะนักท่องเที่ยวชาวจีน อินเดีย และอเมริกัน และสถานที่คือ กรุงเทพมหานคร เชียงใหม่ และภูเก็ต (สมมติว่ามีตัวแปร `City`)
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA HighSeason2024;
    SET TouristStats2024;
    WHERE Year = 2567 AND Season = 'High'; /* สมมติว่ามีตัวแปร Season */
RUN;

DATA SelectedNationalitiesHS2024;
    SET HighSeason2024;
    WHERE Country IN ('China', 'India', 'United States') AND City IN ('กรุงเทพมหานคร', 'เชียงใหม่', 'ภูเก็ต'); /* สมมติว่ามีตัวแปร City */
RUN;

```

**4.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC FREQ` เพื่อสร้างตาราง Crosstabulation ระหว่าง `Country` และ `City`
    -   ทำการทดสอบ Chi-Square เพื่อเปรียบเทียบสัดส่วนของนักท่องเที่ยวจากแต่ละประเทศที่เยี่ยมชมแต่ละสถานที่
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
PROC FREQ DATA=SelectedNationalitiesHS2024;
    TABLE Country * City / CHISQ;
    TITLE 'การเปรียบเทียบสัดส่วนนักท่องเที่ยวชาวจีน อินเดีย อเมริกัน ในแต่ละสถานที่ (High Season ปี 2567)';
RUN;

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC FREQ` จะแสดงค่า Chi-Square และค่า p-value หากค่า p-value มีค่าน้อยกว่าระดับนัยสำคัญ แสดงว่าสัดส่วนของนักท่องเที่ยวจากแต่ละประเทศที่เยี่ยมชมแต่ละสถานที่มีความแตกต่างกันอย่างมีนัยสำคัญทางสถิติ

**คำถามข้อที่ 5:**

**5.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** กรองข้อมูลจาก `TouristStats2024` เฉพาะปี 2567 และเลือกเฉพาะนักท่องเที่ยวชาวจีน อินเดีย และอเมริกัน และสถานที่คือ กรุงเทพมหานคร เชียงใหม่ และภูเก็ต (สมมติว่ามีตัวแปร `City` และ `Season`)
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA Year2024SelectedNationalities;
    SET TouristStats2024;
    WHERE Year = 2567 AND Country IN ('China', 'India', 'United States') AND City IN ('กรุงเทพมหานคร', 'เชียงใหม่', 'ภูเก็ต');
RUN;

```

**5.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC FREQ` เพื่อสร้างตาราง Crosstabulation ระหว่าง `Season` และ `City` โดยแยกตามประเทศ (`Country`)
    -   ทำการทดสอบ Chi-Square เพื่อเปรียบเทียบสัดส่วนของนักท่องเที่ยวที่เยี่ยมชมแต่ละสถานที่ระหว่าง Low Season และ High Season สำหรับแต่ละประเทศ
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
PROC FREQ DATA=Year2024SelectedNationalities;
    TABLE Season * City / CHISQ;
    BY Country;
    TITLE 'การเปรียบเทียบสัดส่วนนักท่องเที่ยวระหว่าง Low Season กับ High Season ปี 2567 (แยกตามประเทศ)';
RUN;

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC FREQ` จะแสดงค่า Chi-Square และค่า p-value สำหรับแต่ละประเทศ หากค่า p-value มีค่าน้อยกว่าระดับนัยสำคัญ แสดงว่าสัดส่วนของนักท่องเที่ยวที่เยี่ยมชมแต่ละสถานที่มีความแตกต่างกันอย่างมีนัยสำคัญทางสถิติระหว่าง Low Season และ High Season สำหรับประเทศนั้นๆ

**คำถามข้อที่ 6:**

**6.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** กรองข้อมูลจาก `CombinedStats` (ที่รวมข้อมูลปี 2566 และ 2567) เฉพาะนักท่องเที่ยวชาวมาเลเซีย (`Country` = 'Malaysia') ที่เยี่ยมชมจังหวัดสงขลาและภูเก็ต (`City` IN ('สงขลา', 'ภูเก็ต')) และสมมติว่ามีตัวแปร `Revenue`
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA MalaysiaSouth;
    SET CombinedStats;
    WHERE Country = 'Malaysia' AND City IN ('สงขลา', 'ภูเก็ต'); /* สมมติว่ามีตัวแปร City */
RUN;

```

**6.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC TTEST` เพื่อเปรียบเทียบค่าเฉลี่ยของรายได้ (`Revenue`) จากนักท่องเที่ยวชาวมาเลเซียระหว่างปี 2566 และ 2567 โดยแยกตามจังหวัด
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC TTEST` จะแสดงค่า t-statistic, degrees of freedom และค่า p-value หากค่า p-value มีค่าน้อยกว่าระดับนัยสำคัญ แสดงว่าค่าเฉลี่ยของรายได้จากนักท่องเที่ยวชาวมาเลเซียมีความแตกต่างกันอย่างมีนัยสำคัญทางสถิติระหว่างปีสำหรับจังหวัดนั้นๆ

**คำถามข้อที่ 7:**

**7.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** กรองข้อมูลจาก `CombinedStats` เฉพาะนักท่องเที่ยวชาวเยอรมัน ฝรั่งเศส และอเมริกัน (`Country` IN ('Germany', 'France', 'United States')) ที่เยี่ยมชมจังหวัดอุดรธานี นครราชสีมา และหนองคาย (`City` IN ('อุดรธานี', 'นครราชสีมา', 'หนองคาย')) และสมมติว่ามีตัวแปร `Revenue`
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA EuropeAmericaEast;
    SET CombinedStats;
    WHERE Country IN ('Germany', 'France', 'United States') AND City IN ('อุดรธานี', 'นครราชสีมา', 'หนองคาย');
RUN;

```

**7.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC ANOVA` เพื่อทดสอบความแตกต่างของค่าเฉลี่ยรายได้ (`Revenue`) ระหว่างกลุ่มนักท่องเที่ยว (ตามประเทศและเมือง) ในปี 2566 และ 2567 แยกกัน
    -   ใช้ `MEANS` statement ร่วมกับ option `TUKEY` เพื่อทำการทดสอบความแตกต่างรายคู่ (post-hoc test) หากพบว่ามีความแตกต่างอย่างมีนัยสำคัญ
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC ANOVA` จะแสดงค่า F-statistic และค่า p-value หากค่า p-value มีค่าน้อยกว่าระดับนัยสำคัญ แสดงว่ามีอย่างน้อยหนึ่งกลุ่มของนักท่องเที่ยวที่มีค่าเฉลี่ยรายได้แตกต่างจากกลุ่มอื่นอย่างมีนัยสำคัญ
    -   ผลลัพธ์จาก `MEANS` statement พร้อม `TUKEY` option จะระบุว่าคู่ใดบ้างที่มีค่าเฉลี่ยแตกต่างกันอย่างมีนัยสำคัญ

**คำถามข้อที่ 8:**

**8.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** สมมติว่ามี Dataset ชื่อ `RevenueData` ที่มีตัวแปร `Year`, `Season`, `ForeignRevenue`, และ `ThaiRevenue` หากไม่มี อาจจะต้องรวมข้อมูลจาก `DomesticTourismData` เข้ากับ `TouristStats` โดยใช้ตัวแปรที่เหมาะสมในการเชื่อมโยงข้อมูล
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
/* สมมติว่ามี Dataset ชื่อ RevenueData อยู่แล้ว */
/* หากไม่มี อาจต้องมีขั้นตอนการ Merge ข้อมูล เช่น */
/* DATA RevenueData; */
/* MERGE TouristStats2023 (IN=a) DomesticTourismData (IN=b); */
/* BY ... ; /* ระบุตัวแปรที่ใช้ในการ Merge */ */
/* IF a OR b; */
/* RUN; */

```

**8.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC CORR` เพื่อหาค่าสัมประสิทธิ์สหสัมพันธ์ระหว่าง `ForeignRevenue` และ `ThaiRevenue` แยกตามปี (`Year`) และฤดูกาล (`Season`)
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ผลลัพธ์จาก `PROC CORR` จะแสดงค่าสัมประสิทธิ์สหสัมพันธ์ (Correlation Coefficient) ซึ่งบ่งบอกถึงความแข็งแกร่งและทิศทางของความสัมพันธ์ระหว่างรายได้นักท่องเที่ยวต่างชาติและไทย ค่าที่ใกล้เคียง +1 หมายถึงมีความสัมพันธ์เชิงบวกที่แข็งแกร่ง ค่าที่ใกล้เคียง -1 หมายถึงมีความสัมพันธ์เชิงลบที่แข็งแกร่ง และค่าที่ใกล้เคียง 0 หมายถึงไม่มีความสัมพันธ์เชิงเส้นตรง

**คำถามข้อที่ 9:**

**9.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** รวมข้อมูลจาก `TouristStats2023` และ `TouristStats2024` และสมมติว่ามีตัวแปร `Season`
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA CombinedStatsWithSeason;
    SET TouristStats2023 TouristStats2024;
    /* สมมติว่ามีตัวแปร Season */
RUN;

```

**9.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   ใช้ `PROC MEANS` เพื่อหาจำนวนนักท่องเที่ยวรวม (`NumberOfTourists`) ของแต่ละประเทศ (`Country`) ในแต่ละปี (`Year`) เพื่อดูแนวโน้ม
    -   คำนวณเปอร์เซ็นต์การเปลี่ยนแปลงของจำนวนนักท่องเที่ยวระหว่างปี 2566 และ 2567 โดยใช้ `DATA` step และฟังก์ชัน `LAG`
    -   ใช้ `PROC MEANS` อีกครั้งเพื่อหาจำนวนนักท่องเที่ยวรวมของแต่ละประเทศในแต่ละฤดูกาล (`Season`) ในแต่ละปี เพื่อดูแนวโน้มตามฤดูกาล
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
PROC MEANS DATA=CombinedStatsWithSeason NOPRINT;
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

PROC MEANS DATA=CombinedStatsWithSeason NOPRINT;
    CLASS Year Country Season;
    VAR NumberOfTourists;
    OUTPUT OUT=SeasonalTrends SUM=TotalTourists;
RUN;

PROC PRINT DATA=SeasonalTrends;
    TITLE 'จำนวนนักท่องเที่ยวในแต่ละฤดูกาลของแต่ละประเทศ (ปี 2566 และ 2567)';
RUN;

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ตาราง `CountryTrends` แสดงจำนวนนักท่องเที่ยวจากแต่ละประเทศในแต่ละปี ทำให้เห็นแนวโน้มการเข้าไทย
    -   ตาราง `ChangeAnalysis` แสดงเปอร์เซ็นต์การเปลี่ยนแปลงของจำนวนนักท่องเที่ยวระหว่างปี ซึ่งช่วยระบุประเทศที่มีการเติบโตหรือลดลง
    -   ตาราง `SeasonalTrends` แสดงจำนวนนักท่องเที่ยวในแต่ละฤดูกาล ทำให้เห็นความแตกต่างของการเข้าไทยในแต่ละช่วงเวลาของปี ข้อมูลเหล่านี้จะช่วย ททท ในการตัดสินใจว่าจะดึงดูดนักท่องเที่ยวจากชาติใด โดยพิจารณาจากแนวโน้มการเติบโตและจำนวนนักท่องเที่ยว

**คำถามข้อที่ 10:**

**10.1 การจัดการข้อมูล (หากต้องทำก่อน) เพื่อสามารถวิเคราะห์ทางสถิติ**

-   **จัดการอย่างไร:** กรองข้อมูลจาก `MonthlyStats` เฉพาะเดือนเมษายน (`Month` = 4) ของปี 2566 และ 2567 และสมมติว่ามี Dataset `MonthlyRevenueData` ที่มีข้อมูลรายได้รายเดือน
-   **แสดงโปรแกรม SAS สำหรับจัดการข้อมูล:**

SAS

```
DATA AprilStats;
    SET MonthlyStats;
    WHERE Month = 4 AND Year IN (2566, 2567);
RUN;

DATA AprilRevenue;
    SET MonthlyRevenueData; /* สมมติว่ามี Dataset นี้ */
    WHERE Month = 4 AND Year IN (2566, 2567);
RUN;

```

**10.2 การวิเคราะห์ข้อมูลเพื่อตอบคำถาม**

-   **วิเคราะห์อย่างไร ใช้ตัวแปรอะไร ในการวิเคราะห์ด้วยวิธีสถิติ (อธิบาย):**
    -   จัดอันดับประเทศตามจำนวนนักท่องเที่ยว (`NumberOfTourists`) ในเดือนเมษายนของแต่ละปี โดยใช้ `PROC SORT` และ `PROC RANK` เพื่อหา 5 อันดับแรก
    -   ใช้ `PROC TTEST` เพื่อทดสอบว่าค่าเฉลี่ยของรายได้ (`Revenue`) ในเดือนเมษายนมีความแตกต่างกันอย่างมีนัยสำคัญระหว่างปี 2566 และ 2567 หรือไม่
-   **แสดงโปรแกรม SAS สำหรับการวิเคราะห์:**

SAS

```
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

PROC TTEST DATA=AprilRevenue;
    CLASS Year;
    VAR Revenue;
    TITLE 'การทดสอบค่าเฉลี่ยรายได้ในเดือนเมษายนระหว่างปี 2566 กับ 2567';
RUN;

```

-   **ผลลัพธ์การวิเคราะห์ ตอบคำถาม และแปลผลได้อย่างไร:**
    -   ตาราง `Top5April` แสดง 5 อันดับแรกของประเทศที่มีนักท่องเที่ยวเข้าไทยมากที่สุดในเดือนเมษายนของปี 2566 และ 2567
    -   ผลลัพธ์จาก `PROC TTEST` จะแสดงค่า p-value หากมีค่าน้อยกว่าระดับนัยสำคัญ แสดงว่าการเปลี่ยนแปลงของรายได้ในเดือนเมษายนระหว่างปีนั้นมีนัยสำคัญทางสถิติ ข้อมูลเหล่านี้จะช่วยในการตัดสินใจว่าจะขายโปรแกรมท่องเที่ยวให้กับนักท่องเที่ยวชาติใดในเดือนเมษายน 2568 โดยพิจารณาจากจำนวนนักท่องเที่ยวที่เข้ามามากและแนวโน้มรายได้
