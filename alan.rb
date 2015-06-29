module DocumentAutomator
  extend self

  @@root = Dir.pwd
  @@verification_dir = ENV['VERIFICATION_DOCUMENT_PATH']

  def create_cover_page(id, config_file)
    Dir.chdir "#{@@verification_dir}/#{id}"
    params = YAML.load_file(config_file)
    pdftk = PdfForms.new('/usr/local/bin/pdftk')
    pdftk.fill_form "#{@@root}/cover_base.pdf", 'cover.pdf',
      :name => params['name'],
      :dob => params['dob'],
      :ssn => "*** ** #{params['ssn']}",
      :address => params['address'],
      :phone => params['phone']
  end

  def combine_directory_into_single_pdf(dir)
    Dir.chdir dir
    
    # Delete combined.pdf
    File.delete('combined_verifications.pdf') if File.exist?('combined_verifications.pdf')

    # Get array of files
    file_array = []
    Dir.glob("*.{png,jpeg,pdf,tiff,tif}") do |f|
      file_array << File.open(f) unless f == "cover.pdf"
    end
    
    # Stamp pages with footer/PII
    # To do

    # Add cover page
    file_array.unshift(File.open("cover.pdf")) if File.exist?("cover.pdf")

    # Combine the files
    file_array = file_array.map do |file|
      magick_object = MiniMagick::Image.open(file.path)
      if magick_object.type == 'PDF'
        file
      elsif ['JPG', 'JPEG', 'PNG', 'GIF'].include?(magick_object.type)
        pdf_path = "/tmp/#{random_string_for_temp_files}.pdf"
        prawn_pdf_doc = Prawn::Document.new
        prawn_pdf_doc.image(magick_object.path, fit: [500, 500])
        prawn_pdf_doc.render_file(pdf_path)
        pdf_doc = File.open(pdf_path)
        pdf_doc
      else
        nil
      end
    end.reject { |element| element == nil }

    # Write to combined_verifications.pdf
    pdf_paths = file_array.map { |file| file.path }
    system("pdftk #{pdf_paths.join(' ')} cat output combined_verifications.pdf")
  end

  def add_footer(combined_file)
  end

  def random_string_for_temp_files
    SecureRandom.hex + Time.now.strftime('%Y%m%d%H%M%S%L')
  end
end