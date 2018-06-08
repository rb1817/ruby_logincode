require 'sinatra'
require 'sinatra/reloader'
require 'uri'
require 'nokogiri'
require 'rest-client'

get '/' do
   erb :app 
end

get '/calculate' do
    num1 = params[:n1].to_i
    num2 = params[:n2].to_i
    @sum = num1 + num2
    @min = num1 - num2
    @mul = num1 * num2
    @div = num1 / num2
    
    erb :calculate
    
end

get '/numbers' do
    erb :numbers
end

get '/form' do
    erb :form
end

get '/url/wild' do
    erb :wild
end


id = "multi"
pw = "campus"



post '/login' do
    if id.eql?(params[:id])
      #비밀번호를 체크 로직
      if pw.eql?(params[:password])
          redirect '/complete'
      else
         @msg ="비밀번호가 존재하지 않습니다."
          redirect '/error?err_co=1'
      end
    else
      #ID가 존재하지 않습니다.
      @msg ="아이디가 존재하지 않습니다."
      redirect '/error?err_co=2' #redirect 새로운 요청
    end
end

#로그인 실패
get'/error' do
    if params[:err_co].to_i == 1
         @msg ="비밀번호가 존재하지 않습니다."
    elsif params[:err_co].to_i == 2
         @msg ="아이디가 존재하지 않습니다."
    end
    erb :error
end

#로그인 완료
get '/complete' do
    erb :complete
end

get '/search' do
    erb :search
end

post '/search' do
    case params[:engine]
    when "naver"
        url = URI.encode("https://search.naver.com/search.naver?query=#{params[:query]}")
        redirect url
    when "google"
         url = URI.encode("https://www.google.com/search?q=#{params[:q]}")
        redirect url
    end
end


get '/op_gg' do

    if params[:userName]
        case params[:search_method]
        # op.gg에서 승/패 수만 크롤링하여 보여줌
        when "self"
        # RestClient를 이용하여 op.gg에서 검색결과 페이지를 크롤링
        url = RestClient.get(URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}"))
        # 검색결과 페이지 중에서 win과 lose 부분을 찾음
        result = Nokogiri::HTML.parse(url)
        # nokogiri를 이용하여 원하는 부분을 골라냄
        #css는 태그라던가 클래스라던가를 찾아나감. copy_selector로 찾을 수 있음
        #win = result.css('#GameAverageStatsBox-matches > div.Box > table > tbody > tr:nth-child(1) > td:nth-child(1) > div > span.win').first
        #lose = result.css('#GameAverageStatsBox-matches > div.Box > table > tbody > tr:nth-child(1) > td:nth-child(1) > div > span.lose').first        
        win = result.css('span.win').first
        lose = result.css('span.lose').first
        # 검색 결과를 페이지에서 보여주기 위한 변수 선언
       @win = win.text
       @lose = lose.text
        # html 태그 제거
        # 검색 결과를 op.gg에서 보여줌
        
        when "opgg"
            url = URI.encode("http://www.op.gg/summoner/userName=#{params[:userName]}")
            redirect url
        end
    end
    erb :op_gg
end