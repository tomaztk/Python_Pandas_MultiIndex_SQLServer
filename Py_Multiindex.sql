/* ****************************
*
* Desc: Pandas multiindex with 
*    sp_execute_external_script
* Author: Tomaz Kastrun
* Date: 26.06.2019
* Blog: tomaztsql.wordpress.com
* 
******************************/


USE SQLPy;
GO

/*
-- Configuring environment if needed

sp_configure;
GO

sp_configure 'show advanced options',1;
GO

RECONFIGURE;
GO


sp_configure 'external scripts enabled',1;
GO

RECONFIGURE;
GO
*/


/*
-- MultiIndex with inplace True - does not return index
EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import io
import pandas as pd

data = io.StringIO(''''''date,language,version
2019-05-12,python,6
2019-05-13,python,5
2019-05-14,python,10
2019-05-12,t-sql,12
2019-05-13,t-sql,12
2019-05-14,t-sql,12'''''')

df = pd.read_csv(data)
df.set_index([''date'', ''language''], inplace=True)
OutputDataSet=df'



EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import io
import pandas as pd

data = io.StringIO(''''''date,language,version
2019-05-12,python,6
2019-05-13,python,5
2019-05-14,python,10
2019-05-12,t-sql,12
2019-05-13,t-sql,12
2019-05-14,t-sql,12'''''')

df = pd.read_csv(data)
df.set_index([''date'', ''language''], inplace=False)
OutputDataSet=df'

*/


EXEC sp_execute_external_script
	 @language = N'Python'
	,@script = N'
import pandas as pd


dt = pd.DataFrame([
                    [''2019-05-12'',''python'',6],
                    [''2019-05-13'',''python'',5],
                    [''2019-05-14'',''python'',10],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-13'',''t-sql'',12],
                    [''2019-05-14'',''t-sql'',12]
                  ],
                  columns = [''date'',''language'',''version''])

OutputDataSet = dt'
WITH RESULT SETS
((
 py_date SMALLDATETIME
,py_lang VARCHAR(10)
,py_ver TINYINT

))




-- MultiIndex with inplace False

EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import numpy as np
import pandas as pd

dt = pd.DataFrame([
                    [''2019-05-12'',''python'',6],
                    [''2019-05-13'',''python'',5],
                    [''2019-05-14'',''python'',10],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-13'',''t-sql'',12],
                    [''2019-05-14'',''t-sql'',12]
                  ],
                  columns = [''date'',''language'',''version''])


dt.set_index([''language'', ''version''], inplace=False)
OutputDataSet=dt'



-- MultiIndex with inplace True
-- Produces an Error
EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import pandas as pd

dt = pd.DataFrame([
                    [''2019-05-12'',''python'',6],
                    [''2019-05-13'',''python'',5],
                    [''2019-05-14'',''python'',10],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12]
                  ],
                  columns = [''date'',''language'',''version''])


dt.set_index([''language'', ''version''], inplace=True)
OutputDataSet=dt'
WITH RESULT SETS
((
 py_date SMALLDATETIME
,py_lang VARCHAR(10)
,py_ver TINYINT
))





-- MultiIndex with inplace True
EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import pandas as pd

dt = pd.DataFrame([
                    [''2019-05-12'',''python'',6],
                    [''2019-05-13'',''python'',5],
                    [''2019-05-14'',''python'',10],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12]
                  ],
                  columns = [''date'',''language'',''version''])


dt.set_index([''language'', ''version''], inplace=True)
OutputDataSet=dt'
WITH RESULT SETS
((
 py_date SMALLDATETIME
))


-- MultiIndex with inplace True
-- adding a concatenated value
EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import pandas as pd

dt = pd.DataFrame([
                    [''2019-05-12'',''python'',6],
                    [''2019-05-13'',''python'',5],
                    [''2019-05-14'',''python'',10],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12],
                    [''2019-05-12'',''t-sql'',12]
                  ],
                  columns = [''date'',''language'',''version''])

dt[''PreservedIndex''] = dt[''language''].astype(str) + '';'' + dt[''version''].astype(str)

dt.set_index([''language'', ''version''], inplace=True)
OutputDataSet=dt'
WITH RESULT SETS
((
  py_date SMALLDATETIME
 ,py_PreservedIndex VARCHAR(30)
))




-- Going from T-SQL
-- And why T-SQL constraints does not play a role in Python

DROP TABLE IF EXISTS PyLang

CREATE TABLE PyLang (
	 [Date] DATETIME NOT NULL
	,[language] VARCHAR(10) NOT NULL
	,[version] INT
	,CONSTRAINT PK_PyLang PRIMARY KEY(date, language)
)


INSERT INTO PyLang (date, language, version)
		  SELECT '2019-05-12', 'python', 6
UNION ALL SELECT '2019-05-13', 'python', 5
UNION ALL SELECT '2019-05-14', 'python', 10
UNION ALL SELECT '2019-05-12', 't-sql', 12
UNION ALL SELECT '2019-05-13', 't-sql', 12
UNION ALL SELECT '2019-05-14', 't-sql', 12

SELECT * FROM PyLang		



-- Python Pandas with different index

EXEC sp_execute_external_script
 @language = N'Python'
,@script = N'

import pandas as pd

dt = InputDataSet
dt[''PreservedIndex''] = dt[''language''].astype(str) + '';'' + dt[''version''].astype(str)
dt.set_index([''language'', ''version''], inplace=True)
OutputDataSet=dt'
,@input_data_1 = N'SELECT * FROM PyLang'
WITH RESULT SETS
((
  py_date SMALLDATETIME
 ,py_MyPreservedIndex VARCHAR(40)
))
