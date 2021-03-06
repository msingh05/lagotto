require 'csv'
require 'date'

namespace :report do

  desc 'Generate CSV file with ALM stats for public sources'
  task :alm_stats => :environment do
    report = AlmStatsReport.new(Source.installed.without_private)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with ALM stats for private and public sources'
  task :alm_private_stats => :environment do
    report = AlmStatsReport.new(Source.installed)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_STATS_PRIVATE_CSV_FILENAME
  end

  desc 'Generate CSV file with Mendeley stats'
  task :mendeley_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "mendeley").first
    next if source.nil?

    report = MendeleyReport.new(source)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::MENDELEY_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC HTML usage stats over time'
  task :pmc_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_HTML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC PDF usage stats over time'
  task :pmc_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_PDF_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC combined usage stats over time'
  task :pmc_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = PmcByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_COMBINED_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with PMC cumulative usage stats'
  task :pmc_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "pmc").first
    next if source.nil?

    report = PmcReport.new(source)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::PMC_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter HTML usage stats over time'
  task :counter_html_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "html"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_HTML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter PDF usage stats over time'
  task :counter_pdf_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "pdf"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_PDF_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter XML usage stats over time'
  task :counter_xml_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "xml"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_XML_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with Counter combined usage stats over time'
  task :counter_combined_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    format = "combined"
    date = Time.zone.now - 1.year
    report = CounterByMonthReport.new(source, format: format, month: date.month.to_s, year: date.year.to_s)
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_COMBINED_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with cumulative Counter usage stats'
  task :counter_stats => :environment do
    # check that source is installed
    source = Source.visible.where(name: "counter").first
    next if source.nil?

    report = CounterReport.new(source)
    date = Time.zone.now - 1.year
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::COUNTER_STATS_CSV_FILENAME
  end

  desc 'Generate CSV file with combined ALM stats'
  task :combined_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed.without_private),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_COMBINED_STATS_FILENAME + "_#{Time.zone.now.to_date}.csv"
  end

  desc 'Generate CSV file with combined ALM private and public stats'
  task :combined_private_stats => :environment do
    report = AlmCombinedStatsReport.new(
      alm_report:      AlmStatsReport.new(Source.installed),
      pmc_report:      PmcReport.new(Source.visible.where(name: "pmc").first),
      counter_report:  CounterReport.new(Source.visible.where(name:"counter").first),
      mendeley_report: MendeleyReport.new(Source.visible.where(name:"mendeley").first)
    )
    ReportWriter.write report, contents: report.to_csv, filename: ReportWriter::ALM_COMBINED_STATS_PRIVATE_CSV_FILENAME
  end

  desc 'Zip reports'
  task :zip => :environment do
    LagottoZipUtility.zip_alm_combined_stats!
    LagottoZipUtility.zip_administrative_reports!
    puts "Reports have been compressed!"
  end

  desc 'Export ALM combined stats report to Zenodo'
  task :export_to_zenodo => [:environment, 'zenodo:requirements_check'] do
    alm_combined_stats_zip_record = FileWriteLog.most_recent_with_name(LagottoZipUtility.alm_combined_stats_zip_filename)

    unless alm_combined_stats_zip_record
      puts  "No zip file (#{File.basename LagottoZipUtility.alm_combined_stats_zip_filename}) found that needs to be exported!"
      next
    end

    publication_date = alm_combined_stats_zip_record.created_at.to_date
    sitenamelong = ENV['SITENAMELONG']
    title = "Cumulative #{sitenamelong} Report - #{publication_date.to_s(:month_and_year)}"
    description = <<-EOS.gsub(/^\s*/, '').gsub(/\s*\n\s*/, " ")
      Article-Level Metrics (ALM) measure the reach and online engagement of scholarly works.
      This #{sitenamelong} report contains the cumulative stats collected for all works through
      #{publication_date.to_s(:long)}. Data are generated by the Lagotto open source software.
      Go to the Lagotto forum for questions or comments.
    EOS

    data_export = ZenodoDataExport.create!(
      name: "alm_combined_stats_report",
      files: [alm_combined_stats_zip_record.filepath],
      publication_date: publication_date,
      title: title,
      description: description,
      creators: [ ENV['CREATOR'] ],
      keywords: ZENODO_KEYWORDS,
      code_repository_url: ENV["GITHUB_URL"]
    )

    DataExportJob.perform_later(id: data_export.id)
  end

  desc 'Generate all article stats reports'
  task :all_stats => [:environment, :alm_stats, :mendeley_stats, :pmc_html_stats, :pmc_pdf_stats, :pmc_combined_stats, :pmc_stats, :counter_html_stats, :counter_pdf_stats, :counter_xml_stats, :counter_combined_stats, :counter_stats, :combined_stats, :alm_private_stats, :combined_private_stats, :zip, :export_to_zenodo]
end
