require "rubygems"
require "bundler"

Bundler.require(:default)

# Do a get request, with the options of specifying additional
# headers, from a file
class GetAPITester
  include HTTParty

  def initialize(site,file)
    @site, @file = site, file
    @contents = File.readlines(@file)
    #self.class.get(site,:headers )

    @header_hash = @contents.inject(Hash.new) do |h,e|
      line_contents = e.split(/\:/).map(&:strip)
      if line_contents.size == 2
        h[line_contents.first] = line_contents.last
      end
      h
    end

  end

  def request
    response = self.class.get(@site,:headers => @header_hash)
    build_response_data(response)
  end

  def build_response_data(response)
    headers = Hash[*(response.headers.to_a).flatten]
    headers_as_string = headers.inject("") {|h,e| h + "#{e[0]}:#{e[1]}" }
    <<-EOLN
    Success: #{response.success?}
    Error code: #{response.response.code}
    HEADERS:
    #{headers_as_string}
    ---------------------
    Response body:\n #{response.body}
    EOLN
  end
end

puts GetAPITester.new(ARGV[0], ARGV[1]).request
