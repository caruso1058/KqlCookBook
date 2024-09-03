

# KQL Cookbook

By Jules Caruso

Kusto quick reference guide for writing simple to complex queries

[[_TOC_]]

![](RackMultipart20221028-1-u4juca_html_c8f9c702742dca5c.png)­­­

## KQL Data Types

bool

datetime

guid

int

long

real

string

decimal

Timespan (time intervals: ex -> 2d, 1.5h, 30min, 10s, 0.1s)

Dynamic (array or dictionary)

**Comment**

Ctrl + K & C

**Uncomment**

Ctrl + K & U

**Toggle**** Ribbon**

Ctrl + F1

## KQL Quick Guide

Some of the content in this cookbook has been compiled based on Robert Cain's Plural Site Course: [KQL from Scratch](https://app.pluralsight.com/library/courses/kusto-query-language-kql-from-scratch/table-of-contents) and is intended to be used as a quick reference guide for writing KQL queries.

Some example queries can be run on the Microsoft test database **MS Azure Log Data** and can be accessed through the provided link:

**https://help.kusto.windows.net**

[https://ms.portal.azure.com/#blade/Microsoft_Azure_Monitoring_Logs/DemoLogsBlade](https://ms.portal.azure.com/#blade/Microsoft_Azure_Monitoring_Logs/DemoLogsBlade)

# The Basics

## Last Refreshed Time

Return the last time a table was refreshed
```
Table
| summarize max(ingestion_time())
```
## GET COLUMN NAME AND TYPES

returns the column names and data types of a column
```
Table
| getschema
```
## SEARCH

**Search all columns in a table for a specific Value:**
```
Perf
| search"Memory"
```
This searches all columns in the Perf table for any text value that has "Memory"

**Make search case sensitive:**
```
Perf
| search kind = casesensitive "Memory"
```
Search for value in specified tables:
```
search in (Table1, Table2, Table3) "Search Word"
```
Search for value in specific column
```
TableName
| search ColumnName == "Search Value"
```
**Greedy Search **
```
TableName
| search ColumnName : "Search Value"
```
**Wild Cards ***
```
TableName
| search ColumnName : "Search Value"
```
```
TableName
| search * startswith "Search Value"
```
```
TableName
| search * endswith "Search Value"
```
**Combine Multiple Search Criteria**
```
Table
| search "Search Value" and ("Second Search Value" or "Third Search Value")
```
**Example to match multiple criteria**
```
Perf
| search "Free" and "C:" and "JBOX00" and "Free Space*"
```
**Fastest Filter – in**

**in vs in~**
```
Table
| where column in~ ('blah') //NOT CASE SENSITIVE
```
```
Table
| where column in ('blah') //CASE SENSITIVE
| where ClusterId in~ ({ClusterList)}
```
**Match Regular Expressions**

```
Table
| search ColumnName matches regex"[A-Z]:"
```

## WHERE HAS

Unlike SQL you can have multiple where clauses
```
Table
| where TimeColumn >= ago(1h)
```
> d (days), h (hours), m (minutes), s (seconds), ms (milliseconds)

**where** is similar to **search**

search all columns where "value" is found:
```
Table
| where * has "Search Value"
```
```
Table
| where * contains "Search Value"
```
**contains** is not case sensitive to make case sensitive – **contains_cs**

Table | where COLUMN contains_cs "Search Value"

## TAKE

**same as limit. limit can be used wherever take is used**

**take** returns a random sample of rows
```
TableName
| take 10
```
take can be used to test your query, so you do not have to waste time on data retrieval
```
TableName
| where Column1 >= ago(1h)
  and Column2 == "Value"
  and Column3 > 42
| take 5
```
## TOP and SORT

```
Table
| top 20 by Column1desc
  by sorts columns in the above example
```

**Top N Values**

Return the top X number of values

```
Table
| top 10 by <column> desc
```

same result with the sort by and take

```
Table
| sort by <column> desc
| take 5
```

## SUMMARIZE

```
TableName
| summarize count() byColumn1
```

Also can be done on multiple columns:

```
TableName
| summarize count() byColumn1, Column2
```

Rename output

```
TableName
| summarize NEW_COLUMN_NAME = count()
    by Column1, Column2
```

Summarize into logical groups like days _Group By_

```
TableName
| summarize NEW_COLUMN_NAME = count()
    by Column1,
    bin (Column2, 1d)
```

## MAKE-SERIES

**smooths out data compared to summarize**

```
TableName
| make-series count() on ColumnName from datetime(2022-03-15) to now() step 1d
| render timechart
```

Same as using summarize (below) but summarize will not display days with no records

```
TableName
| summarize count() by bin(ColumnName, 1d)
| render timechart
```

_Fancy Summarize:_

```
range mydatevalue from startofday (ago(30d)) to now() step 1
| join kind=leftouter (
TableName
| summarize count() by bin(ColumnName, 1d)
) on mydatevalue
```

**BIN By Months:**

```
let StartingDate =
cluster('sparklefollower.centralus.kusto.windows.net').database('AzureDCMDb').ResourceSnapshotHistoryV1
| summarize startDate = min(PreciseTimeStamp)
| extend startDate = startofday(startDate)
;
let startingTime = toscalar (StartingDate)
;
let TimeSeries =
range StartOfMonth from startofmonth(startingTime) to now() step 1d
| where dayofmonth(StartOfMonth) == 1
;
TimeSeries 
```


## EXTEND

**create new columns based on current table data**

```
Table
| where Column1 == "SomeValue"
| extend NEW_COLUMN_NAME = Column2 / 1000
```

extend can be called once to create multiple columns

```
Table
| where Column1 == "SomeValue"
| extend NEW_COLUMN_NAME = column2 / 1000,
         NEW_COLUMN_NAME2 = column2 * 1000
```

## PROJECT

project is similar to SELECT in SQL. project allows you to return only the specified columns in the project statement

```
Table
| project Column1,
 Column2,
 Column3
```

project-away can be called to return all columns except those specified in the project-away statement

```
Table
| project-away Column23,
      Column24,
      Column25
```

the above result will display all columns except Column23, Column 24, and Column 25

Rename Column

```
Table
| project-rename COLUMN_NEW_NAME = Origional_Column_Name
```

## DISTINCT

```
Table
| distinct Column1 //distinct list of values
```

```
Table
| summarize by COLUMN | summarize count() //Exact
```

```
Table | summarize dcount(COLUMN) //Approximate
```

explicitly state levels of approximation

```
Table | summarize count(COLUMN, 0) //lest accurate
```

```
Table | summarize count(COLUMN, 1)
```

```
Table | summarize count(COLUMN, 2)
```

```
Table | summarize count(COLUMN, 3)
```

```
Table | summarize count(COLUMN, 4) //most accurate
```

```
EventTable
| where EventLevelName == "Error"
| distinct SourceColumn
```

## PRINT

```
print('Hello World!')
```

how to name the output of print column statement:

```
print TheAnswerToLifeTheUniverseAndEverything = 21*2
```

## AGO

```
print ago (365d) //returns last year
```

```
print ago (-365d) //returns one year in the future from now
```

## SORT BY and ORDER BY

these are the same and can be anywhere in the query

default to desc if you want to return asc just add asc to end of line

```
Event
| where TimeGenerated >= ago(365d)
| extend MonthGenerated = startofmonth(TimeGenerated)
| project Source, MonthGenerated
| summarize EventCount=count()
   by MonthGenerated, Source
| sort by MonthGenerated desc, Source asc
```

## BETWEEN

retrieve a range of values

```
Table
| where ColumnNamebetween (70 .. 100)
```

```
Table
| where DateColumn1between ( dateFr(2018-04-01) .. datetime(2018-04-03) )
```

```
Perf
| where CounterName == "% Free Space"
| where CounterValuebetween (70 .. 100)
```

```
Perf
| where CounterName == "% Free Space"
| where TimeGenerated  between (datetime(2020-04-01) .. datetime(2021-03-15))
```

this pulls data starting on 04/01/2020 at midnight to the very beginning of 03/15/2021 at midnight

to work around this bug use startofday and endofday

```
Perf
| where CounterName == "% Free Space"
| where TimeGenerated between ( startofday(datetime(2020-04-01)) .. endofday(datetime(2021-03-15)) )
```

## NOT BETWEEN

```
Perf
| where CounterName == "% Free Space"
| where CounterValue ! between (0.0 .. 69.9)
```

## Format Date & Time

```
Table
| project
format_datetime(DATECOLUMN, "y-M-d")
```

```
Perf
| take 100
| project CounterName,
          YMD = format_datetime(TimeGenerated, "y-M-d"),
          YYYY_MM_DD = format_datetime(TimeGenerated, "yyyy-mm-dd"),
          DateWithTime = format_datetime(TimeGenerated, "MM/dd/yyyy hh:mm tt"),
          DateWithTime2 =  format_datetime(TimeGenerated, "MM/dd/yyyy hh:mm:ss:ms.fff tt")
```

Extract parts of a date into multiple columns

```
Perf
| project Column1,
 DATECOLUMN
 year = datetime_part("year", DATECOLUMN),
 month = datetime_part("month", DATECOLUMN),
 weekofyear = datetime_part("weekOfYear", DATECOLUMN),
 day = datetime_part("day", DATECOLUMN),
 dayofyear = datetime_part("dayOfYear", DATECOLUMN),
 hour = datetime_part("hour", DATECOLUMN),
 minute = datetime_part("minute", DATECOLUMN)
```

Group date/time into buckets

```
Perf
| where TimeGenerated >= ago(1d)
| extend HourofDay = datetime_part("hour", TimeGenerated)
| project HourofDay
| summarize EventCount = count()
                         by HourofDay
| sortbyHourofDayasc
```

Identify start or end of x time:

startofday(), startofweek(), startofmonth(), startofyear()

endofday(), endofweek(), endofmonth(), endofyear()

## iif & CASE


iif is a if/then/else clause

```
Perf
| where CounterName == "% Free Space"
| extend FreeState = iif ( CounterValue < 50, "You might want to look at this", "You are okay")
| project Computer, CounterName, CounterValue, FreeState
```

iif must return a boolean -- if CounterValue < than 50, then, else.

```
Perf
| where CounterName == "% Free Space"
| where TimeGenerated between ( ago(60d) .. now() )
| extend CurrentMonth = iif ( datepart("month", TimeGenerated) == datepart("month", now()), "Current Month", "Past Months" )
| project Computer, CounterName, CounterValue, CurrentMonth
```

case is similar to CASE in SQL

```
Perf
| where CounterName == "% Free Space"
|extend FreeLevel = case(CounterValue < 10, "Critical",
        CounterValue < 30, "Danger",
CounterValue < 50, "Look at this",
"You are okay")
| project Computer, CounterName, CounterValue, FreeLevel
| summarize CompterCount = count()
            by FreeLevel
```

## ISEMPTY and ISNULL

isempty matches on empty text strings

isnull matches on empty number values

isnotempty() finds items that are not null

```
Perf
| where TimeGenerated >= ago(1h)
| extend InstName = iif ( isempty(InstanceName), "NO INSTANCE NAME", InstanceName)
```

```
Table | isnotempty(<coulmn1>)
```

# Intermediate

## SPLIT

split is a delimiting feature

```
Employees
| extend Split_FirstName_LastName = split(Name, "|")
```

Break into separate columns

```
Employees
| extend Split_FirstName_LastName = split(Name, "|")
| extend FirstName = Split_FirstName_LastName [0],
         LastName = Split_FirstName_LastName [1]
```

```
Perf
| where TimeGenerated >= ago(1m)
| extend DateSplit = split(TimeGenerated, "-")
| extend Month = DateSplit[0]
```

## CASE SENSITIVE OPERATORS, NOT OPERATORS, IN OPERATORS

All functions can be turned into case sensitive operators by adding _cs to the end

Non-Case sensitive example

```
Perf
| take 100
| where CounterName contains "BYTES"
```

Case Sensitive Example

```
Perf
| take 100
| where CounterName contains_cs "BYTES"
```

Does not contain

```
Perf
| take 100
| where CounterName !contains "Bytes"
```

in - used to compare a column to a set of values

```
Perf
| take 100
| where CounterName in ("Disk Transfers/sec", "Disk Reads/sec", "Avg. Disk sec/Write")
```

## String Concatenation

```
let month_names = dynamic (['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']);
RawSysLogs
| where timestamp between  ( ago (60d) .. now() )
| where tags has 'adx-vm'
| extend MonthNum = datetime_part ("month", timestamp) -1 //need to set Months to 0 based index in since dynamic lists are 0 based indexed 
| extend MonthName = month_names[MonthNum], YearNumber = datetime_part("year", timestamp)
| extend DateText = strcat (MonthName, " ", format_datetime(timestamp, " dd, yyyy"))
| extend YearMonth = strcat(MonthName, " - ", YearNumber)
```

## PERCENTILES

**Get the Median**

```
Table
| summarize percentile(Column1, 50)
```

```
Table
| whereColumnName == "VALUE"
| summarize percentiles(ColumnName1, 5, 50, 95) by ColumnName2
```

Cleaner columns

```
Table
| where ColumnName == "Value"
| summarize percentiles(ColumnName1, 5, 50, 95) by ColumnName2
| project-renamePercent05 = percentile_CounterValue_5,
  Percent50 = percentile_CounterValue_50,
Percent95 = percentile_CounterValue_95
```

Cleanest approach:

```
Table
| where ColumnName == "Value"
| summarize (Percent05, Percent50, Percent95) = percentiles(ColumnName1, 5, 50, 95) by ColumnName2
```

## COUNTIF

```
Table
| summarize RowCount = countif(ColumnsNamecontains"VALUE") by ColumnName
| sort by ColumnName asc
```

countif will return items with 0 values

remove 0 values

```
Table
| summarize RowCount = countif(ColumnsName contains "VALUE") by ColumnName
| where Row Count > 0
```

## Find and Identify Outliers

```
Table
| summarize NodeCounts = make_list(Nodes)
| extend Outliers = series_outliers(NodeCounts)
| mv-expand NodeCounts to type of(long), Outliers to type of(real)
//Anything greater than 1.5 or less than -1.5 is an outlier
| where Outliers between (-1.5 .. 1.5)
| sort by Outliers
```

## PIVOT

```
Table
| project Column1, Column2
| evaluate pivot(Column2)
| sort by Column1asc
```

## MAX & MIN

```
Table
| where ColumnName == "Value"
| summarize max(ColumnName2)
```

```
Table
| where ColumnName == "Value"
| summarize min(ColumnName2)
```

## SUM & SUMIF

```
Table
| where ColumnName == "VALUE"
| summarize sum(ColumnName2)
```

the same value will be returned in the above and below query

```
Table
| summarize sumif(ColumnName, ColumnName2 == "VALUE")
```

## LET

let statements are a combination of Common Table Expressions (CTEs) & Variables in SQL
let statements can define parameters and queries that can be used elsewhere within your queries

```
let startDate = ago(12h);
Perf
| project Computer, TimeGenerated, CounterName, CounterValue
| where TimeGenerated >= stateDate
```
```
let min CounterValue = 300;
let counterName = "Free Megabytes";
Perf
| project Computer, TimeGenerated, CounterName, CounterValue
| where CounterName == counterName
  and CounterValue <= minCounterValue
```

## JOIN

>| join is the most expensive operator

**ALWAYS** put the big dataset on the **right side** of the JOIN

SMALL Dataset goes on the **left side** of the JOIN

>When left side is **very small** in relation to the Right-side USE: **broadcast**

```
| join hint.strategy=broadcast
```

all various joins in KQL - default is innerunique

join kind = innerunique, inner, leftouter, righouter, fullouter, leftanti, rightanti (returns rows that do not have a match)

join tables that have a common column name:

Table1
| join kind=inner (TABLE2) onCOLUMNNAME
join tables that do not have a common name:

```
Table
| join kind=inner (TABLE2) on $left.Column_from_Main_Table == $right.Column_from_Table2
```

JOIN HINTS by default Kusto will run the query on the right side

```
Table
| join hint.remote=left kind=leftouter TABLE on $left.column == $right.column
```

**Joining sub queries**

```
Perf
| where TimeGenerated >= ago(90d)
| where CounterName  == "% Processor Time"
| project Computer,
          CounterName,
          CounterValue,
          PerfTime = TimeGenerated
| join kind=inner ( Alert
       | where TimeGenerated >= ago(90d)
       | project Computer,
                 AlertName,
                 AlertDescription,
                 ThresholdOperator,
                 ThresholdValue,
                 AlertTime = TimeGenerated
       | where ThresholdValue > 0
       )
    on Computer
```

## UNION

Stack tables together

Columns with the same name will be stacked on top of each other

You can union an unlimited number of tables

```
Table1
| union withsource = "SourceTable" Table2
```

OR
```
union withsource = "SourceTable"
Table1, Table2
```

Specific columns can be projected

```
( Table1
| project Column1, Column2, Column3, Column4 )
| unionwith source = "SourceTable"
( Table2
| projectcolumn1, column2, column3, column4 )
```

How to do a large number of unions:

```
union withsource = "SourceTable"
( Table1
| projectcol1, col2 )
( Table2
| projectcol1, col2 )
( Table3
| projectcol1, col2 )
```

## PREVIOUS & NEXT
These are lead and lag functions in SQL
Return the previous row's value or the next row's value

```
Table
| serialize
| extend PreviousValue = strcat("Previous Value Was ", prev(DESIRED_COLUMN))
```

```
Table
| serialize
| extend NextValue = strcat("Next Value Is ", next(DESIRED_COLUMN))
```

## CUMULATIVE SUM

```
Table
| serialize CumulativeSum = row_cumsum(COLUMNNAME)
```

**Count by Group (group by)**

```
Table
| summarize NewColumnName=count() by Column1, Column2
```

## RANGE

creates a table of specified values

```
range MyNumbers from 1 to 8 step 1
```

```
range LastWeek from ago(7d) to now() step 1d
```

## SERIES_STATS

print the statics of a given column or dataset

```
let x=dynamic ([23, 46, 23, 87, 4, 8, 87, 56, 7, 12, 191]);
print series_stats(x)
```

print a JSON output

```
let x=dynamic ([23, 46, 23, 87, 4, 8, 87, 56, 7, 12, 191]);
print series_stats_dynamic(x)
```

# Advanced

## MACHINE LEARNING

**Regression**

```
range x from 1 to 1 step 1
| project x = range(bin(now(), 1h)-11h, bin(now(), 1h), 1h), 
 y = dynamic ([2,5,6,8,11,15,17,18,25,26,30,30])
| extend (RSquare, Slope, Variance, RVariance, Intercept, LineFit) = series_fit_line(y)
| render timechart
```
```
Perf
| where TimeGenerated > ago(1d)
| where CounterName contains "%"
| where CounterValue > 0
| make-series  TotalMemoryUsed = sum(CounterValue) default = 0
                on TimeGenerated
                in range (ago(1d), now(), 1h)
                by Computer
| extend (RSquared, Slope, Variance, RVariance, Intercept, LineFit)=series_fit_line(TotalMemoryUsed)
| render timechart 
```

**Simple Regression**

```
Table
| extend series_fit_line(y)
| render linechart with (ycolumns=y, series_fit_line_y_line_fit)
```

**Basket**

basket analysis is a frequency analysis based on a combination of data. This looks for the most common occurrences and then the combinations that occur most frequently

```
Perf
| where TimeGenerated >= ago(10d)
| project Computer, ObjectName, CounterName
| evaluate basket()
```

You can add threshold to basket model (if no threshold is stated, the default value is 0.05). The lower the number the loser the analysis.

```
let threshold = 0.09
Perf
| where TimeGenerated >= ago(10d)
| project Computer, ObjectName, CounterName
| evaluate basket(threshold)
```

**AUTOCLUSTER**

Look for patterns in your data

```
Alert
| where TimeGenerated  >= ago(10d)
| evaluate autocluster()
```

You can set the the parameter sizeweight to finetune the scope of the autocluster algorithm 

```
let sizeweight = 0.3;
Alert
| where TimeGenerated  >= ago(10d)
| evaluate autocluster(sizeweight)
```

**REDUCE**

used to find patterns in string data

```
Perf
| where TimeGenerated >= ago(5d)
| project Computer
| reduce by Computer
| order by Count
```

## Create Functions

Example a folder will be created if a folder does not already exist

```
.create-or-alter function with
(folder = "Demo", docstring = "Say hello", skipvalidation = "true")
SayHello(person:string)
{
print greetings = strcat("Hello ", person)
}
//Execute

SayHello("Jules Caruso")
```
## Create Temp Table

```
let TempTable = table("TestTable",
    Column column1 = [1,2,3],
    Column comumn2 = ["A","B","C"]
    );
```

## DROP A FUNCTION

```
.drop function SayHello
```

## Explore Existing Functions

```
.show function <FUNCTION_NAME>
```

## Inspect Wide Rows

```
Table
| take 5
| evaluate narrow()
| summarize make_list(Value) byColumn
```

## Kusto Python Plugin

```
Table
| evaluate python (output_schema, script, script_parameters, external_artifacts)
```

## Turn 1x1 Table into Scalar

```
toscalar()
```

## Run Data Doctor

**Find your query ID:**

```
.showqueries  | whereStartedOn > ago(1d) | take 100
```

## Delete a Specific Record From a Table

```
.delete async table tableName records <| tableName 
| where columnName == value
```

## Delete all Data from a table

```
.clear table table_you_want_to_delete_recordsdata
```

If table has tags

(How to inspect if your table has tags):

```
.show table my_test_table extents
```

Then you can delete specific records with tags:

```
.drop extents <|

.show table my_test_table extents

where tags has "2020-05-01"
```
**Ensure your table is inserted with Tags:**

```
.set-or-appendmy_test_table
with (
folder = 'myfolder'
,tags = '["2020-05-01"]'
) <| datatable (insert_date:datetime,name:string)[
datetime(2020,5,1),"Jules1"
,datetime(2020,5,1),"Jules2"
];
.set-or-appendNodeTransitions_MCF_Gen_4_5
with (
folder = 'DecomQualityIndex'
,tags='["5/27/2022"]'
) <| fNodeTransitionsForMCF();
```

## Create Table

```
.create table TableName ( Column1: int, Column2: string)
with (docstring= "this is a new table created by Jules", folder = "MyFolder")
```

## Rename Table

```
.rename table TableName to NewTableName
```

## Row Count by Item Window Function

```
Table
| order by Column_You_Want_to_Count asc, NumericValue_to_sort desc
| extend rowNumber = row_number(1, prev(Column) != Column)
```

## Performance Testing

```
| consume
```
Consume does not provide result set it simply provides the performance results of the query

Pull full dataset:

```
set notruncation;
```

Run Queries with no memory limits:

```
set notruncation;

set maxmemoryconsumptionperiterator=68719476736;

set max_memory_consumption_per_query_per_node=68719476736;
```

## Ceiling

Returns the smallest integer greater than or equal to the specified number

```
print c1 = ceiling(1.1)
 >> 2
```

## Partition

isolates the dataset into distinct virtual tables by specified column and then performs the set of calculations specified between the parenthesis on each unique table and then unions the results of each virtual table back together for the final output

```
letdemoData = datatable(Env: string, Version:int, BugCount:int)
[
"dev",1, 1,
"test",1, 1,
"prod",1, 1,
"dev",2, 2,
"test",2, 0,
"dev",3, 2,
"test",3, 0,
"prod",2,2,
];
demoData
| partition hint.strategy=shuffle by Env ( summarize ceiling (avg(BugCount)) by Env)
```

## % of Total

```
let percentage =
cluster('sparklefollower.centralus.kusto.windows.net').database('AzureCM').LogNodeSnapshot
| where nodeState == 'Ready'
| summarize stateValues = count() by nodeAvailabilityState
| as T
| extend Percentage = round(100.0 * stateValues / toscalar(T | summarize sum(stateValues)), 2);
percentage
| sort by Percentage
```

## Window Functions

```
Table
| as T
| extend column = toscalar (T| summarizecolumn1 = sum(sum_TotalNodeCount))
| extend percentageOfTotal = round( todecimal((countColumn * 1.000000000) / totalCount), 5)
```

## Meta Data Querying

**Data Volume, Number of tables, Number of Functions**

```
.show extents | summarize sum(RowCount) by TableName
```
```
.show tables | count
```
```
.show functions | count
```
## Cardinality – Distinct Values

When cardinality (distinct values in the dataset) is > 1 million values THEN USE 
```
| summarize hint.shufflekey = column <expression>
```
