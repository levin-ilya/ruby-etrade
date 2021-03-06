require 'rubygems'
require 'oauth'
require "rexml/document"

require 'access_token'
require 'consumer_token'

class Stock
  attr_accessor :ticker
  attr_accessor :price
  attr_accessor :ly_dividend

  def initialize(t,p,l)
    @ticker = t
    @price = p
    @ly_dividend = l
  end
  def to_s
    return "STOCK " + ticker + " Price: " + price.to_s + " Annual Dividend: " + ly_dividend.to_s
  end
  def Stock.find_by_ticker(t)
    consumer = OAuth::Consumer.new(CONSUMER_TOKEN[:token],CONSUMER_TOKEN[:secret],{:site => "https://etws.etrade.com", :http_method => :get})
    access_token = OAuth::Token.new(ACCESS_TOKEN[:token],ACCESS_TOKEN[:secret])
		response = consumer.request(:get, "/market/rest/quote/#{t}", access_token, {:detailFlag => "INTRADAY"})
		sleep 0.25
		doc = REXML::Document.new response.body
		price = doc.elements["QuoteResponse/QuoteData/all/lastTrade"].text.to_f
    response = consumer.request(:get, "/market/rest/quote/#{t}", access_token, {:detailFlag => "WEEK_52"})
    sleep 0.25
    doc = REXML::Document.new response.body
    puts doc
    ly_dividend = doc.elements["QuoteResponse/QuoteData/all/annualDividend"].text.to_f

    return Stock.new(t,price,ly_dividend)
  end
  def option_expire_dates
    return OptionExpireDate.find_all_by_ticker(ticker)
  end
end
