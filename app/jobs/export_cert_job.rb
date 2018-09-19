class ExportCertJob < ApplicationJob
  queue_as :default

  def perform(*args)

    current_user = args[0]
    entry_ids = args[1]

    @logbook_entries = LogbookEntry.find(entry_ids)

    # filename = "#{Rails.root}/public/feedbacks/feedback_for_#{current_user.id}_#{Time.now.strftime('%Y%m%d')}.pdf"

    # => PRAWN METHOD:
    # pdf = Prawn::Document.new(margin: [72, 72, 72, 72])
    # eval(Availability.get_pdf_markup(@logbook_entries, current_user))
    # pdf.render_file(filename)

    # => PDFKIT METHOD:
    @certificate = current_user.certificates.create!
    @certificate.logbook_entries = @logbook_entries

    # filename = "#{Rails.root}/public/certificates/certificate_#{@certificate.id}.pdf"
    tmp_filename = "#{Rails.root}/tmp/certificate_#{@certificate.id}.pdf"
    filename = "s3://oslr-uploads-production/uploads/certificates/certificate_#{@certificate.id}.pdf"
    @certificate.update_attribute(:filename, filename)

    # root_url = Rails.env == "production" ? "http://mercuryapp.co.uk" : "http://localhost:3000"
    # root_url = "http://127.0.0.1"
    # url = root_url + pdf_certificate_path(@certificate)
    # puts "URL: #{url}"
    # html = Nokogiri::HTML(open(url))

    html = ApplicationController.new.render_to_string(
      :template => "certificates/pdf",
      :layout => false,
      :locals => {
        :@logbook_entries => @logbook_entries,
        :@certificate => @certificate,
        :current_user => current_user
      }
    )

    kit = PDFKit.new(html, page_size: 'A4')
    kit.stylesheets << Rails.root.join("public", "bootstrap", "bootstrap.min.css")
    kit.stylesheets << Rails.root.join("public", "bootstrap", "bootstrap-theme.min.css")

    puts "PDFKit loaded - to save to #{tmp_filename} then transfer to #{filename}"
    # kit.stylesheets << '/path/to/css/file'
    pdf = kit.to_pdf
    puts "PDF loaded"
    file = kit.to_file(tmp_filename)
    puts "PDFKit saved to file (#{filename})"

    # Upload to S3
    connection = Fog::Storage.new(AWS_CREDENTIALS) # Should get AWS credentials from carrierwave initializer
    directory = connection.directories.get("oslr-uploads-#{Rails.env == 'production' ? 'production' : 'development'}")
    file = directory.files.create(
      :key    => "uploads/certificates/certificate_#{@certificate.id}.pdf",
      :body   => File.open(tmp_filename),
      :public => true
    )

    UserMailer.send_feedback(current_user, tmp_filename).deliver_now
  end
end
