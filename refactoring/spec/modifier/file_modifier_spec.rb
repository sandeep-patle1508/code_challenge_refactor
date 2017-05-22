require_relative '../spec_helper'
require_relative '../../lib/core_extensions/float'
require_relative '../../lib/core_extensions/string'
require_relative '../../lib/modifier/constant'
require_relative '../../lib/file_manager'
require_relative '../../lib/modifier/file_modifier'
require 'csv'
require 'date'


describe FileModifier do
  let(:latest_file) { File.expand_path('../sample_files/project_2012-07-27_2012-10-10_sample.txt', File.dirname(__FILE__)) }
  let(:file_modifier) { FileModifier.new(latest_file, 1, 0.4) }

  before do
    file_modifier.modify
  end

  describe '#modify' do
    let(:output_file) { File.expand_path('../sample_files/project_2012-07-27_2012-10-10_sample_0.txt', File.dirname(__FILE__)) }
    let(:output_data) { CSV.read(output_file, { col_sep: "\t", headers: :first_row }) }
    let(:row_values) { output_data.each_with_object([]) { |row, array| array << row[output_data.headers.index(key)] } }

    context 'sorted rows' do
      let(:key) { 'Clicks' }

      it 'should sort data by clicks in descending order' do
        expect(row_values).to eq(%w(1121 531 423 221 121 81))
      end
    end

    context 'modified rows' do
      context 'LAST_REAL_VALUE_WINS columns' do
        let(:key) { 'Last Avg CPC' }

        it 'Last Avg CPC(LAST_REAL_VALUE_WINS) should not include zero or blank values' do
          expect(row_values).to eq(['45', '23', nil, nil, '12', nil])
        end
      end

      context 'INT_VALUES columns' do
        let(:key) { 'Impressions' }

        it 'modifies Impressions(INT_VALUES) values to string' do
          expect(row_values).to eq(['1600', '200', '', '300', '100', '0'])
        end
      end

      context 'FLOAT_VALUES columns' do
        let(:key) { 'Avg CPC' }

        it 'modifies Avg CPC(FLOAT_VALUES) float values to german float' do
          expect(row_values).to eq(['9,115', '11,3', '1,2', '22,4', '12,4', '0,0'])
        end
      end

      context 'COMMISSIONS columns' do
        let(:key) { 'number of commissions' }

        it 'returns modified commissions(COMMISSIONS) values' do
          expect(row_values).to eq(['9,200000000000001', '22,0', '31,200000000000003', '26,0', '18,0', '2,4000000000000004'])
        end
      end

      context 'COMMISSIONS_VALUES columns' do
        let(:key) { 'Commission Value' }

        it 'returns modified Commission Value(COMMISSIONS) values' do
          expect(row_values).to eq(['0,0', '0,24', '0,6000000000000001', '0,6000000000000001', '0,48', '0,48'])
        end
      end
    end
  end

  after do
    # Delete all generated output files
    FileUtils.rm_f(File.expand_path("../sample_files/project_2012-07-27_2012-10-10_sample.txt.sorted", File.dirname(__FILE__)))
    FileUtils.rm_f(File.expand_path("../sample_files/project_2012-07-27_2012-10-10_sample_0.txt", File.dirname(__FILE__)))
  end
end
