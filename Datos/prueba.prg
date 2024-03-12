*Note: This code should be made generic
*      so it can be reused as general solution

*      It will work for the data set you've
*      provided. Although as stated, it's specific
*      to your supplied problem and should be
*      made more general for reuse.
*
*      Also, the function should validate the
*      length of the SQL generation command to
*      insure it falls within the limits of VFP.
*      Particularly table field counts(255-254)
*      and command line lengths(8192).

************************************************************
*-- Program:          P_VFP_PivotTable
*-- Author:           Darrell C. Greenhouse
*-- Last Upate:
*-- Created:          2003.05.20
*-- Description:
*-- Pass:
*-- Returns:
*-- Called by:
*-- Calls:
*-- Assumuptions:
*-- Notes:
*-- Todo:
*-- Revisions:
************************************************************

* Generate the source data

LOCAL lcDataPoints, lnDataPoints, i

lcDataPoints = ;
  'aaaa,1,10'+CHR(13)+;
  'aaaa,2,11'+CHR(13)+;
  'aaaa,3,14'+CHR(13)+;
  'aaaa,4,21'+CHR(13)+;
  'bbbb,1,11'+CHR(13)+;
  'bbbb,2,11'+CHR(13)+;
  'bbbb,3,12'+CHR(13)+;
  'cccc,1,13'

lnDataPoints = ALINES(laDataPoints,lcDataPoints)

CREATE CURSOR sourcedata (NAME c(4), SIZE N(1), VALUE N(2))

FOR i = 1 TO lnDataPoints
  INSERT INTO sourcedata (NAME,SIZE,VALUE) VALUES;
    ( LEFT(laDataPoints(i),4), ;
    INT(VAL(SUBSTR(laDataPoints(i),6,1))), ;
    INT(VAL(SUBSTR(laDataPoints(i),8,2))) )
NEXT


* Create a x-ref table (pivot)
* This is where the actual work is.
* This area should be made generic, so
* calls into a the function created from
* this base code can perform the discovery
* of X-Refs itself.
* i.e.
* Function GenXRef(tcSource, tcTarget, lcXAxis, lcYAxis, lcZAxis)
* Where:
* lcXAxis is the field that will drive the rows
* lcYAxis drives the columns
* lcZAxis supplies the values
*

LOCAL ARRAY laYAxis[1]
LOCAL lnYAxisCount
laYAxis = ""
lnYAxisCount = 0

GO TOP IN "sourcedata"
SCAN
  * Tabulate number of unique values of field to pivot on
  * Size in this case
  IF ASCAN( laYAxis, "Size"+ALLT(STR(sourcedata.SIZE)) ) == 0
    lnYAxisCount = lnYAxisCount + 1
    DIME laYAxis[lnYAxisCount]
    laYAxis[lnYAxisCount] = "Size"+ALLT(STR(sourcedata.SIZE))
  ENDIF
ENDSCAN
=ASORT(laYAxis)


* Generate a SQL Table creation command

LOCAL lcSQLCreateCommand

lcSQLCreateCommand = "(name c(4),"

FOR i = 1 TO lnYAxisCount
  lcSQLCreateCommand = lcSQLCreateCommand + ;
    laYAxis[ i ] + " n (2)" + ;
    IIF(i<lnYAxisCount,",",")")
NEXT

CREATE CURSOR PIVOT &lcSQLCreateCommand
INDEX ON NAME TAG NAME

LOCAL lcPivotY, lcPivotX
SELECT sourcedata
SCAN
  lcPivotY = "size"+ALLT(STR(sourcedata.SIZE))
  lcPivotX = sourcedata.NAME

  IF SEEK(lcPivotX,"pivot") && Expected case after a few iterations
    REPLACE &lcPivotY WITH sourcedata.VALUE IN "pivot"
  ELSE
    INSERT INTO PIVOT ( NAME, (lcPivotY) ) VALUES ;
      ( lcPivotX, sourcedata.VALUE)
  ENDIF
ENDSCAN

SELECT * FROM PIVOT