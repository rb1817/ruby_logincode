## Day 3

### 새로운 폴더에 sinatra 프로젝트 넣기

* app.rb 파일 생성 후 views 폴더 생성
* sinatra 와 sinatra-reloader gem을 설치

*test_app/app.rb*

```ruby
require 'sinatra'
require 'sintra/reloader'

get '/' do
   erb :app 
end
```

#### 페이지간 이동

<a>- a->b

<form> -다음페이지로 넘겨야할 데이터가 있을 때



### GET POST 방식

- GET은 주소줄에 값이 ?뒤에 쌍으로 이어붙고 POST는 숨겨져서(body안에) 보내진다.
- 기본적으로 POST 요청에 대한 로직은 직접 뷰를 렌더링하는 것이 아니라 다른 페이지로 redirect 시킨다.

#### 로그인 하기(<form> 태그 이용)

```ruby
get '/form' do
	erb :form
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
endb :complete
end
```

``` erb
<form action = "/login" method = "POST">
 아이디 : <input type="text" name = "id">
 비밀번호 : <input type="password" name = "password">
 <input type="submit" value = "로그인">
</form>


<h1><%=@msg %></h1>
```



#### 검색창 만들기

```ruby
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
```

```erb
<p>----form action을 이용한 방법----</p>
<form action="https://search.naver.com/search.naver">
    <input type="text" name="query" placeholder="네이버 검색창">
    <input type="submit">
</form>

<form action="https://www.google.com/search">
    <input type="text" name="q" placeholder="구글 검색창">
    <input type="submit">
</form>

<p>----form method POST를 이용한 방법----</p>
<form method="POST">
    <input type="hidden" name="engine" value="naver">
    <input type="text" name="query" placeholder="네이버 검색">
    <input type="submit" value="검색">
</form>

<form method="POST">
    <input type="hidden" name="engine" value="google">
    <input type="text" name="q" placeholder="구글 검색">
    <input type="submit" value="검색">
</form>
```



#### fake op.gg 사이트 만들기

```ruby
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
        #win = result.css('#GameAverageStatsBox-matches > div.Box > table > tbody > tr:nth-		  child(1) > td:nth-child(1) > div > span.win').first
        #lose = result.css('#GameAverageStatsBox-matches > div.Box > table > tbody > 		   tr:nth-child(1) > td:nth-child(1) > div > span.lose').first        
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
```

``` erb
<form>
    <select name="search_method">
        <option value="self"> 승패만 보기 </option>
        <option value="opgg"> OP.GG에서 보기 </option>
    </select>
    <input type="text" placeholder="소환사 이름" name="userName">
    <input type="submit" value="검색">
</form>

<% if params[:userName] %> <!--눈에 보이지 않아도 되는건 =만 없애면 된다-->
<ul>
    <li><%= params[:userName] %>님의 전적입니다.</li>
    <li><%= @win %> 승</li>
    <li><%= @lose %> 패</li>
</ul>
<% end %>
```

