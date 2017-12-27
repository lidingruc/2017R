#######################################
#第一部分：网页抓取
#httr包类似于python的Requests
#rvest也是hadley创建整合了httr、xml2，能够同时使用XPath和selectr
#RCurl包是curl在R中的对应，基于C的基础包。很快！
#https://r-how.com/packages/httr

##########################
#示例1：httr抓取网页
#########################
setwd("/Users/liding/E/Bdata/liding17/2017R/l145spider")
library(httr)
library(xml2)
url<-"http://bj.xiaozhu.com/fangzi/5098280314.html"
html<-GET(url)
# 查看内容
headers(html)
str(html)
cookies(html)

#原始编码
doc<-content(html,"raw")
#文本
doc<-content(html,"text")
cat(doc,file="xiaozhu.html")

#content自带解析功能.采用xml2解析
doc<-content(html,"parsed")
#使用xml2中的函数提取
xml_find_all(doc,"//h4")


##########################
#示例2：Rcurl抓取网页
#########################
library(RCurl)
#注意，得到的是文本
html<-getURL(url)
#可以通过XML的 xmlTreeParse
#或者xml2的read_xml进行解析

#RCurl还可以进行登录，设置cookies等等
#见综合实例：人人网个人好友网络抓取代码

#######################################
#第二部分：网页解析和元素提取
#可用用XML提取，
#可以用xlm2提取
#都是基于‘libxml2’ C library
#可以用selectr提取

##########################
#示例3：使用xml2解析、提取网页
#########################
library(xml2)
doc <- read_html(html)
#实际上xml2包中的read_html可以直接读入网页
doc <- read_html(url)

xml_find_first(doc,"//h4")

xml_find_all(doc,"//h4")

xml_find_all(doc,"//h4")[1]

xml_find_all(doc,"//h4/em")

xml_text(xml_find_all(doc,"//h4/em"))

xml_find_all(doc,"//title")
xml_name(xml_find_all(doc,"//title"))
xml_text(xml_find_all(doc,"//title"))

xml_find_all(doc,"//head")

# 同时查找两个
xml_find_all(doc, c("//h6 | //h4"))
xml_find_all(doc, "//h6 | //h4")

xml_find_all(doc, "//a[@class='lorder_name']")[[1]]


##########################
#示例4：使用XML解析、提取网页
#########################
html<-getURL(url)
doc<-htmlParse(html, encoding = "utf-8")

nodi = getNodeSet(doc, path ="//h6")
nodi = getNodeSet(doc, path =c("//h6","//h4"))
nodi = getNodeSet(doc, path =c("//h6 | //h4"))
#头
getNodeSet(doc, "//head")
#全部节点
getNodeSet(doc, "//h6")
#节点中的第一个
getNodeSet(doc, "//h6")[[1]]

##提取内容
# 提取内容
xmlValue(nodi[[1]])
# 提取属性
xmlGetAttr(nodi[[2]],'class')
# 直接打印
xmlValue(getNodeSet(doc, "//title")[[1]])

#用apply函数提取内容
#取值
sapply(nodi, xmlValue) 
#属性
sapply(nodi, xmlAttrs) 
#父节点
sapply(nodi, xmlParent) 
#变成一个list
sapply(nodi, xmlToList) 

#内部的size
sapply(nodi, xmlSize) 

# 节点name
sapply(nodi, xmlName) 

#附录：关于htmlTreeParse和htmlParse的差异：
#http://stackoverflow.com/questions/20684507/in-r-xml-package-what-is-the-difference-between-xmlparse-and-xmltreeparse
doc<-htmlTreeParse(html, encoding = "utf-8")
xmlValue(doc$children[[1]])


##########################
#示例5：使用selectr提取网页
#########################

# 使用的是xml2的解析的结果
doc<-read_html(html, encoding = "utf-8")
library(selectr)
querySelector(doc,"h4")
querySelectorAll(doc,"h4,h6")

# 使用的是XML的解析的结果
doc<-htmlParse(html, encoding = "utf-8")
querySelectorAll(doc, c("h6","h4"))
querySelectorAll(doc, c("h6,h4"))

##########################
#示例6：使用rvest提取网页
#########################
#实际上是‘xml2’ 和 ‘httr’ 的组合
#可以用管道操作 %>%
#https://zhuanlan.zhihu.com/p/22940722?refer=rdatamining
library(rvest)
#使用的其实就是xml2中的read_html进行了读取和解析
doc <- read_html(url)
doc %>% html_nodes("h4") %>% html_text()


#等效的
html_nodes(doc,"h4,h6")
html_node(doc,"h4,h6")

xml_nodes(doc,"h4,h6")
xml_node(doc,"h4,h6")


# 使用CSS selector
#https://sjp.co.nz/projects/selectr/
library(selectr)
querySelectorAll(doc, "div.con_l > div.pho_info > h4")

xpath <- css_to_xpath("div.con_l > div.pho_info > h4")
xpath


##########################
#示例7：xml2，XML批量操作
#########################
#xml2的示例
#Here’s a small example working with an inline XML document:
#https://blog.rstudio.org/2015/04/21/xml2/
library(xml2)
x <- read_xml("<foo>
              <bar>text <baz id = 'a' /></bar>
              <bar>2</bar>
              <baz id = 'b' /> 
              </foo>")

xml_name(x)
#> [1] "foo"
xml_children(x)
#> {xml_nodeset (3)}
#> [1] <bar>text <baz id="a"/></bar>
#> [2] <bar>2</bar>
#> [3] <baz id="b"/>

# Find all baz nodes anywhere in the document
baz <- xml_find_all(x, ".//baz")
baz
#> {xml_nodeset (2)}
#> [1] <baz id="a"/>
#> [2] <baz id="b"/>
xml_path(baz)
#> [1] "/foo/bar[1]/baz" "/foo/baz"
xml_attr(baz, "id")
#> [1] "a" "b"

#########################
#示例8：XML 批量化提取多页信息，xpath
#与json方式
#########################
#http://stackoverflow.com/questions/24576962/how-write-code-to-web-crawling-and-scraping-in-r
library(XML)
library(httr)

# 单步分解
# 网页地址固定部分
url <- "http://www.wikiart.org/en/claude-monet/mode/all-paintings-by-alphabet/?page="

# 第二页，总共22页
i <- 2

# 设置一个空的list准备存网页链接
hrefs <- list()

# 获取索引页内容，打印出来查看实际获得的代码
response <- GET(paste0(url,i))
doc <- content(response,type="text")
cat(doc,file="monet.html")

# 解析网页、获取对应的链接
doc <- htmlParse(response)
doc["//ul[@class='title']/li[1]/a/@href"]

# 将新获得链接与已经获得的部分合并
hrefs    <- c(hrefs,doc["//ul[@class='title']/li[1]/a/@href"])

# 构建一个详情页的网址
url      <- "http://www.wikiart.org"
paste0(url,hrefs[1])

#获取一个详情页
response <- GET(paste0(url,hrefs[1]))
doc <- content(response,type="text")
cat(doc,file="monet1.html")

doc <- htmlParse(response)

# 打开获取代码，查找相关信息，可以看到

# 画名在 h1下面的span中

doc["//h1/span[@itemprop='name']"]
# 创作时间
doc["//span[@itemprop='dateCreated']"]
# 作者
doc["//div[@class='artwork-title']/a[@class='artist-name']"]
# 风格
doc["//div[@class='info-line'][2]/a/span"]
# 流派
doc["//span[@itemprop='genre']"]


###   正式命令，有22页，全部获取时间较长，建议只获取前2页。

url <- "http://www.wikiart.org/en/claude-monet/mode/all-paintings-by-alphabet/?page="
hrefs <- list()
for (i in 1:2) {
  response <- GET(paste0(url,i))
  # doc      <- content(response,type="text/html")
  doc <- htmlParse(response)
  hrefs    <- c(hrefs,doc["//ul[@class='title']/li[1]/a/@href"])
}

url      <- "http://www.wikiart.org"

# 定义xpath锚点集合
xPath    <- c(pictureName = "//h1/span[@itemprop='name']",
              date        = "//span[@itemprop='dateCreated']",
              author      = "//div[@class='artwork-title']/a[@class='artist-name']",
              style       = "//div[@class='info-line'][2]/a/span",
              genre       = "//span[@itemprop='genre']")

# 定义信息提取函数
get.picture <- function(href) {
  response <- GET(paste0(url,href))
  doc <- htmlParse(response)
  info     <- sapply(xPath,function(xp)ifelse(length(doc[xp])==0,NA,xmlValue(doc[xp][[1]])))
}


# 批量获取22页信息，获取时间较长。
pictures <- do.call(rbind,lapply(hrefs,get.picture))

head(pictures)
write.csv(pictures,file="monet.csv")


## 网页分析发现，这些信息也在头部信息中，我们可以想办法获取这些信息
#  <meta name="description" content="Apple Trees in Bloom, 1873 by Claude Monet. Impressionism. landscape" />


# 网页分析也可以发现，索引页在json中。我们可以在其中获得网页地址，详情页。

# https://www.wikiart.org/en/claude-monet/mode/all-paintings-by-alphabet?json=2&page=1

library(rjson)
help(library="rjson")

library(RCurl)

url <- "https://www.wikiart.org/en/claude-monet/mode/all-paintings-by-alphabet?json=2&page=1"
response <- getURL(url)
dat <- fromJSON(response)
hrefs <- list()
for (i in 1:20){
 hrefs <- c(hrefs, dat$Paintings[[i]]$paintingUrl[1])
}

# 再嵌套一个循环即可获得所有详情页链接

#########################
#示例9：XML 提取爬民政部社会组织信息，table
#########################
library(XML)
library(httr)

urlst <- "http://www.chinanpo.gov.cn/zznjresult.html?netTypeId=1&websitId=100&page_flag=true&goto_page="

urled<-"&current_page=32&total_count=31134&result=&registrationDeptCode=&times=&registrationNo=&managerDeptCode=&orgName=&type=&checkYear=&topid=&to_page=45"

hrefs <- list()

#http://www.chinanpo.gov.cn/zznjresult.html?netTypeId=1&websitId=100&page_flag=true&goto_page=145&current_page=32&total_count=31134&result=&registrationDeptCode=&times=&registrationNo=&managerDeptCode=&orgName=&type=&checkYear=&topid=&to_page=45

# 测试获得第一页的表格
html<-getURL(paste0(urlst,1,urled),.encoding='GB2312')
tables <- readHTMLTable(html,stringsAsFactors = FALSE)
data<- tables[[4]]


#最终命令
library(RCurl)
library(xml2)
data<-data.frame()
for(i in 1077:1557){
  html<-getURL(paste0(urlst,i,urled),.encoding='GB2312')
  tables <- readHTMLTable(html,stringsAsFactors = FALSE)
  data<- rbind(data,tables[[4]])
  Sys.sleep(1)
}
# 修改变量名
names(data) <- c('num','name','id','af','co','re')
data$num <- as.numeric(data$num)

write.table(data, "chinanpo.csv", row.names=TRUE, sep=",")


#########################
#示例10：XML 批量化提取多页table，编译GIS地址
#########################
#抓取美国大学名单列表
#https://collegestats.org/colleges/all/?pg=1
library(RCurl)
library(xml2)
library(XML)
urlst <- "https://collegestats.org/colleges/all/?pg="
data<-data.frame()
for(i in 1:300){
  html<-getURL(paste0(urlst,i),.encoding='utf-8')
  tables <- readHTMLTable(html,stringsAsFactors = FALSE)
  data<- rbind(data,tables[[1]])
  Sys.sleep(3)
}
# 修改变量名
#names(data) <- c('num','name','id','af','co','re')
#data$num <- as.numeric(data$num)
setwd('/Users/liding/E/Bdata/rtemp/data')
write.table(data, "usacolleges.csv", row.names=FALSE, sep=",")


library(readr)
ucdata <- read_csv("/Users/liding/E/Bdata/rtemp/data/usacolleges.csv")

#编译地址
library(ggmap)
sadd <- paste(data[1:24,2],data[1:24,3],data[1:24,4],sep =" ")

library(RCurl)
library(RJSONIO)

construct.geocode.url <- function(address, return.call = "json", sensor = "false") {
  root <- "http://maps.google.com/maps/api/geocode/"
  u <- paste(root, return.call, "?address=", address, "&sensor=", sensor, sep = "")
  return(URLencode(u))
}

gGeoCode <- function(address,verbose=FALSE) {
  require("plyr")
  if(verbose) cat(address,"\n")
  u <- aaply(address,1,construct.geocode.url)
  doc <- aaply(u,1,getURL)
  json <- alply(doc,1,fromJSON,simplify = FALSE)
  coord = laply(json,function(x) {
    if(x$status=="OK") {
      lat <- x$results[[1]]$geometry$location$lat
      lng <- x$results[[1]]$geometry$location$lng
      return(c(lat, lng))
    } else {
      return(c(NA,NA))
    }
  })
  if(length(address)>1) colnames(coord)=c("lat","lng")
  else names(coord)=c("lat","lng")
  return(data.frame(address,coord))
}
gGeoCode(c("Philadelphia, PA","New York, NY"))


geoadd <- gGeoCode(sadd)

#########################
#示例11：rvest提取抓取新浪调查页面，css Selector
#########################

#http://survey.news.sina.com.cn/list_all.php?dpc=1&state=going&page=2
library(plyr)
library(rvest)
library(stringr)
library("data.table")
library(dplyr)

urlst <- "http://survey.news.sina.com.cn/list_all.php?dpc=1&state=going&page="
Alldata<-data.frame()
for(i in 41:732){
  web<-read_html(paste0(urlst,i),encoding='gb2312')
  sbiaoti<-web%>%html_nodes("li.clearfix div.item-wrap a")%>%html_text()
  sdate<-web%>%html_nodes("li.clearfix  span.date")%>%html_text()
  ssort<-web%>%html_nodes("li.clearfix  span.sort")%>%html_text()
#链接
  link<-web%>%html_nodes("li.clearfix div.item-wrap a")%>%html_attrs()
  link1<-c(1:length(link))  #初始化一个和link长度相等的link1
  for(i in 1:length(link))
    link1[i]<-link[[i]][1]
 # link1  #查看link1
  
  data<-matrix(40,4)  # 定义一个40行，4列的矩阵
  data[,1]<-sbiaoti
  data[,2]<-ssort
  data[,3]<-sdate
  data[,4]<-link1
 #给列命名
  Alldata<- rbind(Alldata,data)
  Sys.sleep(1)
}
colnames(Alldata)<-c("biaoti","sort","sdate","link") 
head(Alldata)  #查看Alldata数据前6行
setwd('/Users/liding/E/Bdata/rtemp/data')
write.csv(Alldata,file="sinasurveylist.csv",quote=F,row.names = F)  #保存csv文件中

#########################
# 示例12：正则表达式抓取
#########################
# 邮件地址的表达式
# 从下面三个字符中抽取邮件地址
word <- c('abcnoboby@stat.berkeley.edu','text with no email','first me@mything.com alsoyou@yourspace.com')

pattern <-'[-A-Za-z0-9_.%]+@[-A-Za-z0-9_.%]+\\.[A-Za-z]+'

#标定位置
(gregout <- gregexpr(pattern,word))
# 抽取
substr(word[1],gregout[[1]],gregout[[1]]+attr(gregout[[1]],'match.length')-1)

#通常我们会定义一个抽取函数,更方便
getcontent <- function(s,g){
  substring(s,g,g+attr(g,'match.length')-1)
}
#使用函数
getcontent(word[1],gregout[[1]])

#########################
#下面要抓取豆瓣电影中250部最佳电影的资料：
library(httr)
library(xml2)
url<-'https://movie.douban.com/top250?format=text%27'
#readLines,注意先检验上面的网址是否与浏览器中完全一致
web <-readLines("doubao.txt",encoding="UTF-8")

#如果readLiness不能直接用，所以用了上面的命令
# 获取网页原代码，以行的形式存放在web变量中
html<-GET(url)
web<-content(html,"text")
setwd("/Users/liding/E/Bdata/liding17/2017R/l145spider")
writeLines(web,"doubao.txt")
web <-readLines("doubao.txt",encoding="UTF-8")

###批量获取250页数据
url<-'https://movie.douban.com/top250?format=text%27'
web <- readLines(url,encoding="UTF-8")
for(i in 0:9){
  url1<-paste('https://movie.douban.com/top250?start=',25*i,'&filter=',sep="")
  web1 <- readLines(url1,encoding="UTF-8")
  web<-c(web,web1)  
}

###


# 定义一个函数
getcontent <- function(s,g){
  substring(s,g,g+attr(g,'match.length')-2)
}

# 找到包含电影名称的行编号
name <- web[grep(' <div class="hd">',web)+2]

# 用正则表达式来提取电影名
gregout <- gregexpr('>\\W+<',name)

movie.names = 0
for(i in 1:length(gregout)){
  movie.names[i]<-getcontent(name[i],gregout[[i]])
}
movie.names <- sub('>','',movie.names)


# 找到包含电影发行年份的行编号并进行提取
year <- web[grep('<div class="star">',web)-4]
movie.year <- substr(year,29,32)

# 找到包含电影评分的行编号并进行提取
score <- web[grep('<span class="rating_num" property="v:average">',web)]
movie.score <- substr(score,79,81)

# 找到包含电影评价数量的行编号并进行提取
rating <- web[grep('<span class="rating_num" property="v:average">',web)+2]

library(stringr)
movie.rating <- substr(rating,32,str_length(rating)-10)
movie.rating <- sub('<span>','',movie.rating)

# 合成为数据框
movie <-data.frame(names=movie.names,year=as.numeric(movie.year),score=as.numeric(movie.score),rate=as.numeric(movie.rating))

# 绘散点图
library(ggplot2)

p <-ggplot(data=movie,aes(x=year,y=score))
p+geom_point(aes(size=rate),colour='lightskyblue4',
             position="jitter",alpha=0.8)+
  geom_point(aes(x=1997,y=8.9),colour='red',size=4)


#########################
# 示例12：phantomjs渲染后一步抓取表格
#########################

#自带请求器的解析包而且还是嵌入的pantomjs无头浏览器
# phantomjs渲染效果，直接抓取格式化网页 例子很好
# phantomjs 安装之后需要修改环境变量
# http://note.youdao.com/noteshare?id=25579f889483fca14ffb134775b96309

stopifnot(Sys.which("phantomjs") != "")

library(magrittr)
URL<-"https://www.aqistudy.cn/historydata/monthdata.php?city=北京"
library("rdom")
library(XML)
library(stringr)
tbl <- rdom(URL) %>% readHTMLTable(header=TRUE) %>% `[[`(1)
names(tbl) <- names(tbl) %>% stri_conv(from="utf-8")
DT::datatable(tbl)


library("rvest") 
URL<-"https://www.aqistudy.cn/historydata/monthdata.php?city=北京" 

URL%>% xml2::url_escape(reserved ="][!$&'()*+,;=:/?@#")

library(RCurl)
header<-c("User-Agent"="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36") 

mytable <- getURL(URL,httpheader=header,.encoding="UTF-8") %>% htmlParse(encoding ="UTF-8") %>% readHTMLTable(header=TRUE) $`NULL` 

#rvest

mytable <- URL %>%  read_html(encoding ="UTF-8") %>% html_table(header=TRUE) %>% `[[`(1) 


#########################
# 示例13：Rselenium+ phantomjs 抓取动态网页 
#########################

# 下载selenium，放到某个目录
#  已经安装了java的情况下才能运行
# http://selenium-release.storage.googleapis.com/index.html?path=3.8/

# 示例：https://ask.hellobi.com/blog/datamofang/10742
# 说明：https://cran.r-project.org/web/packages/RSelenium/vignettes/RSelenium-basics.html

system("java -jar \"/Users/liding/anaconda/selenium-server-standalone-3.8.1.jar\"")

library("RSelenium")
library("magrittr")
library("xml2")

#给plantomjs浏览器伪装UserAgent
eCap <- list(phantomjs.page.settings.userAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0")
###伪装浏览器UserAgent,为什么即使使用plantomjs这种浏览器也需要伪装UA呢，
###因为plantomjs是专门用于web端页面测试的，通常都是在自己的web项目中测试web端功能，直接拿去抓别人的网站，默认的UA就是plantomjs；
###这是公然的挑衅！

###连接phantomjs服务，简单使用
remDr <- remoteDriver(remoteServerAddr="localhost",
                      port=4444L,
                      browserName = "phantomjs", extraCapabilities = eCap)

remDr$open()

remDr$navigate("http://www.google.com/ncr")

remDr$navigate("http://www.bbc.co.uk")


#### 正式开始
remDr <- remoteDriver(browserName = "phantomjs", extraCapabilities = eCap)

#自动化抓取函数：
myresult<-function(remDr,url){
  ###初始化一个数据框，用作后期收据收集之用！
  myresult<-data.frame() 
  ###调用后台浏览器（因为是plantomjs这种无头浏览器（headless），所以你看不到弹出窗口）
  remDr$open()
  ###打开导航页面（也就是直达要抓取的目标网址）
  remDr$navigate(url) 
  ###初始化一个计时器（用于输出并查看任务进度）
  i = 0
  while(TRUE){
    #计时器开始计数：
    i = i+1
    #范回当前页面DOM
    pagecontent<-remDr$getPageSource()[[1]]
    #以下三个字段共用一部分祖先节点，所以临时建立了一个根节点（节省冗余代码）
    con_list_item       <- pagecontent %>% read_html() %>% xml_find_all('//ul[@class="item_con_list"]/li')
    #职位名称
    position.name       <- con_list_item %>% xml_attr("data-positionname") 
    #公司名称
    position.company    <- con_list_item %>% xml_attr("data-company") 
    #职位薪资
    position.salary     <- con_list_item %>% xml_attr("data-salary") 
    #职位详情链接
    position.link       <- pagecontent %>% read_html() %>% xml_find_all('//div[@class="p_top"]/a') %>% xml_attr("href")
    #职位经验要求
    position.exprience  <- pagecontent %>% read_html() %>% xml_find_all('//div[@class="p_bot"]/div[@class="li_b_l"]') %>% xml_text(trim=TRUE) 
    #职位所述行业
    position.industry   <- pagecontent %>% read_html() %>% xml_find_all('//div[@class="industry"]') %>% xml_text(trim=TRUE) %>% gsub("[[:space:]\\u00a0]+|\\n", "",.)
    #职位福利
    position.bonus      <- pagecontent %>% read_html() %>% xml_find_all('//div[@class="list_item_bot"]/div[@class="li_b_l"]') %>% xml_text(trim=TRUE) %>% gsub("[[:space:]\\u00a0]+|\\n", "/",.)
    #职位工作环境
    position.environment<- pagecontent %>% read_html() %>% xml_find_all('//div[@class="li_b_r"]') %>% xml_text(trim=TRUE) 
    #收集数据
    mydata<- data.frame(position.name,position.company,position.salary,position.link,position.exprience,position.industry,position.bonus,position.environment,stringsAsFactors = FALSE)
    #将本次收集的数据写入之前创建的数据框
    myresult<-rbind(myresult,mydata)
    #系统休眠0.5~1.5秒
    Sys.sleep(runif(1,0.5,1.5))
    #判断页面是否到尾部
    if ( pagecontent %>% read_html() %>% xml_find_all('//div[@class="page-number"]/span[1]') %>% xml_text() !="30"){
      #如果页面未到尾部，则点击下一页
      remDr$findElement('xpath','//div[@class="pager_container"]/a[last()]')$clickElement()
      #但因当前任务进度
      cat(sprintf("第【%d】页抓取成功",i),sep = "\n")
    } else {
      #如果页面到尾部则跳出while循环
      break
    }
  }
  #跳出循环后关闭remDr服务窗口
  remDr$close() 
  #但因全局任务状态（也即任务结束）
  cat("all work is done!!!",sep = "\n")
  #返回最终数据
  return(myresult)
}


url <- "https://www.lagou.com/zhaopin"
myresult <- myresult(remDr,url)
#预览
DT::datatable(myresult)



