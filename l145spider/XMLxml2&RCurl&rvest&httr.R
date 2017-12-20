#######################################
#网页抓取
#httr包的功能 类似于python的Requests
#rvest也是hadley创建，整合了httr的功能
#能够同时使用XPath和selectr
#https://r-how.com/packages

#RCurl包是curl在R中的对应，基于C。很快！
#https://r-how.com/packages/httr

##########################
#示例1：httr抓取网页
#########################
library(httr)
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

#content自带解析功能，采用xml2解析
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
#见第五讲综合实例课的人人网个人好友网络抓取代码


#######################################
#网页解析和元素提取
#可用用XML提取，
#可以用xlm2提取
#都是基于‘libxml2’ C library
#可以用selectr提取

##########################
#示例3：使用xml2提取网页
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
#示例4：使用XML提取网页
#########################
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
#参考资料：xml2，XML批量操作
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
#XML 批量化提取的例子
#########################
#http://stackoverflow.com/questions/24576962/how-write-code-to-web-crawling-and-scraping-in-r
library(XML)
library(httr)
url <- "http://www.wikiart.org/en/claude-monet/mode/all-paintings-by-alphabet/"
hrefs <- list()
for (i in 1:23) {
  response <- GET(paste0(url,i))
  doc      <- content(response,type="text/html")
  hrefs    <- c(hrefs,doc["//p[@class='pb5']/a/@href"])
}

url      <- "http://www.wikiart.org"
xPath    <- c(pictureName = "//h1[@itemprop='name']",
              date        = "//span[@itemprop='dateCreated']",
              author      = "//a[@itemprop='author']",
              style       = "//span[@itemprop='style']",
              genre       = "//span[@itemprop='genre']")
get.picture <- function(href) {
  response <- GET(paste0(url,href))
  doc      <- content(response,type="text/html")
  info     <- sapply(xPath,function(xp)ifelse(length(doc[xp])==0,NA,xmlValue(doc[xp][[1]])))
}
pictures <- do.call(rbind,lapply(hrefs,get.picture))
head(pictures)

# 爬民政部社会组织年鉴数据
library(XML)
library(httr)
urlst <- "http://www.chinanpo.gov.cn/zznjresult.html?netTypeId=1&websitId=100&page_flag=true&goto_page="
urled<-"&current_page=32&total_count=31134&result=&registrationDeptCode=&times=&registrationNo=&managerDeptCode=&orgName=&type=&checkYear=&topid=&to_page=45"

hrefs <- list()
#http://www.chinanpo.gov.cn/zznjresult.html?netTypeId=1&websitId=100&page_flag=true&goto_page=145&current_page=32&total_count=31134&result=&registrationDeptCode=&times=&registrationNo=&managerDeptCode=&orgName=&type=&checkYear=&topid=&to_page=45

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
setwd('/Users/liding/E/Bdata/rtemp/data')
write.table(data, "chinanpo.csv", row.names=TRUE, sep=",")



# 最开始的时候通过下面的代码测试获得第一页的表格
html<-getURL(paste0(urlst,1,urled),.encoding='GB2312')
tables <- readHTMLTable(html,stringsAsFactors = FALSE)
data<- tables[[4]]

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


##抓取新浪调查页面
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
  
  data<-matrix(,40,4)  # 定义一个40行，6列的矩阵
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

## 一步抓取表格
#自带请求器的解析包，而且还是嵌入的pantomjs无头浏览器
# phantomjs渲染效果，直接抓取格式化网页 例子很好
# phantomjs 安装之后需要修改环境变量
# http://note.youdao.com/noteshare?id=25579f889483fca14ffb134775b96309

stopifnot(Sys.which("phantomjs") != "")

library(magrittr)
URL<-"https://www.aqistudy.cn/historydata/monthdata.php?city=北京"
library("rdom")
library(XML)
tbl <- rdom(URL) %>% readHTMLTable(header=TRUE) %>% `[[`(1)
names(tbl) <- names(tbl) %>% stri_conv(from="utf-8")
DT::datatable(tbl)


library("rvest") 
URL<-"https://www.aqistudy.cn/historydata/monthdata.php?city=北京" %>% xml2::url_escape(reserved ="][!$&'()*+,;=:/?@#")

library(RCurl)
header<-c("User-Agent"="Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36") 

mytable <- getURL(URL,httpheader=header,.encoding="UTF-8") %>% htmlParse(encoding ="UTF-8") %>% readHTMLTable(header=TRUE) $`NULL` 

#rvest

mytable <- URL %>%  read_html(encoding ="UTF-8") %>% html_table(header=TRUE) %>% `[[`(1) 

