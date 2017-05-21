# Constant values used in modifier
module Modifiers
  module Constant
    # Column names
  	KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
  	LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type',
  		'Subid', 'Paused', 'Max CPC', KEYWORD_UNIQUE_ID, 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
  	LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
  	INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks',
  		'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
  	FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']
  	COMMISSIONS = ['number of commissions']
  	COMMISSIONS_VALUES = ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value',
  		'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value']

  	# Rows per file allowed
  	LINES_PER_FILE = 120000

  	# Options for file read/write
  	DEFAULT_CSV_OPTIONS = { col_sep: "\t", headers: :first_row }
  	EXTENDED_CSV_OPTIONS = DEFAULT_CSV_OPTIONS.merge({ :row_sep => "\r\n" })
  end
end
