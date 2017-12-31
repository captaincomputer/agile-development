require 'rubygems'
require 'nokogiri'
require 'open-uri'
#require 'Date'
require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
#puts OpenSSL::OPENSSL_VERSION
#puts "SSL_CERT_FILE: %s" % OpenSSL::X509::DEFAULT_CERT_FILE
#puts "SSL_CERT_DIR: %s" % OpenSSL::X509::DEFAULT_CERT_DIR
class AcademyAwards

  def get_movies(table)
    (2..table.size-7).each do |i|
      puts '-' * 20
      puts table[i].css('a')[0].text  #year
      puts '-' * 20
      table[i].css('td i a').each { |row| puts row.text } #movie
    end    
  end
  
  def get_actors(table)
    movie = ''
    rows = table.css('tr')
    (1..rows.size-1).each do |i|    
      yyyy = rows[i].css('th').css('a')
      if yyyy.size != 0
        year = yyyy[0].text #unless yyyy.size == 0
        puts '-' * 20
        puts year
        puts '-' * 20
      end
      as = rows[i].css('a')
      break if as.size == 0
      actor = as[0+yyyy.size].text
      as = rows[i].css('i a')
      movie = '' unless as.size == 0
      (0..as.size-1).each { |a| movie += "#{' / ' + as[a].text.to_s}" }
      puts "#{actor + ' ' + movie.to_s}"
    end    
  end  

  def get_Nokogiri(url)
		base_url="https://en.wikipedia.org/wiki/Academy_Award_for_Best_"		
    puts base_url+url    
		Nokogiri::HTML(open(base_url+url))
	end
end  
m = AcademyAwards.new
best = ["Picture","Actor", "Actress", "Supporting_Actor", "Supporting_Actress", "Director"]
best = ["Picture"]

(0..best.size-1).each do |cat|
  page = m.get_Nokogiri(best[cat])
  table = page.css('table')
  case best[cat]
  when "Picture" 
    m.get_movies(table)
  else 
    (2..table.size-9).each { |t| m.get_actors(table[t]) }
  end
end