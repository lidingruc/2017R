# 几个包的安装
# https://stackoverflow.com/questions/37014340/installing-r-package-opennlp-in-r
#1. Launch R at the command line (To test solution)
#> sudo R CMD javareconf
#> export LD_LIBRARY_PATH=$JAVA_LD_LIBRARY_PATH
#> LD_LIBRARY_PATH=$(/usr/libexec/java_home)/jre/lib/server: open -a RStudio

##now within RStduio:
# > install.packages("rJava", type = "source")
#> install.packages("openNLP")
#> require(rJava)
#> require(openNLP)

#To launch RStudio from finder... (El Capitan)
#You have to link libjvm.dylib to /usr/lib...
#sudo ln -s $(/usr/libexec/java_home)/jre/lib/server/libjvm.dylib /usr/local/lib

# 可以下载到本地，网速比较慢
# 可以尝试将包的源文件下载本地 安装

library(ezdf)

install.packages("rJava", type = "source")
install.packages("Rwordseg", repos = "http://R-Forge.R-project.org")
install.packages("tmcn", repos="http://R-Forge.R-project.org")
install.packages("Rweibo", repos = "http://R-Forge.R-project.org")

library(rJava);  
library(Rwordseg); 
library(tmcn); 

# 了解文本资料特征
# 设置文档存储位置

setwd("/Users/liding/E/Bdata/Course/6TextasData/")
a <-"十八大以来，中央在选用干部的思路上强调不搞表面文章、唯才是用、注重实效，布小林此番进步，正因为她是符合实际需要的人选，可谓举贤不避亲。"
nchar(a) #计算字符串长度
strsplit(a,split="，") #字符串切割
avec <- unlist(strsplit(a,split="，"))  #字符串拼接
paste(avec,collapse=",")
substr(a, 1,13)  #字符串截取

###########读取样本文本（省长信箱）
#### 原文件的格式gb18030,手工改变文件存储之后得到可用的
lecture<-read.csv("samgov1.csv",encoding="utf-8")

head(lecture)
nchar(lecture) #计算字符串长度
n=length(lecture[,1]);  
print(n) 
 
# == 文本预处理  
res=lecture[lecture!=" "]; 
ls()
fix(res)

#剔除URL  
res=gsub(pattern="http:[a-zA-Z\\/\\.0-9]+","",res);   

#剔除特殊词  
res=gsub(pattern="[我|你|的|了|一下|一个|没有|这样|现在|原告|被告|北京|法院|简称]","",res);

#剔除数字 
res=gsub(pattern="/^[^0-9]*$/","",res); 

# 安装新词典-sougou 输入法
# 查找下载相关字典
# http://pinyin.sogou.com/dict/
#清华大学词库 http://thuocl.thunlp.org/

installDict("科学发展观.scel","kxfzg")
installDict("xinli.scel","xinli") # 心理学
installDict("zzx.scel","zzx") # 政治学
listDict()
uninstallDict()

# == 临时添加新词  
insertWords("百忙之中") 
insertWords("白忙") 

# == 分词+频数统计
# 单个文档分词
segmentCN("崇仁陈坊村书记游桂发与崇仁县森林公安分局大队长朱鹰勾结指使人将林木一伐而光当今天国家大力提倡退耕还林、保护我们日益生存环境的同时，竟然有无视法律的森林公安分局警官、村干部及村民做出如此令人痛心的勾当，不揭发难于平民愤。事情从2007年初说起，江西省抚州市崇仁县相山镇陈坊村民委员会书记游XX与崇仁县森林公安分局大队长朱X（主管相山镇山林）勾结，指示陈坊村委会茶坪村小组的组长谢XX、谢XX先后请了两批砍伐工人，将茶坪村老辽、南美坑等山地的阔叶林木一伐而光。砍伐时间长达1年、涉及原始森林面积大约1800亩、当时的价值约100多万元。据当地村小组的村民说：这片森林在国民党时期都没有砍伐，但就在江西省启动天然阔叶林保护工程，全省禁伐天然阔叶林木时，却被毁于一旦。昔日1800多亩的原始森林现是疮痍满目、荒芜一片，看了让人无比的心痛。由于这勾当没有得到应有的制裁，更是无法无天了。2008年7月，几个福建商人明目张胆地，砍伐茶坪村村口一棵几百年的红豆杉，然后把伐断的红豆杉安然无恙运回福建。在福建商人开始运红豆杉时，就有村委会的干部向朱鹰报告，但没有任何结果，过了六天后朱鹰才来到红豆杉被砍伐的现场。这是失职吗？几个外省人怎会知道江西省崇仁县一个山旮旯的地方有如此珍稀的古木呢？红豆杉：国家一级保护植物，有“活化石植物”之称，是濒危物种，像茶坪村口这棵几百年的红豆杉更是珍稀。茶坪村现还有三棵同样大的红豆杉，不知什么时候又要被毁。其实这事有记者采访过，后公安部门派人到那里查。而谢XX被当替死鬼，被公安部门通缉，常年在外省躲藏，由游XX和朱X等人提供资金支持。不让他们回来。据说当时叫他们走的时候每人给了十万块钱。而真正的罪魁祸首游XX、朱X却拿着人民的几百万逍遥法外。这本不是和谐社会应该有的现象。希望政府部门重视。否则法将不法，国将不国。地方官方一手遮天，山高皇帝远。我深爱这个国家，深爱这个民族，我心所以会痛啊。呼吁有关部门，打击这帮无法无天为了私利的盗木者，将他们绳之于法，使我们现存的绿色家园不再被毁!这事情已经过去几年了，当地农民也是投诉无门，只能吃哑巴亏了，在那个靠山吃山的村庄，没有山的村民纷纷向下游迁徙，现在的茶坪村已经空无一人，以前多美丽的村庄，如今成了这样，不得不叫人寒心。")  
segmentCN("崇仁陈坊村书记游桂发与崇仁县森林公安分局大队长朱鹰勾结指使人将林木一伐而光当今天国家大力提倡退耕还林", nature=TRUE)  
insertWords(c("崇仁","陈坊","勾结指使")) 
segmentCN("崇仁陈坊村书记游桂发与崇仁县森林公安分局大队长朱鹰勾结指使人将林木一伐而光当今天国家大力提倡退耕还林", nature=TRUE)  

# 多个文档分词
segmentCN(c("习近平前往美国出席第四届核安全峰会", "李克强：推进上海建设科技创新中心", "洪秀柱就任国民党主席 着蓝衣接证书及印信"))  

# 所有文档分词
words=unlist(lapply(X=res, FUN=segmentCN));  
word=lapply(X=words, FUN=strsplit, " ");  
v=table(unlist(word));    
summary(v)

# 降序排序  
v=rev(sort(v));   
d=data.frame(word=names(v), freq=v);   
head(d)
# 过滤掉1个字和词频小于2的记录  
d=subset(d, nchar(as.character(d$word))>1 & d$freq.Freq>=2)  
names(d)<-c("word","var","freq")
# 加载词云分析模块
library(wordcloud)
require(scales)
library(RColorBrewer)

# 映射windows字体
#windowsFonts(A=windowsFont("微软雅黑"))
par(family="A") 
wordcloud(d$word,d$freq,random.order=FALSE,rot.per=.45,col=brewer.pal(9,"Set1"))
wordcloud(d$word,d$freq,random.order=FALSE,rot.per=.45,col=rainbow(length(d$freq)))
wordcloud(d$word,d$freq,random.order=FALSE,rot.per=.45,col=rainbow(length(d$freq)),max.words=100)
wordcloud(names(d$freq), d$freq, min.freq=100, scale=c(5, .1), colors=brewer.pal(6, "Dark2")) 
wordcloud(names(d$freq), d$freq, max.words=100, rot.per=0.2, colors=brewer.pal(6, "Dark2"))  

# 输出结果  
write.csv(d, file="samgov2.csv", row.names=FALSE)  



# jiebaR 分词
library(jiebaR)
engine<-worker()
words<-"想学R语言，那就赶紧拿起手机，打开微信，关注公众号《跟着菜鸟一起学R语言》，跟着菜鸟一块飞。"
segment(words,engine)

engine<=words

# 添加词库
engine_new_word<-worker()
new_user_word(engine_new_word, c("公众号","R语言"))
segment(words,engine_new_word)

#批量从文件导入
#engine_user<-worker(user='dictionary.txt')
#segment(words,engine_user)
#或者
#new_user_word(engine_new_word,
#              scan("dictionary.txt",what="",sep="\n"))
#segment(words,engine_new_word)

# 停用词
#engine_s<-worker(stop_word = "stopwords.txt")
#segment(words,engine_s)

# 词频统计
freq(segment(words,engine))

# 词性确定
qseg[words]
qseg<=words
#词性标注也可以使用worker函数的type参数，type默认为mix，仅需将它设置为tag即可。
tagger<-worker(type="tag")
tagger<=words

#提取关键词
#我们需要把worker里面的参数type设置为keyword或者simhash，使用参数topn设置提取关键字的个数，默认为5个。
#type=keywords
keys<-worker(type="keywords",topn=2)
keys<=words
#type=simhash
keys2<-worker(type="simhash",topn=2)
keys2<=words

#R豆瓣读书
#获取信息有点困难
#http://qxde01.blog.163.com/blog/static/6733574420132915952828/
library("devtools")
install_github("Rdouban","qxde01")
library(Rdouban)
qxde<-user_book_status(userid='qxde01',verbose=FALSE)
data(stopwords) ## 中文停止词
## 生成用户qxde01的2013年阅读信息可视化图形
user_book_viz(x=qxde,YEAR="2013",stopwords=stopwords,back=TRUE)

library(wordcloud2)
wordcloud2(demoFreqC)
wordcloud2(demoFreq)
