#ed's scraper to make .pdf books out of scanned manuscripts

require 'open-uri'
require 'rubygems'
require 'pdf/writer'

# VARIABLES PER PDF BUILD
@endpageurl = 'http://images.library.wisc.edu/DLDecArts/EFacs/CityCtryLang/M/lang0432.jpg'
@booktitle = 'Asher'
@size = 'XL'

# SHOULD NOT NEED TO EDIT BELOW THIS LINE
@docnameroot = ''
@pages = ''
@countstring = ''

# take apart the file name for its component information
ary1 = @endpageurl.split('/')

# take the last element of the URL (the file name) and break it into the name and the extension
ary2 = ary1[-1].split('.')

#set the imagetype (to be used to pick them out of a directory later) to the last element of the filename array from above
@imagetype = ary2[-1]


# break the first element of ary2 (the filename) into any naming companent and the subsequent page number / count string
ary3 = ary2[0].split(//) 
ary3.each do |s|
  if s.match(/[a-z]/)
    @docnameroot.concat(s)
  elsif s.match(/[0-9]/)
    @countstring.concat(s)
  end
    @countdepth = @countstring.length
    @maxpages = @countstring.to_i
end

# lines below are debug output
pust @endpageurl.split('*.jpg')
puts @docnameroot
puts @maxpages
puts @countstring
puts @countdepth

# comment the following line when you want to run the whole thing
@maxpages = 1

# build back up the documents web root (there must be a better way to just get the URL root and filename via Mechanize?)
len = ary1.length
shortlen =  len - 3
# puts ary1[0..shortlen].join
ary4 = ary1[0..shortlen].map {|s| "#{s}/"}
@baseurl = ary4.join

@counter = 0

@maxpages.to_i.times do
    @counter += 1
    
    # here we build the name of the file to go get
    scrapepage = "#{@docnameroot}#{@countstring}.jpg"
    
    # here we fill up that output file with the content from the web
    begin
        file = File.new(scrapepage,'w')
        file.puts open("#{@baseurl}#{@size}/#{@docnameroot}#{@countstring}.#{@imagetype}", 'User-Agent' => 'Ruby-Wget').read
        rescue OpenURI::HTTPError
          # It couldn't be accessed, so do something.
        file.close 
    end
end

# put the images into a PDF
pdf = PDF::Writer.new

Dir['*.jpg'].each do |file|
 pdf.image file 
end

File.open("#{@booktitle}.pdf", "wb") { |f| f.write pdf.render }