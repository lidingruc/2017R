#######################################################
#教学目标：
#一、R作图的基本原则
#二、基础绘图
#三、ggplot2作图，映射、几何对象、分组、坐标轴、标签、样式设定等
#四、作图基础！
#五、其他作图如lattice

# 综合了肖凯、陈堰平、纽约大学图书馆、John Fox课件的内容


# 1.1、为什么要作图
#数据下载：http://www.xueqing.tv/upload/april-training/day4/data.zip
# http://www.xueqing.tv/upload/april-training/day4/index.html#1
#http://guides.nyu.edu/r


#########################################################
# 一图胜千言示例1：相关散点图

setwd("/Users/liding/E/Bdata/rtemp/")
data <- read.table('data/anscombe1.txt',T)
head(data)
data <- data[,-1]
head(data)
dim(data)

# 我们可以看原始数据，可以汇总各种指标。
colMeans(data)
rowMeans(data)
sapply(1:4,function(x) cor(data[,x],data[,x+4]))
# 但是，都远远不如可视化来得更为直接。
par(mfrow=c(2,2))
sapply(1:4,function(x) plot(data[,x],data[,x+4]))


#########################################################
# 一图胜千言示例2：HLM模型
# Trellis displays (implemented in lattice package; uses grid package)

library(nlme) # for data
library(lattice) # for Trellis graphics 
head(MathAchieve)
head(MathAchSchool)

# data management

Bryk <- MathAchieve[, c("School", "SES", "MathAch")]
Sector <- MathAchSchool$Sector
names(Sector) <- row.names(MathAchSchool)
Bryk$Sector <- Sector[as.character(Bryk$School)]
head(Bryk)

# examine 20 Catholic

set.seed(12345) # for reproducibility
cat <- with(Bryk, sample(unique(School[Sector=="Catholic"]), 20))
Cat.20 <- Bryk[Bryk$School %in% cat, ]

res <- xyplot(MathAch ~ SES | School, data=Cat.20, main="Catholic Schools",
              ylab="Math Achievement",
              panel=function(x, y){ 
                panel.xyplot(x, y)
                panel.loess(x, y, span=1)
                panel.lmline(x, y, lty=2)
              }
)
class(res)
res  # "printing" plots the object

remove(list=objects())  # clean up

#########################################################
# 一图胜千言示例3：3D动态图
# rgl 3D graphics package (by Daniel Adler and Duncan Murdoch)
# uses scatter3d() from car package
library(car)
scatter3d(prestige ~ log(income) + education | type, data=Prestige, 
          ellipsoid=TRUE, parallel=FALSE,revolution=TRUE)  

# data(Duncan, package="car")
# 加上revolutions=3表示自动旋转
scatter3d(prestige~education+income, data=Duncan, fit="linear", 
          residuals=TRUE, bg="white", axis.scales=TRUE, grid=TRUE, ellipsoid=TRUE, 
          id.method='mahal', id.n = 3, revolutions=3)

## 3D图
library(rgl)
x <- sort(rnorm(1000))
y <- rnorm(1000)
z <- rnorm(1000) + atan2(x,y)
plot3d(x, y, z, col=rainbow(1000))


#3D 曲面图
library(plyr)
library(lattice)
func3d <- function(x,y) {
  sin(x^2/2 - y^2/4) * cos(2*x - exp(y))
}
vec1 <- vec2 <- seq(0,2,length=30)
para <- expand.grid(x=vec1,y=vec2)
result6 <- mdply(.data=para,.fun=func3d)

wireframe(V1~x*y,data=result6,scales = list(arrows = FALSE),
          drape = TRUE, colorkey = F)

#########################################################
#1.2、作图的基本原则

##1. 需要事先明确可视化的具体目标
###探索性可视化
###解释性可视化

##2. 需要考虑数据和受众群体的特点
###哪些变量最重要最有趣
###受众方面要考虑阅读者的角色和知识背景
###选择合适的映射方式

##3. 在传送足够信息前提下保持简洁

##4、将变量取值映射到图形元素上
### 坐标位置
### 尺寸
### 色彩
### 形状
### 文字



############################################################
# 二、利用基础绘图命令做统计图

if(!require(MASS)) install.packages("MASS")
data(UScereal)
head(UScereal)

############################################################
# A. 选择合适的统计图

# 单个连续变量的分布：One Continuous Variable

# Q: What is the Distribution of Variable X?
# Q: Is my Variable X normally distributed? Bimodal? Skewed?
# Q: Are there any outliers in my variable?

# Histogram
hist(UScereal$calories, breaks = 15)
hist(UScereal$calories, bin = 15)

# Boxplot
boxplot(UScereal$calories, horizontal = TRUE)


# 单个分类变量：One Categorical (Discrete) Variable

# Q: 各个类别是否均匀 evenly distributed?

barplot(table(UScereal$shelf))

plot(UScereal$shelf,type="p") # 没有意义

# 两个连续变量：Two Continuous Variables

# Q: Is there a relationship between Variable X and Variable Y?
# Q: If there is a relationship, is it linear? Quadratic? 

plot(x = UScereal$sugars, y = UScereal$calories)

plot(calories ~ sugars, data = UScereal) # formula notation

plot(UScereal[, c(2:8, 10)]) # 8个变量的scatterplot matrix


# 一个连续变量和一个分类变量
# One Continuous Variable and One Categorical Variable

# Q: Is the distribution of Variable Y, different across categories of Variable X?

boxplot(sugars ~ shelf, data = UScereal, horizontal = TRUE)


# 两个连续变量和一个分类变量
# Two Continuous Variables and One Categorical Variable

# Q: Is the relationship between Variable X and Y different across categories of Variable Z?

plot(calories ~ sugars, data = UScereal, col = shelf)
legend('topright', inset = .05, legend = c(3,2,1),
       fill = c('green', 'red', 'black'))


##################################################
# 添加其他图形元素
# 方法1：在plot中用ylab, xlab and main参数
if(!require(MASS)) install.packages("MASS")
data(UScereal)

plot(calories ~ sugars, data = UScereal, ylab = 'Calories',
     xlab = 'Sugars (grams)', main = 'Nutrition of a Single Cup of Cereal')


# 方法2 使用title function
# 此时plot中设定 ann=FALSE 抑制原轴标题
# Turn off axes and annotations (axis labels)
plot(calories ~ sugars, data = UScereal, ann = FALSE)
title(main = 'Nutrition of a Single Cup of Cereal', ylab = 'Calories',
      xlab = 'Sugars (grams)') # add afterwards

###################################################
# 图例 legend
# 在plot后使用legend function
plot(calories ~ sugars, data = UScereal, col = shelf)
legend('topright', inset = .05, legend = c(3,2,1),
       fill = c('green', 'red', 'black'))


###################################################
# 修改点形状和颜色 Point Shape and Color 
# Tip: Changing color or shape of points can be used to represent the same dimension

plot(calories ~ sugars, data = UScereal, pch = 15)


# Set a color to a factor variable, and R will use default colors
plot(calories ~ sugars, data = UScereal, pch = 19, col = shelf, bg = shelf)
legend('topright', inset = .05, legend = c(3,2,1),
       fill = c('green', 'red', 'black'))


# Use a palette of defined colors
palette(c('#e5f5f9', '#99d8c9', '#2ca25f'))
plot(calories ~ sugars, data = UScereal, pch = 19, col = shelf, bg = shelf)
legend('topright', inset = .05, legend = c(3,2,1),
       fill = c('#e5f5f9', '#99d8c9', '#2ca25f'))


###################################################
# 给点加标签 Label points

# Label points with the text function
plot(calories ~ sugars, data = UScereal, pch = 15)
text(UScereal$sugars, UScereal$calories, row.names(UScereal),
     col = "red", pos = 1, cex = .5)

# The pos argument(1,2,3,4) 点的下左上右
plot(calories ~ sugars, data = UScereal, pch = 15)
text(UScereal$sugars, UScereal$calories, UScereal$mfr, col = "blue", pos = 2)

# 标记极端值 Identify Outliers

# 1. 选出极端案例，以之作标签
plot(calories ~ sugars, data = UScereal, pch = 19)

outliers <- UScereal[which(UScereal$calories > 300),]
text(outliers$sugars, outliers$calories - 15, labels = row.names(outliers))


# 2. 交互式选择-不太好选
plot(calories ~ sugars, data = UScereal, pch = 19)
identify(UScereal$carbo, UScereal$calories, n = 2, labels = row.names(UScereal))     


# 3. 修改axis limits to remove outliers from view
plot(calories ~ sugars, data = UScereal, pch = 19, ylim = c(0, 325))


###################################################
# 修改图形元素大小(text size, point size, label size etc..)

# Use cex argument family
plot(calories ~ sugars, data = UScereal, pch = 19, ann = FALSE, cex = 1.5)
outliers <- UScereal[which(UScereal$calories > 300),]
text(outliers$sugars, outliers$calories - 15,
     labels = row.names(outliers), cex = .75)
title(main = 'Nutrition of a Single Cup of Cereal', ylab = 'Calories',
      xlab = 'Sugars (grams)', cex.main = 2, cex.lab = 1.5)


###################################################
# Combine Graphs into the Same Window
##通过par读图形参数进行全局设定
par(mfrow = c(2, 2))

boxplot(calories ~ shelf, data = UScereal)
hist(UScereal$calories, breaks = 15)
boxplot(sugars ~ shelf, data = UScereal)
hist(UScereal$sugars, breaks = 15)
# 保存图片
dev.print(png,file="file1.png",width=480,height=640)


par(mfrow = c(1, 1)) # reset the matrix

# 查看可选项
names(par())

# 查看参数
par("col")  # graphical parameters color

###################################################
# Exercise 1a. 
# How can we improve this graph? From what we have learned above, implement at least 3 improvements to this graph.
# A little more information about this dataset: The heart and body weights of samples of male and 
# female cats used for digitalis experiments. The cats were all adult, over 2 kg body weight.
data(cats)
head(cats)
plot(Hwt~Bwt, data = cats)

# Exercise 1b.
# How can we improve this graph? From what we have learned above, implement at least 3 improvements to this graph.
# A little more information about this dataset: The heart and body weights of samples of male and 
# Fisher's famours dataset measures the sepal and petal length and width for 3 species of Iris
data(iris)
head(iris)
boxplot(Petal.Width ~ Species, data = iris)

		
# ----------------------------------------------
# - 三 利用ggplot2作图 -
# ----------------------------------------------
# ggplot2 package (by Hadley Wickham)
# 请主要参看 R4DS

library(ggplot2)
#数据data
#映射关系，mapping
#几何对象，geom
#文本元素，text

###################################################
# A. ggplot 函数

# quick plot function
# 散点图
qplot(income, prestige, 
      xlab="Average Income", ylab="Prestige Score",
      geom=c("point", "smooth"), data=car::Prestige)
# 分色散点图
qplot(x = sugars, y = calories, color = as.factor(shelf),
      data = UScereal) 

# 多个图形元素
qplot(cty,hwy,
      data=mpg,
      geom=c("point", "smooth"))

#ggplot function函数+ 图层
p1 <- ggplot(UScereal)
p <- p1 + geom_histogram(aes(x = calories)) 
print(p)
summary(p)  ## 查看p的内部结构  两层内容


###################################################
# B. 图层 Layers 

# 利用'+'在ggplot object基层上添加图层
p1 <- ggplot(UScereal, aes(x = calories))

p1 + geom_dotplot()

p1 + geom_density()

p1 + geom_histogram(binwidth = 10)


# 可以添加多个图层
p1 + geom_histogram(binwidth = 10) + xlab('Calories in a Single Cup') +
  ylab('Frequency') + 
  ggtitle('Distribution of Calories in US Cereals') + theme_bw()


# 图层的顺序无关
p1 + geom_histogram(binwidth = 10) + xlab('Calories in a Single Cup') +
  ylab('Frequency') + ggtitle('Distribution of Calories in US Cereals') + 
  theme_bw() + theme(text = element_text(size = 30))


# 可以添加多个 geom_function
p2 <- ggplot(UScereal, aes(x = sugars, y = calories, color = mfr))
p2  + geom_point() + geom_smooth() + geom_line()

###################################################
# 五种named graph
# scatterplots : geom_point() 注意alpha参数和geom_jitter() 
# linegraphs : geom_line() 
# boxplots: geom_boxplot()
# histograms: geom_histogram()  注意 bins或binwidth 参数
# barplots:geom_bar() 或者 geom_col()  注意 position参数:簇状、叠加


###################################################
# C. 选择和修改美学特征
# Aesthetics: x position, y position, size of elements, shape of elements, color of elements
# elements: geometric shapes such as points, lines, line segments, bars and text
# geomitries have their own aesthetics i.e. points have their own shape and size


# To color by manufacturer - 在ggplot function中设定与某变量对应:
p2 <- ggplot(UScereal, aes(x = sugars, y = calories, color = mfr))

p2 + geom_point() 

my_colors <- c('#9ebcda', '#8c96c6', '#8c6bb1', '#88419d', '#810f7c', '#4d004b')

p2 + geom_point() + scale_color_manual(values = my_colors) 


# 或者inside the geom_point function:
p2 <- ggplot(UScereal, aes(x = sugars, y = calories))
p2 + geom_point(aes(color = mfr)) 


# 给点添加标签 Adding Labels to points

# 使用 geom_text() layer
p2 + geom_point(aes(color = mfr)) + 
  geom_text(aes(label = row.names(UScereal)), hjust = 1.1)


# 改变 point size
p2 + geom_point(aes(color = mfr), size = 4) 


# 编辑 legend

# Use the scale_color_manual() layer, and the color argument in the labs() layer 
p2 + geom_point(aes(color = mfr), size = 5) +labs(color = 'Manufacturer') + 
  scale_color_manual(values = c('blue', 'green', 'purple', 'navyblue', 'red', 'orange'),
                     labels = c('General Mills', 'Kelloggs', 'Nabisco', 'Post', 'Quaker Oats', 'Ralston Purina'))  + theme(text = element_text(size = 30)) 


###################################################
# D. 分面 Faceting  - divide a plot into subplots based on the valuesof one or more discrete variables

# Tip: Use facets to help tell your story
# Q: How is the distribution of sugar across different shelves?
# Q: Are cereals with higher sugar content on lower shelves/at a child's eye level?

p3 <- ggplot(UScereal, aes(x = sugars))

p3 + geom_histogram(binwidth = 4)

# Each graph is in a separate row of the window
p3 + geom_histogram(binwidth = 4) + facet_grid(shelf ~ .)

# Each graph is in a separate column of the window
p3 + geom_histogram(binwidth = 4) + facet_grid(. ~ shelf)

# Finished product 
p3 + geom_histogram(fill = '#3182bd', color = '#08519c', binwidth = 4) +
  facet_grid(shelf ~ .) + theme(text = element_text(size = 20)) + 
  labs(title = 'Are Sugary Cereals on Lower Shelves?',
       x = 'Sugars (grams)', y = 'Count')

###################################################
# Box Plots
p4 <- ggplot(UScereal, aes(mfr, calories))
p4 + geom_boxplot()
p4 + geom_boxplot(notch = TRUE)
p4 + geom_violin()

p4 + geom_boxplot(outlier.shape = 8, outlier.size = 4, fill = '#3182bd') + coord_flip() + 
  labs(x = 'Manufacturer', y = 'Calories') + theme_bw() + 
  scale_x_discrete(labels = c('General Mills', 'Kelloggs', 'Nabisco', 'Post', 'Quaker Oats', 'Ralston Purina'))

# Add median value to boxplot

install.packages('dplyr')
library(dplyr)
p4_meds <- UScereal %>% group_by(mfr) %>% summarise(med = median(calories))

p4 + geom_boxplot(outlier.shape = 8, outlier.size = 4, fill = '#8c96c6') + 
  labs(x = 'Manufacturer', y = 'Calories') + theme_bw() + 
  scale_x_discrete(labels = c('General Mills', 'Kelloggs', 'Nabisco', 'Post', 'Quaker Oats', 'Ralston Purina')) + 
  geom_text(data = p4_meds, aes(x = mfr, y = med, label = round(med,1)), size = 4, vjust = 1.2)

###################################################
# Exercise 2a. Use ggplot2 to improve the graph below:
data(cats)
head(cats)
plot(Hwt~Bwt, data = cats)


# Exercise 2b. Use ggplot2 to improve the graph below:
data(iris)
head(iris)
boxplot(Petal.Width ~ Species, data = iris)


# ----------------------------
# - 练习题答案 -
# ----------------------------

# Below are just examples of cleaned up graphics. There are many solutions on how to improve these graphs

# Exercise 1a 

palette(c('#fa9fb5', '#9ebcda'))
plot(Hwt~Bwt, data = cats, ylab  = 'Heart Weight (grams)', xlab = 'Body Weight (kg)', main = 'Measurements of Cats', pch = 16, col = Sex)

# Exercise 1b
boxplot(Petal.Width ~ Species, data = iris, xlab = 'Petal Width (centimeters)', 
        main = 'Distribution of Petal Length by Species', pch = 8, horizontal = TRUE, col = 'lightgray')



# Exercise 2a
e2a <- ggplot(cats, aes(Bwt, Hwt, color = Sex))
e2a + geom_point() + theme_bw() + labs(title = 'Measurements of Cats', x = 'Body Weight (kg)', y = 'Heart Weight (grams)')

# Exercise 2b
e2b <- ggplot(iris, aes(Species, Petal.Width))
e2b + geom_boxplot(fill = '#addd8e') + theme_bw() + coord_flip() + ggtitle('Distribution of Petal Length by Species' )



#ggplot作图
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy)) + geom_point()
# 加点标签
p+geom_text(aes(label=manufacturer),hjust=0, vjust=0)
p+geom_text(aes(label=ifelse(cty>30,manufacturer,'')),hjust=0,vjust=0)


# 加入年份变量
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy,colour=factor(year))) 
p + geom_point()


# 加入统计量

p + stat_smooth() ## 平滑散点图


# 同时包含点和拟合曲线 
#课堂练习：下面的图，如果变成两条拟合曲线，怎么做？)
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy)) +
	geom_point(aes(colour=factor(year))) +
	stat_smooth()
print(p)

# 如何来控制Scale 标度 呈现样式
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy)) +
	geom_point(aes(colour=factor(year))) +
	stat_smooth() +
	scale_color_manual(values=c('blue2','red4'))
print(p)

#分面 化成两图
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy)) +
	geom_point(aes(colour=factor(year))) +
	stat_smooth() +
	scale_color_manual(values=c('blue2','red4')) +
	facet_wrap(~year,ncol=1)
print(p)

# 做一些精细化的调整
p<-ggplot(data=mpg,mapping=aes(x=cty,y=hwy)) +
	geom_point(aes(colour=class,size=displ),
				alpha=0.5,position = 'jitter') +
	stat_smooth() +
	scale_size_continuous(rang = c(4,10)) +
	facet_wrap(~year,ncol=1) +
	opts(title='汽车型号与油耗')+
	labs(y='每加仑高速公路行驶距离',
		x='每加仑城市公路行驶距离',
		size='排量',
		colour ='车型')
print(p)


## 直方图
p <- ggplot(data=iris,aes(x=Sepal.Length))+ 
     geom_histogram()
print(p)

ggplot(iris,aes(x=Sepal.Length))+ 
     geom_histogram(binwidth=0.1,   # 设置组距
                   fill='skyblue', # 设置填充色
                   colour='black') # 设置边框色
# 增加概率密度曲线 
ggplot(iris,aes(x=Sepal.Length)) +
	geom_histogram(aes(y=..density..),
	fill='skyblue',
	color='black') +
	stat_density(geom='line',color='black',
	linetype=2,adjust=2)

#调整平滑宽度，adjust参数越大，越平滑。
ggplot(iris,aes(x=Sepal.Length)) +
     geom_histogram(aes(y=..density..), # 注意要将y设为相对频数
                   fill='gray60',
                   color='gray') +
    stat_density(geom='line',color='black',linetype=1,adjust=0.5)+
    stat_density(geom='line',color='black',linetype=2,adjust=1)+
    stat_density(geom='line',color='black',linetype=3,adjust=2)

#面积曲线-分类
ggplot(iris,aes(x=Sepal.Length,fill=Species)) +
     geom_density(alpha=0.5,color='gray')


#箱子图-分类
ggplot(iris,aes(x=Species,y=Sepal.Length,fill=Species)) +
     geom_boxplot()

#小提琴图
p <- ggplot(iris,aes(x=Species,y=Sepal.Length,fill=Species)) +
     geom_violin()
print(p)

#小提琴叠加点图
p <- ggplot(iris,aes(x=Species,y=Sepal.Length,
                     fill=Species)) +
     geom_violin(fill='gray',alpha=0.5)+
     geom_dotplot(binaxis = "y", stackdir = "center")

#条形图	
p <- ggplot(mpg,aes(x=class))+
         geom_bar()
print(p)
# 按照频次排序
ggplot(mpg,
       aes(x=reorder(class,class,
                     function(x) -length(x)))) +
  geom_bar()

# 另一种做法是先修改分类变量的排序，然后作图
## set the levels in order we want
theTable <- within(mpg, 
                   class <- factor(class, 
                                      levels=names(sort(table(class), 
                                                        decreasing=TRUE))))
## plot
ggplot(theTable,aes(x=class))+geom_bar( )

##第三种画法
#汇总得到数之后
fdata <- as.data.frame(sort(table(mpg$class),decreasing = TRUE))
names(fdata)<-c("class","count")
ggplot(fdata,aes(x=class,y=count)) +
       geom_bar(stat = "identity")
# 第四种方法
fdata <- as.data.frame(table(mpg$class))
names(fdata)<-c("class","count")
#作图
ggplot(fdata,aes(x=reorder(class,-count),y=count)) +
  geom_bar(stat = "identity")


#频数叠加条形图
mpg$year <- factor(mpg$year)
p <- ggplot(mpg,aes(x=class,fill=year))+
            geom_bar(color='black')
print(p)

#簇状图
p <- ggplot(mpg,aes(x=class,fill=year))+
     geom_bar(color='black',
             position=position_dodge())
print(p)

#百分比叠加图
p <- ggplot(mpg,aes(x=class,fill=year))+
     geom_bar(color='black',
              position='fill') 
print(p)

# 饼图
p <- ggplot(mpg, aes(x = factor(1), fill = factor(class))) +
     geom_bar(width = 1)+ 
     coord_polar(theta = "y")
print(p)


# 结构连续变化图
data <- read.csv('data/soft_impact.csv',T)
library(reshape2)
data.melt <- melt(data,id='Year')
p <- ggplot(data.melt,aes(x=Year,y=value,
                          group=variable,fill=variable))+
     geom_area(color='black',size=0.3,
               position=position_fill())+
     scale_fill_brewer()
	 
#####

####################
#后面的图不讲

#图表风格
library("ggthemes")

#标记图中特殊的点
dat <- data.frame(x = rnorm(10), y = rnorm(10), label = letters[1:10])

#Create a subset of data that you want to label. Here we label points a - e
labeled.dat <- dat[dat$label %in% letters[1:5] ,]

ggplot(dat, aes(x,y)) + geom_point() +
  geom_text(data = labeled.dat, aes(x,y, label = label), hjust = 2)

#Or add a separate layer for each point you want to label.

ggplot(dat, aes(x,y)) + geom_point() +
  geom_text(data = dat[dat$label == "c" ,], aes(x,y, label = label), hjust = 2) + 
  geom_text(data = dat[dat$label == "g" ,], aes(x,y, label = label), hjust = 2)



perc.rank <- function(x) trunc(rank(x))/length(x)
my.df <- iris
my.df <- within(my.df, xr <- perc.rank(Sepal.Width))

plot(my.df$xr,my.df$Sepal.Width)

############################################################
# 二、绘图基础 (traditional S/R graphics)

args(plot.default)  # default plot method
# 默认方法的内容  type="p"表示散点图
# 帮助文件中可以看各个参数有哪些选项
?plot
?plot.default

# points, lines, axes, frames

# windows()  # 打开独立的图形窗口  for windows system
# X11() # for Mac system

plot(c(0, 1), c(0, 1), type="n", xlab="", ylab="")  # coordinate system

plot(c(0, 1), c(0, 1), type="n", xlab="", ylab="", axes=FALSE) # w/o axes

# 查看可选项
names(par())

# 查看参数
par("col")  # graphical parameters color



# 查看帮助
?par

# 例如，将作图窗口分为1行*2列
par(mfrow=c(1, 2))  # array of plots

###################################################
## 点线形状、轴标签、线型
# The pch argument changes the shape of the points
plot(1:25, pch=1:25, xlab="Symbol Number", ylab="")  # symbols
lines(1:25, type="S", lty="dashed") # type p l b c o s S h

## 字符、轴、外边框
plot(26:1, pch=letters, xlab="letters", ylab="",
     axes=FALSE, frame.plot=TRUE)
# no plot 
plot(c(1, 7), c(0, 1), type="n", axes=FALSE,  # lines
     xlab="Line Type (lty)", ylab="")

# add frame
box() 

###################################################
# 设置坐标轴方位、标签位置、线型
axis(1, at=1:6)  # x-axis 1 在南 2在西 3在北 4 在东
axis(2, at=c(0,0.5,1)) 
for (lty in 1:6) 
  lines(c(lty, lty, lty + 1), c(0, 0.5, 1), lty=lty)

# 坐标系、直线
plot(c(0, 1), c(0, 1), type="n", xlab="", ylab="")

abline(0, 1) # intercept and slope 加参照线
abline(c(1, -1), lty="dashed")  # 过两点
# horizontal and vertical lines: 
abline(h=seq(0, 1, by=0.1), v=seq(0, 1, by=0.1), col="gray")

###################################################
# # 标题 Titles 
plot(c(0, 1), c(0, 1), axes=FALSE, type="n", xlab="", ylab="",
     main="(a)",frame.plot=TRUE) 

# Tip: We want titles to meaningful, non-repetitive and include units when applicable

# 方法1：在plot中用ylab, xlab and main参数
if(!require(MASS)) install.packages("MASS")
data(UScereal)
plot(calories ~ sugars, data = UScereal, ylab = 'Calories',
     xlab = 'Sugars (grams)', main = 'Nutrition of a Single Cup of Cereal')


# 方法2 使用title function
# 此时plot中设定 ann=FALSE 抑制原轴标题
plot(calories ~ sugars, data = UScereal, ann = FALSE)
title(main = 'Nutrition of a Single Cup of Cereal', ylab = 'Calories',
      xlab = 'Sugars (grams)') # add afterwards

###################################################
# 图例 legend
# 在plot后使用legend function

plot(c(1,5), c(0,1), axes=FALSE, type="n", xlab="", ylab="",
     frame.plot=TRUE)

# 手工确定位置,字符，线型、符号、颜色
legend(locator(1), legend=c("group A", "group B", "group C"),
       lty=1:3, pch=1:3, col=c("blue", "green", "red"))

# 右上方
legend("topright", legend=c("group A", "group B", "group C"),
       lty=1:3, pch=1:3, col=c("blue", "green", "red"), inset=0.01)

plot(calories ~ sugars, data = UScereal, col = shelf)
legend('topright', inset = .05, legend = c(3,2,1),
       fill = c('green', 'red', 'black'))


###################################################
# # 文本位置
text(x=c(0.2, 0.5), y=c(0.2, 0.7),  
     c("example text", "another string"))

plot(c(0, 1), c(0, 1), axes=FALSE, type="n", xlab="", ylab="",
     frame.plot=TRUE, main="(b)")
# 手动添加left-click 3 times，请点击右侧图形三次。
text(locator(3), c("one", "two", "three"))  

locator() 
# 获得鼠标点击坐标，esc退出 


###################################################
# arrows and line segments（线段）
?arrows  # 可以查看可以设定的参数
# 箭头
plot(c(1, 5), c(0, 1), axes=FALSE, type="n", xlab="", ylab="")
arrows(x0=1:5, y0=rep(0.1, 5),   # 起点
       x1=1:5, y1=seq(0.3, 0.9, len=5), code=2) 
# 终点 已经箭头类型，1起点箭头,2终点箭头， 3两头有箭头，
title("(a) arrows")

# 线段
plot(c(1, 5), c(0, 1), axes=FALSE, type="n", xlab="", ylab="")
segments(x0=1:5, y0=rep(0.1, 5),
         x1=1:5, y1=seq(0.3, 0.9, len=5))
title("(b) segments")

# restore single panel
par(mfrow=c(1, 1)) 

###################################################
# 其他更漂亮的箭头（从略）
# nicer arrows: p.arrows() in the sfsmisc package
# note different arguments, unidirectional arrows
# question: how can you easily get bidirectional arrows?
# library(shape) 中的Arrows

if(!require(sfsmisc)) install.packages("sfsmisc")
plot(c(1, 5), c(0, 1), axes=FALSE, type="n", xlab="", ylab="")
p.arrows(x1=1:5, y1=rep(0.1, 5),
         x2=1:5, y2=seq(0.3, 0.9, len=5), fill="black")
# 反向箭头
p.arrows(x1=1:5, y1=seq(0.3, 0.9, len=5),
         x2=1:5, y2=rep(0.1, 5),
         fill="black")

# 多边形 polygon
plot(c(0, 1), c(0, 1), type="n", xlab="", ylab="")
polygon(c(0.2, 0.8, 0.8), c(0.2, 0.2, 0.8), col="red")
polygon(c(0.2, 0.2, 0.8), c(0.2, 0.8, 0.8))


####################################################
# curve

?plotmath   # 如何在图中输入公式

curve(x*cos(25/x), 0.01, pi, n=1000)

curve(sin, 0, 2*pi, ann=FALSE, axes=FALSE, lwd=2)
axis(1, pos=0, at=c(0, pi/2, pi, 3*pi/2, 2*pi),
     labels=c(0, expression(pi/2), expression(pi),
              expression(3*pi/2), expression(2*pi)))  # expression

axis(2, pos=0) # 坐标位置
curve(cos, add=TRUE, lty="dashed", lwd=2) # 添加到已有图上
legend(pi, 1, lty=1:2, lwd=2, legend=c("sine", "cosine"), bty="n")


#####################################################
# colors
pie(rep(1, length(palette())), col=palette())

palette()

# Hex 16进位： 0 1 2 ...9 A B C D E F
# 00 表示0， FF=16^2-1
# RGB原色 TT 透明度
rainbow(10) # "#RRGGBBTT" (red, green, blue, transparency)
pie(rep(1, 10), col=rainbow(10))

# 设定特定的颜色
pie(rep(1, 3), col=c("#FF0000FF","#00FF00FF","#0000FFFF"))

# 不同的灰
gray(0:9/9) # "#RRGGBB"
pie(rep(1, 10), col=gray(0:9/9))

# 定义好的color
length(colors())
head(colors(), 20) # first 20 named colors
pie(rep(1, 20), labels=head(colors(), 20), col=head(colors(), 20))


# for palettes based on psychophysical principles, see colorspace package

######################################################
# 利用这些基础命令，可以做出各种各样的示意图来
######################################################
# 标准正态分布示意图1（标定取值大于1.96部分带阴影）

# 设定边距
oldpar <- par(mar = c(5, 6, 4, 2) + 0.1)    # leave room on the left
oldpar  # old parameter saved
# z 1000个取值
z <- seq(-4, 4, length=1000)
# 密度取值
p <- dnorm(z)
# 作图
plot(z, p, type="l", lwd=2,
     main=expression("The Standard Normal Density Function" ~~ phi(z)),  ## 加空格用符号 ~~
     ylab=expression(phi(z) ==
                       frac(1, sqrt(2*pi)) * ~~ e^- ~~ frac(z^2, 2)))
abline(h=0, col="gray")
abline(v=0, col="gray")
# 可以一次添加两条线 abline(h=0, v=0 ), col="gray")
# 增加面积部分，得到坐标
z0 <- z[z >= 1.96]    # define region to fill
# 左侧起点
z0 <- c(z0[1], z0)
# 上方点，加一个0
p0 <- p[z >= 1.96]
p0 <- c(0, p0)

# 画出阴影部分
polygon(z0, p0, col="gray")
# 手工确定示意公式标签的头尾首尾位置
coords <- locator(2)    
arrows(coords$x[1], coords$y[1], coords$x[2], coords$y[2], code=1,
       length=0.125)
text(coords$x[2], coords$y[2], pos=3,   # text above tail of arrow
     expression(integral(phi(z)*dz, 1.96, infinity) == .025))

##########################
#标准正态分布示意图1（标定-3-3整数位置上的竖线）

par(oldpar)  # restore graphics parameters

# 利用上面参数画出合适大小的空画布
plot(z, p, type="n", xlab="", ylab="", axes=FALSE,
     main=expression("The Standard Normal Density Function" ~~ phi(z)))

# 坐标轴
axis(1, pos=0, at=-3:3)
abline(h=0)
axis(2, pos=0, at=.1*1:3)
abline(v=0)

# 曲线
curve(dnorm, -4, 4, n=1000, add=TRUE, lwd=2)

# 轴标签和曲线标签放在什么位置
text(locator(2), c("z", expression(phi(z))), xpd=TRUE)
# 画出竖直线
for (z0 in -3:3) lines(c(z0, z0), c(0, dnorm(z0)), lty=2)


#####################
# explaining nearest-neighbour kernel regression
# 示例核平滑的算法
oldpar <- par(mfrow=c(2,2), las=1)   # 2 x 2 array of graphs

library(car) # for data

UN <- na.omit(UN)
gdp <- UN$gdp
infant <- UN$infant.mortality
ord <- order(gdp)   # 得到GDP的位次，作为排序依据
gdp <- gdp[ord]
infant <- infant[ord]

x0 <- gdp[150]          # focal x = x_(150)
dist <- abs(gdp - x0)   # distance from focal x
h <- sort(dist)[95]     # bandwidth for span of .5 (where n = 190)
pick <- dist <= h       # observations within window

# upper-left panel

plot(gdp, infant, xlab="GDP per Capita", ylab="Infant-Mortality Rate",
     type="n", main="(a) Observations Within the Window\nspan = 0.5")
points(gdp[pick], infant[pick], col="blue")
points(gdp[!pick], infant[!pick], col=gray(0.75))
abline(v=x0, col="red")    # focal x
abline(v=c(x0 - h, x0 + h, col="blue"), lty=2)  # window
text(x0, par("usr")[4] + 10, expression(x[(150)]), xpd=TRUE, col="red") 
# above plotting region

# upper-right panel

plot(range(gdp), c(0,1), xlab="GDP per Capita",
     ylab="Tricube Kernel Weight",
     type="n", main="(b) Tricube Weights")
abline(v=x0, col="red")
abline(v=c(x0 - h, x0 + h), lty=2, col="blue")

# function to calculate tricube weights

tricube <- function(x, x0, h) {
  z <- abs(x - x0)/h
  ifelse(z < 1, (1 - z^3)^3, 0)
}

tc <- function(x) tricube(x, x0, h) # to use with curve

curve(tc, min(gdp), max(gdp), n=1000, lwd=2, add=TRUE)
points(gdp[pick], tricube(gdp, x0, h)[pick], col="blue", pch=16)
abline(h=c(0, 1), col="gray")

# lower-left panel

plot(gdp, infant, xlab="GDP per Capita", ylab="Infant-Mortality Rate",
     type="n", main="(c) Weighted Average (Kernal Estimate)")
points(gdp[pick], infant[pick], col="blue")
points(gdp[!pick], infant[!pick], col=gray(0.75))
abline(v=x0, col="red")
abline(v=c(x0 - h, x0 + h), lty=2, col="blue")
yhat <- weighted.mean(infant, w=tricube(gdp,  x0, h))  # kernel estimate
lines(c(x0 - h, x0 + h), c(yhat, yhat), lwd=3, col="red") # line at kernel estimate
text(x0, yhat, expression(widehat(y)[(150)]), adj=c(0, 0), col="red")

# lower-right panel

plot(gdp, infant, xlab="GDP per Capita", ylab="Infant-Mortality Rate",
     main="(d) Complete Kernel Estimate")
yhat <- numeric(length(gdp))
for (i in 1:length(gdp)){   # kernel estimate at each x
  x0 <- gdp[i]
  dist <- abs(gdp - x0)
  h <- sort(dist)[95]
  yhat[i] <- weighted.mean(infant, w=tricube(gdp, x0, h))
}
lines(gdp, yhat, lwd=2, col="red")

par(oldpar)  # restore plotting parameters

#######################################################
#一页多图，位置的细节性调整
# using par(mfrow=c(m, n))

par(mfrow=c(2, 2))

# 二次函数+随机波动
x <- seq(0, 1, length=200)
Ey <- rev(1 - x^2)
y <- Ey + 0.1*rnorm(200)
plot(x, y, axes=FALSE, frame=TRUE, main="(a) monotone, simple", 
     cex.main=1, xlab="", ylab="")
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)

# 对数函数+随机波动
x <- seq(0.02, 0.99, length=200)
Ey <- log(x/(1 - x))
y <- Ey + 0.5*rnorm(200)
plot (x, y, axes=FALSE, frame=TRUE, main="(b) monotone, not simple", 
      cex.main=1, xlab="", ylab="")
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)

# 二次函数+随机波动
x <- seq(0.2, 1, length=200)
Ey <- (x - 0.5)^2
y <- Ey + 0.04*rnorm(200)
plot(x, y, axes=FALSE, frame=TRUE, main="(c) non-monotone, simple", 
     cex.main=1, xlab="", ylab="")
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)

# 上图布局不平衡，下面试图将第三个图放在正中间

# 先设定边缘间距：外边框 行数，留给顶端标题，四边
par(oma=c(0, 0, 1, 0), mar=c(2, 3, 3, 2)) 

# 重新做上面三个图、修改了一些特征，如点的颜色改灰
# 左上图
par(fig=c(0, .5, .5, 1))
# 数字表示比例，横向放在0-0.5。纵向放在0.5-1
# par(fig=c(x1, x2, y1, y2))

x <- seq(0, 1, length=200)
Ey <- rev(1 - x^2)
y <- Ey + 0.1*rnorm(200)
plot(x, y, axes=FALSE, frame=TRUE, main="(a) monotone, simple", 
     cex.main=1, xlab="", ylab="", col="gray", cex=0.75)
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)

# 右上图 
par(fig=c(.5, 1, .5, 1)) # top-right panel
par(new=TRUE)  # 在原图中开一个新窗口
x <- seq(0.02, 0.99, length=200)
Ey <- log(x/(1 - x))
y <- Ey + 0.5*rnorm(200)
plot (x, y, axes=FALSE, frame=TRUE, main="(b) monotone, not simple", 
      cex.main=1, xlab="", ylab="", col="gray", cex=0.75)
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)

# 下方图
par(fig=c(.25, .75, 0, .5)) # bottom panel
par(new=TRUE)
x <- seq(0.2, 1, length=200)
Ey <- (x - 0.5)^2
y <- Ey + 0.04*rnorm(200)
plot(x, y, axes=FALSE, frame=TRUE, main="(c) non-monotone, simple", 
     cex.main=1, xlab="", ylab="", col="gray", cex=0.75)
lines(x, Ey, lwd=2)
mtext("x", side=1, adj=1)
mtext("y ", side=2, at=max(y), las=1)
title("Nonlinear Relationships", outer=TRUE) # 标题

# clean up
remove(list=objects())  
par(mfrow=c(1, 1))
par(mar = c(5, 6, 4, 2) + 0.1)

###################################################
# 通过叠加元素形成一个复杂的图
# 生成两个向量
cars <- c(1, 3, 6, 4, 9)
trucks <- c(2, 5, 4, 5, 12)
# 取得取值范围
g_range <- range(0, cars, trucks)

#作图，抑制坐标轴和标题
plot(cars, type="o", col="blue", ylim=g_range, 
     axes=FALSE, ann=FALSE)

# 定义x标签（1，2，3，4下左上右）
axis(1, at=1:5, lab=c("Mon","Tue","Wed","Thu","Fri"))

# 定义Y标签
axis(2, las=1, at=4*0:g_range[2])

# Create box around plot
box()

# Graph trucks with red dashed line and square points
lines(trucks, type="o", pch=22, lty=2, col="red")

grid(nx=NA,ny=NULL,lwd=2)

#  主标题 red, bold/italic font
title(main="Autos", col.main="red", font.main=4)

# Label the x and y axes with dark green text
title(xlab="Days", col.lab=rgb(0,0.5,0))
title(ylab="Total", col.lab=rgb(0,0.5,0))

# 图例设定 
legend(1, g_range[2], c("cars","trucks"), cex=0.8, 
       col=c("blue","red"), pch=21:22, lty=1:2)

###################################################
#lattice包
library(lattice)
num<-sample(1:3,size=50,replace=T)
barchart(table(num))
qqmath(rnorm(100))
#单维散点
stripplot(~Sepal.Length | Species,data=iris,layout=c(1,3)) # |表示条件
#密度
densityplot(~ Sepal.Length,groups=Species,data=iris,plot.points=FALSE)
#箱子图
bwplot(Species~ Sepal.Length, data = iris)
#散点图
xyplot(Sepal.Width~Sepal.Length,groups=Species,data=iris)
#矩阵散点
splom(iris[1:4])  # 矩阵散点图
#分面直方图
histogram(~Sepal.Length | Species,data=iris,layout(c(1,3)))


###################################################
##其他作图包
##REmap – 动态地图
#bigvis – 大数据集的可视化
#ggsci – 为ggplot2提供科技期刊所用的绘图风格
#rCharts – 生成动态交互图

# Scatterplot Matrix
install.packages('GGally')
library(GGally)
ggpairs(UScereal[, c(2, 8, 9, 11)],
        upper = list(continuous = 'smooth', combo = 'facetdensity', discrete = 'blank') ,
        lower = list(continuous = 'cor', combo = 'box'))

# Maps
# http://bcb.dfci.harvard.edu/~aedin/courses/R/CDC/maps.html
# http://rstudio.github.io/leaflet/
# maps, choroplethr, 

#玫瑰图
set.seed(1)
#随机生成100次风向，并汇集到16个区间内
dir <- cut_interval(runif(100,0,360),n=16)
#随机生成100次风速，并划分成4种强度
mag <- cut_interval(rgamma(100,15),4) 
sample <- data.frame(dir=dir,mag=mag)
#将风向映射到X轴，频数映射到Y轴，风速大小映射到填充色，生成条形图后再转为极坐标形式即可
p <- ggplot(sample,aes(x=dir,fill=mag))+
  geom_bar()+ coord_polar()

#马赛克图（用矩形面积表示份量）	  
library(vcd)
mosaic(Survived~ Class+Sex, data = Titanic,shade=T, 
       highlighting_fill=c('red4',"skyblue"),
       highlighting_direction = "right")

## 层次树图
library(treemap)
data <- read.csv('data/apple.csv',T)
treemap(data,
        index=c("item", "subitem"),
        vSize="time1206",
        vColor="time1106",
        type="comp",
        title='苹果公司财务报表可视化',
        palette='RdBu')


library(maps)
data(us.cities) 
big_cities <- subset(us.cities,long> -130)
ggplot(big_cities,aes(long,lat))+borders("state",size=0.5,colour="grey70")+geom_point(colour="black",alpha=0.5,aes(size = pop)) 

p <-ggplot(us.cities,aes(long,lat))+
  borders("state",colour="grey70")
p+geom_point(aes(long,lat,size=pop),data=us.cities,colour="black",alpha=0.5)
