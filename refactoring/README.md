# File Modifier

### Overview of the script functionality.

- Fetch the latest text file from the given path.
  - Fetch all the text files by the given name and regular expression `*given_string*.txt`.
  - Get the last date for the each above files by using regular expression `/\d+-\d+-\d+_[[:alpha:]]+\.txt` (Eg: project_2012-07-27_2012-10-10_performancedata => 2012-10-10).
  - Select one file with the latest date.
- Sort the input file by 'Clicks' column in descending order.
- Write the output in to new file with the same file name but with an extension 'sorted' (Eg: 'filname.txt.sorted').
- Modify the column values of the sorted file.
  - Convert all the column values defined with in LAST_REAL_VALUE_WINS constant to nil, if the values are either nil, 0 or blank.
  - Convert all the column values defined with in INT_VALUES constant to string.
  - Convert all the column values defined with in FLOAT_VALUES constant to german float values.
  - Calculate and update all the column values defined with in COMMISSIONS constant by using below formula 
    - cancellation_factor * commision_value
  - Calculate and update all the column values defined with in COMMISSIONS_VALUES constant by using below formula -
    - cancellation_factor * sale_amount_factor * column_value
- Write the updated data into output files
  - The maximum length for an output file should be 1_20_000 lines including header.
  - If the file exceeds the above limit, a new output file should be created with the increameting index value. (Eg: filename_0.txt, filename_1.txt)
  
### Highlights of refactoring
- I have removed the use of Combiner class to combine the files since here we have only one input file and we do not need to combine it. Combiner class is useful when we need to combine more than two files on the basis of a given column.
- Also, we can avoid creating sorted file by creating array of objects for each row and then perform sort operation but, as mentioned in the email we should not change the output of script. Original script was resulting two output files one for sorted and other for modified values. I maintained the same ouput behaviour.

### Unbundle 
- git clone code_challenge_refactor.bundle -b master repo

### To run the test cases for file modifer class
- rspec spec/modifier/file_modifier_spec.rb

####### Please find all sample input files in `sample_input_files` folder with in the root directory.
