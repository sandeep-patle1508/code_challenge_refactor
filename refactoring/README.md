# File Modifier

h3.Overview of the script functionality.

- Fetch the latest text file from the given path.
  - Fetch all the text files by the given name and regular expression `*given_string*.txt`.
  - Get the last date for the each above files by using regular expression `/\d+-\d+-\d+_[[:alpha:]]+\.txt` (Eg: project_2012-07-27_2012-10-10_performancedata => 2012-10-10).
  - Select one file with the latest date.
- Sort the input file by 'Clicks' column in descending order.
- Write the output in to new file with the same file name but with an extension 'sorted' (Eg: 'filname.txt.sorted').
- Modify the column values of the sorted file.
  - Convert all the LAST_REAL_VALUE_WINS column values if the values are either nil, 0 or blank.
  - Convert all INT_VALUES column values to string.
  - Convert all FLOAT_VALUES column values to german float values.
  - Calculate and update all COMMISSIONS column values by using formula - cancellation_factor * commision_value
  - Calculate and update all COMMISSIONS_VALUES column values by using below formula -
    - cancellation_factor * sale_amount_factor * column_value
- Write the updated data into output files
  - The maximum length for an output file should be 1_20_000 lines including header.
  - If the file exceeds the above limit, a new output file should be created. (Eg: filename_0.txt, filename_1.txt)
