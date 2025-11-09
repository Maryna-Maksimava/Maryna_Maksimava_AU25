------------------------
2
-------------------------
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;
---------------
SELECT 10000000

Query returned successfully in 9 secs 756 msec.
---------------------------------------------

"oid","table_schema","table_name","row_estimate","total_bytes","index_bytes","toast_bytes","table_bytes","total","index","toast","table_size"
418270,"public","table_to_delete","-1","602464256","0","8192","602456064","575 MB","0 bytes","8192 bytes","575 MB"

--------------------------------------------
DELETE FROM table_to_delete
WHERE REPLACE(col, 'veeeeeeery_long_string','')::int % 3 = 0;
--------------------------------
DELETE 3333333

Query returned successfully in 9 secs 892 msec.
-----------------------------------
"oid","table_schema","table_name","row_estimate","total_bytes","index_bytes","toast_bytes","table_bytes","total","index","toast","table_size"
418270,"public","table_to_delete","1.0000364e+07","602611712","0","8192","602603520","575 MB","0 bytes","8192 bytes","575 MB"
--------------------------------------------------------
VACUUM FULL VERBOSE table_to_delete;
-------------------------
INFO:  vacuuming "public.table_to_delete"
INFO:  "public.table_to_delete": found 527880 removable, 6666667 nonremovable row versions in 73536 pages
VACUUM

Query returned successfully in 5 secs 201 msec.
----------------------------------------------------------
"oid","table_schema","table_name","row_estimate","total_bytes","index_bytes","toast_bytes","table_bytes","total","index","toast","table_size"
418270,"public","table_to_delete","6.666667e+06","401645568","0","8192","401637376","383 MB","0 bytes","8192 bytes","383 MB"
----------------------------------------------------
DROP TABLE IF EXISTS table_to_delete;
CREATE TABLE table_to_delete AS
SELECT 'veeeeeeery_long_string' || x AS col
FROM generate_series(1,(10^7)::int) x;
----------------------------------------------------
SELECT 10000000

Query returned successfully in 10 secs 533 msec.
-----------------------------------------------
TRUNCATE table_to_delete;
---------------------------------------
TRUNCATE TABLE

Query returned successfully in 82 msec.
