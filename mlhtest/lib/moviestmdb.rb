require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'
require 'themoviedb'
#require 'tmdb_party'
require 'byebug'
class Movies
	attr_accessor :key
	def initialize(key)
		@key = key
		@base_url = "https://api.themoviedb.org/3/"
	end	
=begin   #============> find by movie title ===========
	def get_themoviedb(param)
		puts param.class
		key = '85f46422f0a81eaf88cddf44c041b5d3'
		Tmdb::Api.key(key)		
		movie_title = param
		movie = Array.new
		movie = Tmdb::Movie.find("#{movie_title}")
#		detail = Tmdb::Movie.detail(movie[0].id,append_to_response: "credits")
		detail = Tmdb::Movie.detail(movie[0].id)
		puts detail		
		(0..movie.size-1).each { |m| puts "#{movie[m].id + ': ' +movie[m].title + ' => ' + movie[m].release_date}" }
		puts '-' * 20
		#puts detail
		puts '-' * 20
		puts detail['lists'].class
		detail['lists']['results'].each { |lk,lv| puts lk }
	end
=end    #================= end working ===============	
#begin
	def get_tmdb(url)
		http = Net::HTTP.new(url.host, url.port)
#		response = http.request(Net::HTTP::Get.new(url.request_uri))
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		#body = Hash.new["0"]
		response = Net::HTTP.get_response(url)
		#response = Net::HTTP::Get.new(url)
		JSON.parse(response.body)	
	end
#end
#begin
	def search_tmdb(parm)
		puts parm.inspect
		puts parm.size
		puts parm[parm.size-1].class
		key = '?api_key=' + @key.to_s	#85f46422f0a81eaf88cddf44c041b5d3'
		if parm[1].class == String and parm.size == 2
			url = "#{@base_url + 'search/' + parm[0] + key + '&query=' + parm[1]}"
		elsif parm[0] == 'movie'
			url = "#{@base_url + parm[0] + '/' + parm[1].to_s + key + '&append_to_response=credits'}" 
		elsif parm[0] == 'person'	
			url = "#{@base_url + parm[0] + '/' + parm[1].to_s + '/movie_credits' + key}"
		else
			url = "#{@base_url + parm + key}"
		end
=begin
		elsif parm == 'collection'
			url = "#{@base_url + 'search/' + parm + key}"
		else
			url = "#{@base_url + parm + '/' + key}"
		end
=end		
		puts url 
#		url = URI("https://api.themoviedb.org/3/search/movie?api_key=85f46422f0a81eaf88cddf44c041b5d3&query=king henry")
#		url = URI("https://api.themoviedb.org/3/movie/343824?api_key=85f46422f0a81eaf88cddf44c041b5d3&append_to_response=credits")
#		url = URI("https://api.themoviedb.org/3/list/33517?api_key=85f46422f0a81eaf88cddf44c041b5d3&language=en-US")
		get_tmdb(URI(url))
	end
#end
#begin
	def get_movies(movie)
		items = Array['genres','title','overview','release_date']
		results = search_tmdb(['movie',movie])
		(0..results['results'].size-1).each { |movie|
#		(results['results'].size-1..results['results'].size-1).each { |movie|
			get_movie(results['results'][movie]['id'])
		}
	end
#end
#begin
	def get_movie(id)
#		search = "#{'movie',id}"	# + '/append_to_response=credits'}"
#		results = m.search_tmdb("#{search}")
		results = search_tmdb(['movie',id])
		puts "#{results['release_date'] + ' ' + results['title']}"
		genres = ''
		(0..results['genres'].size-1).each { |g| genres << results['genres'][g]['name'] << ', ' }
		puts genres[0,genres.size-2]
		puts results['overview']
		puts '-'*20
		get_credits(results['credits'])
	end
#end
#begin
	def get_person(person)
#		m.search_tmdb(['person','marlon brando'])
		results = search_tmdb(['person',person])
		id = results['results'][0]['id']
#		search = "#{'person/' + id.to_s + '/movie_credits'}"
		get_credits(search_tmdb(['person',id]))		
	end
#end
#begin
	def get_credits(results)
		driver = Array['cast','crew']
		driver.each { |d|
			(0..results[d].size-1).each do |film|
				results[d][film].each { |k,v| 
				puts "#{k + ' => ' + v.to_s}" 
				}
				puts '-'*20
			end
		}		
	end
#end
#begin
	def get_genres(media)
		results = search_tmdb('genre/' + media +'/list')
		genres = Hash.new
		(0..results['genres'].size-1).each { |g|
			id = results['genres'][g]['id'] 
			name = results['genres'][g]['name']
			genres[id] = name
		}
		
		puts genres
		puts genres[28]
	end
	
#end
end #=====> class end  <==========

	m = Movies.new('85f46422f0a81eaf88cddf44c041b5d3')
#	m.get_person('marlon brando')
	m.get_movies('king henry')
#	m.get_genres('movie')

=begin	
	puts response.size		
	case parm[0]
	when 'movie'
		items = Array['release_date','id','title']
		(0..response['results'].size-1).each do |r|
			record = response['results'][r]
			fields = Hash.new
			(0..items.size-1).each { |item| 
				field = items[item]
				fields << record[field].to_s + ' '
			}
			puts fields
#				puts "#{record['release_date'] + ' ' + record['id'].to_s.ljust(6,padstr=' ') + ' ' + record['title']}"
			puts record['overview']
			puts '-'*20
		end
	end
=end	

=begin
		key = '85f46422f0a81eaf88cddf44c041b5d3'
		Tmdb::Api.key(key)
		@search = Tmdb::Search.new
		@search.resource('person') # determines type of resource
		@search.query('samuel jackson') # the query to search against
		@search.fetch # makes request	
		puts @search.all
#		body = get_movie('Storytelling')

		(1928..2016). each do |y|
			body['items'].each { |i| 
				if i['release_date'][0,4] == "#{y}" 
					puts "#{ i['release_date'] + ' => ' + i['title']}"
				end
			}
=end			

=begin
	key = '85f46422f0a81eaf88cddf44c041b5d3'
	Tmdb::Api.key(key)
	@search = Tmdb::Search.new
	@search.resource('person') # determines type of resource
	@search.query('tom cruise') # the query to search against
	response = @search.fetch # makes request
	puts response[0]['known_for'].size  #['known_for'].size
	(0..response[0]['known_for'].size-1).each do |kf|
		puts response[0]['known_for'][kf]
		puts '-'*20
	end
=end


=begin
detail.each { |k,v| 
	puts k
	if k == 'lists'
		v.each { |lk,lv| puts lk }
	end
}
=end

#detail = Tmdb::Movie.detail(id)
#puts detail

=begin
puts detail.size
puts detail.length
#detail.each do |k, v| 
#	puts k,  ' => '  v
=end

=begin
detail.each do |k, v|
	puts k + ":  " + v.to_s
end
puts themoviedb.movie.adult
=end

=begin
puts movie.length
puts movie.detail(
puts movie[0]

#url = URI("https://api.themoviedb.org/3/search/movie&query=Spirited%20Away?api_key=85f46422f0a81eaf88cddf44c041b5d3")
#url = URI("https://api.themoviedb.org/3/movie/The%20Decalogue?api_key=85f46422f0a81eaf88cddf44c041b5d3")
url = URI("https://api.themoviedb.org/3/movie/343824?api_key=85f46422f0a81eaf88cddf44c041b5d3")
=end

=begin
puts body["credits"].class
#puts body[body.size-1]
body["credits"]["crew"].each { |k,v| 
	if k["job"] == "Director"
		puts k['name']
	end
}
=end
#response.credits.crew.each { |c| puts c }
#request.body = "{}"
#puts body.each { |k, v| puts k,  "==>", v}
#response = http.request(Net::HTTP::Get.new(url.request_uri))
#response = http.request(request)
#puts response.body
#movies = response.read_body
#puts movies{"adult"}	#{"page"}	#.each { |elm| puts elm }
#puts response.read_body{"adult"}	#.each { |elm| puts elm }
#response.each_header { |h| puts h response[h] }
#end