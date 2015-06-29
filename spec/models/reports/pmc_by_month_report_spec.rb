require "rails_helper"
require "models/reports/source_by_month_report_shared_examples"

describe "Running a SourceByMonthReport for Pmc" do
  include_examples "SourceByMonthReport examples", source_factory: :pmc
end
