require 'csv'
require 'date'

module RakeReportHelper
  def self.write(filename, csv)
    if csv.nil?
      puts "No data for report \"#{filename}\"."
    elsif Report.write(filename, csv)
      puts "Report \"#{filename}\" has been written."
    else
      puts "Report \"#{filename}\" could not be written."
    end
  end
end

namespace :report do

  desc 'Generate CSV file with ALM stats for public sources'
  task :alm_stats => :environment do
    report = AlmStatsReport.new(Source.installed.without_private)
    RakeReportHelper.write("alm_stats.csv", report.to_csv)
  end

  desc 'Generate CSV file with ALM stats for private and public sources'
  task :alm_private_stats => :environment do
    report = AlmStatsReport.new(Source.installed)
    RakeReportHelper.write("alm_private_stats.csv", report.to_csv)
  end

  desc 'Generate CSV file with Mendeley stats'
  task :mendeley_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "mendeley").first
    next if source.nil?

    report = MendeleyReport.new(source)
    RakeReportHelper.write("mendeley_stats.csv", report.to_csv)
  end

  desc 'Generate CSV file with PMC HTML usage stats over time'
  task :pmc_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("pmc_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with PMC PDF usage stats over time'
  task :pmc_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("pmc_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with PMC combined usage stats over time'
  task :pmc_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("pmc_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with PMC cumulative usage stats'
  task :pmc_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    report = PmcReport.new(source)
    RakeReportHelper.write("pmc_stats.csv", report.to_csv)
  end

  desc 'Generate CSV file with Counter HTML usage stats over time'
  task :counter_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("counter_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with Counter PDF usage stats over time'
  task :counter_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("counter_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with Counter XML usage stats over time'
  task :counter_xml_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "xml"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("counter_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with Counter combined usage stats over time'
  task :counter_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    RakeReportHelper.write("counter_#{format}.csv", report.to_csv)
  end

  desc 'Generate CSV file with cumulative Counter usage stats'
  task :counter_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    report = CounterReport.new(source)
    date = Time.zone.now - 1.year
    RakeReportHelper.write("counter_stats.csv", report.to_csv)
  end

  desc 'Generate CSV file with combined ALM stats'
  task :combined_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed.without_private),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    RakeReportHelper.write("alm_report.csv", report.to_csv)
  end

  desc 'Generate CSV file with combined ALM private and public stats'
  task :combined_private_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    RakeReportHelper.write("alm_private_report.csv", report.to_csv)
  end

  desc 'Zip reports'
  task :zip => :environment do
    folderpath = "#{Rails.root}/data/report_#{Time.zone.now.to_date}"
    if !Dir.exist? folderpath
      puts "No reports to compress."
    elsif Report.zip_file && Report.zip_folder
      puts "Reports have been compressed."
    else
      puts "Reports could not be compressed."
    end
  end

  desc 'Generate all article stats reports'
  task :all_stats => [:environment, :alm_stats, :mendeley_stats, :pmc_html_stats, :pmc_pdf_stats, :pmc_combined_stats, :pmc_stats, :counter_html_stats, :counter_pdf_stats, :counter_xml_stats, :counter_combined_stats, :counter_stats, :combined_stats, :alm_private_stats, :combined_private_stats, :zip]
end
