require 'rubygems'
require 'sinatra'
require 'haml'
require 'mechanize'

set :server, 'thin'

get '/' do
  url = 'http://www.confinvest.it/dbase/quotazioni.php'
  scraper = Mechanize.new
  result = {}
  scraper.get(url) do |page|
    table = page.search('table[border="0"][cellpadding="0"][cellspacing="0"][width="550"][align="center"]')
    labels = table.search('.unnamed1')[2..-3].map{|e| e.text}
    values = table.search('.soldi').map{|e| e.text.strip}.reject{|e| e == ""}

    result[:tendenza] = values.pop
    result[:indice_mom] = values.pop

    result[:monete] = []

    index = 0
    values.each_slice(2) do |slice|
      result[:monete] << {
        nome: labels[index],
        valori: slice
      }
      index += 1
    end
  end

  {status: result}.to_json
end
