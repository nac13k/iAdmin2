require 'winnow'
require 'consistent_hash'
require 'unicode'

class Winnower
	attr_reader :averages,:files
	def initialize(guarantee,noise,path)
	    @guarantee = guarantee || 15
	    @noise = noise || 9
	    @fingerprinter = Winnow::Fingerprinter.new(guarantee_threshold: guarantee,noise_threshold: noise)
	    @fingerprints = {}
	    @matches = {}
	    @averages = {}
		@path = path
		@filenames = []
		@files = {}
		@contexts = {}
	end
	def seek_matches(keys)
		match_key = "#{keys[0]}-#{keys[1]}"

	    @matches[match_key] = Winnow::Matcher.find_matches(@fingerprints[keys[0]],
	    												   @fingerprints[keys[1]])
	end
	def calculate_fingerprints
		@files.each do |key,file|
			@fingerprints[key] = @fingerprinter.fingerprints(file, source: key)
		end
	end
	def take_files
		@filenames.each do |filename|
      file = PDF::Reader.new(filename)
			text = ""
      file.pages.each do |p|
        text += p.text
      end
			matricula = File.basename(filename,'.*')
			@files[matricula] = Unicode::downcase(text)
		end
	end
	def start_matching
		@fingerprints.keys.combination(2) do |keys|
			seek_matches(keys)
		end
	end
	def check_matches
		@matches.each do |key,matches|
			 k1,k2 = key.split("-")
			 @contexts[key] = get_match_context(k1,k2,matches)
			 @averages[key] = ((matches.size*100)/@fingerprints[k1].count)
		end
	end
	def get_match_context(k1,k2,matches)
		list = []
	    matches.each do |match|
			context_a = context_for(@files[k1],
									match.matches_from_a.first,
									15)
			context_b = context_for(@files[k2],
									match.matches_from_b.first,
									15)
			list << [context_a, context_b]
	    end
	    return list
	end
	def context_for(file,match,size)
	    first = match.index - size
	    last = match.index + size
	    return file[first .. last]
	end
	def get_dirs
		@filenames = Dir.glob("#{@path}/*/*")
	end
	def execute
		get_dirs
		take_files
		calculate_fingerprints
		start_matching
		check_matches
	end
	def get_results
		puts "\n\n RESULTADOS"
		@contexts.each do |key,ctx|
			k1,k2 = key.split("-")
			ctx.each do |c|
				puts "Esta parte del archivo #{k1} tiene coincidencias: \n\t#{c[0].inspect}"
				puts "Con esta parte del archivo #{k2} \n\t#{c[1].inspect}"
			end
		end
		@averages.sort_by(&:last).each do |key,average|
			puts "Porcentaje de coincidencias entre #{key} con #{average}%"
		end
	end
end
