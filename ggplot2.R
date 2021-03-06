library(ggplot2)
library(grid)
library(dplyr)
movie <- read.csv("movie.csv")

# Q1 - Does higher rating movie also have a higher adjusted gross revenue?
# method - log-transform
# data cleaning
movie_1 <- movie
movie_1$Adjusted_Gross2 <- log10(as.numeric(gsub(",","",movie_1$Adjusted_Gross)))
movie_1$MovieLens_Rating2 <- movie_1$MovieLens_Rating*2 # adjust MovieLens Rating to the same scale as IMDb's
# Compute correlation coefficient
correlation_coef_IMDb <- round(cor(as.numeric(movie_1$IMDb_Rating), movie_1$Adjusted_Gross2),3) # correlation coefficient of IMDb_Rating
correlation_coef_MovieLens <- round(cor(as.numeric(movie_1$MovieLens_Rating), movie_1$Adjusted_Gross2),3) # correlation coefficient of MovieLens_Rating
correlation_coef_I <- paste("Correlation Coefficient(IMDb) =", correlation_coef_IMDb)
correlation_coef_M <- paste("Correlation Coefficient(MovieLens) =", correlation_coef_MovieLens)
# graph
grob_IMDb <- grobTree(textGrob(correlation_coef_I, x=0.05,  y=0.90, hjust=0,
                               gp=gpar(col="#CC79A7", fontsize=12, fontface="italic")))
grob_MovieLens <- grobTree(textGrob(correlation_coef_M, x=0.05,  y=0.85, hjust=0,
                                    gp=gpar(col="#56B4E9", fontsize=12, fontface="italic")))
ggplot(movie_1, aes(y=Adjusted_Gross2))+
  geom_point(color="#CC79A7", aes(x=as.numeric(IMDb_Rating), shape="IMDb"))+
  geom_smooth(se=FALSE, method=lm, color="#CC79A7", aes(x=as.numeric(IMDb_Rating)))+
  geom_point(aes(x=as.numeric(MovieLens_Rating2), shape="MovieLens"), color="#56B4E9")+
  geom_smooth(aes(x=as.numeric(MovieLens_Rating2)), se=FALSE, method=lm, color="#56B4E9")+
  guides(shape=guide_legend("Rating Type", override.aes = list(color=c("#CC79A7", "#56B4E9"))))+
  scale_x_continuous(breaks = c(1:10))+
  labs(x="Rating", y="Adjusted Gross Revenue (log transformed)")+
  ggtitle("Adj. Gross Revenue VS. Rating")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  annotation_custom(grob_IMDb)+
  annotation_custom(grob_MovieLens)

# distribution based on genre
# data cleaning
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie_1 <- movieG
movie_1$Adjusted_Gross2 <- log10(as.numeric(gsub(",","",movie_1$Adjusted_Gross)))
movie_1$MovieLens_Rating2 <- movie_1$MovieLens_Rating*2 # adjust MovieLens Rating to the same scale as IMDb's
# graph
ggplot(movie_1, aes(y=Adjusted_Gross2))+
  geom_point(color="#CC79A7", aes(x=as.numeric(IMDb_Rating), shape="IMDb"))+
  geom_smooth(se=FALSE, method=lm, color="#CC79A7", aes(x=as.numeric(IMDb_Rating)))+
  geom_point(aes(x=as.numeric(MovieLens_Rating2), shape="MovieLens"), color="#56B4E9")+
  geom_smooth(aes(x=as.numeric(MovieLens_Rating2)), se=FALSE, method=lm, color="#56B4E9")+
  facet_wrap( ~ Genre)+
  guides(shape=guide_legend("Rating Type", override.aes = list(color=c("#CC79A7", "#56B4E9"))))+
  scale_x_continuous(breaks = c(1:10))+
  labs(x="Rating", y="Adjusted Gross Revenue (log transformed)")+
  ggtitle("Adj. Gross Revenue VS. Rating")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))
# Compute correlation coefficient
genre_cor <- cbind(as.data.frame(movie_1 %>% group_by(Genre) %>% summarize(IMDb_Cor.Coef = round(cor(IMDb_Rating, Adjusted_Gross2),3))),
                   as.data.frame(movie_1 %>% group_by(Genre) %>% summarize(MovieLens_Cor.Coef = round(cor(MovieLens_Rating, Adjusted_Gross2),3))))[,-3]
genre_cor <- cbind(genre_cor, mean_Cor.Coef = (genre_cor$IMDb_Cor.Coef+genre_cor$MovieLens_Cor.Coef)/2)
genre_cor <- genre_cor[order(genre_cor$mean_Cor.Coef, decreasing = TRUE),]



# Q2 - Shall we make a short movie or a long movie?
# method - log-transform
# Profit VS. Runtime_min
# data cleaning
movie_2 <- movie
movie_2$Profit2 <- log10(as.numeric(gsub(",","",movie_2$Profit)))
# Compute correlation coefficient
correlation_coef_Profit <- round(cor(movie_2$Runtime_min, movie_2$Profit2),3)
correlation_coef_P <- paste("Correlation Coefficient =", correlation_coef_Profit)
# graph
grob <- grobTree(textGrob(correlation_coef_P, x=0.05,  y=0.90, hjust=0,
                          gp=gpar(col="black", fontsize=12, fontface="italic")))
ggplot(movie_2, aes(x=Runtime_min, y=Profit2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  labs(x="Movie Run Time(min)", y="Profit (log transformed)")+
  ggtitle("Profit VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  annotation_custom(grob)

# Adj. Gross Revenue VS. Runtime_min
# data cleaning
movie_2_Revenue <- movie
movie_2_Revenue$Adjusted_Gross2 <- log10(as.numeric(gsub(",","",movie_2_Revenue$Adjusted_Gross)))
# Compute correlation coefficient
correlation_coef_Revenue <- round(cor(movie_2_Revenue$Runtime_min, movie_2_Revenue$Adjusted_Gross2),3)
correlation_coef_R <- paste("Correlation Coefficient =", correlation_coef_Revenue)
# graph
grob <- grobTree(textGrob(correlation_coef_R, x=0.05,  y=0.90, hjust=0,
                          gp=gpar(col="black", fontsize=12, fontface="italic")))
ggplot(movie_2_Revenue, aes(x=Runtime_min, y=Adjusted_Gross2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  labs(x="Movie Run Time(min)", y="Adjusted Gross Revenue (log transformed)")+
  ggtitle("Adjusted Gross Revenue VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  annotation_custom(grob)

# Budget VS. Runtime_min
# data cleaning
movie_2_Budget <- movie
movie_2_Budget$Budget2 <- log10(as.numeric(gsub(",","",movie_2_Budget$Budget)))
# Compute correlation coefficient
correlation_coef_Budget <- round(cor(movie_2_Budget$Runtime_min, movie_2_Budget$Budget2),3)
correlation_coef_B <- paste("Correlation Coefficient =", correlation_coef_Budget)
# graph
grob <- grobTree(textGrob(correlation_coef_B, x=0.05,  y=0.90, hjust=0,
                          gp=gpar(col="black", fontsize=12, fontface="italic")))
ggplot(movie_2_Budget, aes(x=Runtime_min, y=Budget2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  labs(x="Movie Run Time(min)", y="Budget (log transformed)")+
  ggtitle("Budget VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  annotation_custom(grob)

# boxplot
# Profit VS. Runtime_min
# data cleaning
movie_2 <- movie
movie_2$Profit2 <- log10(as.numeric(gsub(",","",movie_2$Profit)))
movie_2$Quantile <- "none"
quan_25 <- round(quantile(movie_2$Runtime_min, 0.25))
quan_50 <- round(quantile(movie_2$Runtime_min, 0.50))
quan_75 <- round(quantile(movie_2$Runtime_min, 0.75))
quan_100 <- quantile(movie_2$Runtime_min, 1)
movie_2$Quantile[movie_2$Runtime_min<=quan_25] <- paste0("0-",quan_25)
movie_2$Quantile[movie_2$Runtime_min<=quan_50 & movie_2$Runtime_min>quan_25] <- paste0(quan_25,"-",quan_50)
movie_2$Quantile[movie_2$Runtime_min<=quan_75 & movie_2$Runtime_min>quan_50] <- paste0(quan_50,"-",quan_75)
movie_2$Quantile[movie_2$Runtime_min>quan_75] <- paste0(quan_75,"-",quan_100)
ggplot(movie_2, aes(x=Quantile, y=Profit2))+
  geom_boxplot()+
  labs(x="Movie Run Time(min)", y="Profit (log transformed)")+
  ggtitle("Profit VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))

# distribution based on genre (log-transformed)
# Profit VS. Runtime_min
# data cleaning
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie_2 <- movieG
movie_2$Profit2 <- log10(as.numeric(gsub(",","",movie_2$Profit)))
# graph
ggplot(movie_2, aes(x=Runtime_min, y=Profit2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  facet_wrap( ~ Genre)+
  labs(x="Movie Run Time(min)", y="Profit (log transformed)")+
  ggtitle("Profit VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))
# Compute correlation coefficient
genre_cor <- as.data.frame(movie_2 %>% group_by(Genre) %>% summarize(Cor.Coef = round(cor(Runtime_min, Profit2),3)))
genre_cor <- genre_cor[order(genre_cor$Cor.Coef, decreasing = TRUE),]

# boxplot
# Profit VS. Runtime_min
# data cleaning
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie_2 <- movieG
movie_2$Profit2 <- log10(as.numeric(gsub(",","",movie_2$Profit)))
movie_2$Quantile <- "none"
quan_25 <- round(quantile(movie_2$Runtime_min, 0.25))
quan_50 <- round(quantile(movie_2$Runtime_min, 0.50))
quan_75 <- round(quantile(movie_2$Runtime_min, 0.75))
quan_100 <- quantile(movie_2$Runtime_min, 1)
movie_2$Quantile[movie_2$Runtime_min<=quan_25] <- paste0("0-",quan_25)
movie_2$Quantile[movie_2$Runtime_min<=quan_50 & movie_2$Runtime_min>quan_25] <- paste0(quan_25,"-",quan_50)
movie_2$Quantile[movie_2$Runtime_min<=quan_75 & movie_2$Runtime_min>quan_50] <- paste0(quan_50,"-",quan_75)
movie_2$Quantile[movie_2$Runtime_min>quan_75] <- paste0(quan_75,"-",quan_100)
ggplot(movie_2, aes(x=Quantile, y=Profit2))+
  geom_boxplot()+
  facet_wrap( ~ Genre)+
  labs(x="Movie Run Time(min)", y="Profit (log transformed)")+
  ggtitle("Profit VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))

# boxplot2
# Profit Percentage VS. Runtime_min
# data cleaning
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie_2 <- movieG
movie_2$Profit_perc2 <- log10(as.numeric(gsub(",","",movie_2$Profit_perc)))
movie_2$Quantile <- "none"
quan_25 <- round(quantile(movie_2$Runtime_min, 0.25))
quan_50 <- round(quantile(movie_2$Runtime_min, 0.50))
quan_75 <- round(quantile(movie_2$Runtime_min, 0.75))
quan_100 <- quantile(movie_2$Runtime_min, 1)
movie_2$Quantile[movie_2$Runtime_min<=quan_25] <- paste0("0-",quan_25)
movie_2$Quantile[movie_2$Runtime_min<=quan_50 & movie_2$Runtime_min>quan_25] <- paste0(quan_25,"-",quan_50)
movie_2$Quantile[movie_2$Runtime_min<=quan_75 & movie_2$Runtime_min>quan_50] <- paste0(quan_50,"-",quan_75)
movie_2$Quantile[movie_2$Runtime_min>quan_75] <- paste0(quan_75,"-",quan_100)
ggplot(movie_2, aes(x=Quantile, y=Profit_perc2))+
  geom_boxplot()+
  facet_wrap( ~ Genre)+
  labs(x="Movie Run Time(min)", y="Profit Percentage (log transformed)")+
  ggtitle("Profit Percentage VS. Movie Run Time")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))



# Q3 - If a movie does well in US, does it also usually do well overseas?
# method - log-transform
# data cleaning
movie_3 <- movie
movie_3$US_rev2 <- as.numeric(gsub(",","",movie_3$US_rev))
movie_3$Overseas_rev2 <- log10(as.numeric(gsub(",","",movie_3$Overseas_rev)))
# Compute correlation coefficient
correlation_coef_Compare <- round(cor(movie_3$US_rev2, movie_3$Overseas_rev2),3)
correlation_coef_C <- paste("Correlation Coefficient =", correlation_coef_Compare)
# graph
grob <- grobTree(textGrob(correlation_coef_C, x=0.05,  y=0.90, hjust=0,
                          gp=gpar(col="black", fontsize=12, fontface="italic")))
ggplot(movie_3, aes(x=US_rev2, y=Overseas_rev2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  labs(x="US Revenue", y="Overseas Revenue (log transformed)")+
  ggtitle("Overseas Revenue VS. US Revenue")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  annotation_custom(grob)

# distribution based on genre (log-transformed)
# data cleaning
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie_3 <- movieG
movie_3$US_rev2 <- as.numeric(gsub(",","",movie_3$US_rev))
movie_3$Overseas_rev2 <- log10(as.numeric(gsub(",","",movie_3$Overseas_rev)))
# graph
ggplot(movie_3, aes(x=US_rev2, y=Overseas_rev2))+
  geom_point(alpha=0.5)+
  geom_smooth(se=FALSE, color="#56B4E9", method=lm)+
  facet_wrap( ~ Genre)+
  labs(x="US Revenue", y="Overseas Revenue (log transformed)")+
  ggtitle("Overseas Revenue VS. US Revenue")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))
# Compute correlation coefficient
genre_cor <- as.data.frame(movie_3 %>% group_by(Genre) %>% summarize(Cor.Coef = round(cor(US_rev2, Overseas_rev2),3)))
genre_cor <- genre_cor[order(genre_cor$Cor.Coef, decreasing = TRUE),]



# Q4 - recommendation
# Profit VS. Budget 
movie4 <- movie
movie4$Profit2 <- log10(as.numeric(gsub(",","",movie4$Profit)))
movie4$Budget2 <- log10(as.numeric(gsub(",","",movie4$Budget)))
ggplot(movie4, aes(x=Budget2, y=Profit2))+
  geom_point(alpha=0.5)+
  labs(x="Budget (log transformed)", y="Profit (log transformed)")+
  xlim(0.5,2.5)+
  ggtitle("Profit VS. Budget")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))

# Genres
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie4 <- movieG
movie4$Profit2 <- log10(as.numeric(gsub(",","",movie4$Profit)))
movie4$Profit_perc2 <- log10(as.numeric(gsub(",","",movie4$Profit_perc)))
# aggregate genre
Profit_G <- aggregate(Profit2~Genre, movie4, mean)
ProfitPerc_G <- aggregate(Profit_perc2~Genre, movie4, mean)
Genre_compare <- cbind(Profit_G,ProfitPerc_G)[,-3]
# graph
ggplot(Genre_compare, aes(x=Profit2, y=Profit_perc2, color=Genre))+
  geom_point(size=6)+
  xlim(2.3,2.6)+
  ylim(2.4,2.9)+
  labs(x="Avg. Profit (log transformed)", y="Avg. Profit Percentage (log transformed)")+
  ggtitle("Avg. Profit Percentage VS. Avg. Profit on Genres")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  geom_text(label = Genre_compare$Genre, vjust=-1, size=5)+
  guides(color=guide_legend("none"))

# Studio
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie4 <- movieG
movie4$Profit2 <- log10(as.numeric(gsub(",","",movie4$Profit)))
movie4$Profit_perc2 <- log10(as.numeric(gsub(",","",movie4$Profit_perc)))
# aggregate genre
Profit_S <- aggregate(Profit2~Studio, movie4, mean)
ProfitPerc_S <- aggregate(Profit_perc2~Studio, movie4, mean)
Studio_compare <- cbind(Profit_S,ProfitPerc_S)[,-3]
# graph
ggplot(Studio_compare, aes(x=Profit2, y=Profit_perc2, color=Studio))+
  geom_point()+
  labs(x="Avg. Profit (log transformed)", y="Avg. Profit Percentage (log transformed)")+
  ggtitle("Avg. Profit Percentage VS. Avg. Profit on Studios")+
  xlim(2.1,2.9)+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  geom_text(label = Studio_compare$Studio, vjust=-0.5)+
  guides(color=guide_legend("none"))

# Director
# select genre with number of datapoint >= 15
Freq_genre <- as.data.frame(sort(table(movie$Genre),decreasing=TRUE))
selected_genre <- as.character(Freq_genre[Freq_genre$Freq>=15,1])
movieG <- movie[movie$Genre %in% selected_genre,]
movie4 <- movieG
movie4$Profit2 <- log10(as.numeric(gsub(",","",movie4$Profit)))
movie4$Profit_perc2 <- log10(as.numeric(gsub(",","",movie4$Profit_perc)))
# aggregate genre
Profit_D <- aggregate(Profit2~Director, movie4, mean)
ProfitPerc_D <- aggregate(Profit_perc2~Director, movie4, mean)
Director_compare <- cbind(Profit_D,ProfitPerc_D)[,-3]
# graph
ggplot(Director_compare, aes(x=Profit2, y=Profit_perc2, color=Director))+
  geom_point()+
  labs(x="Avg. Profit (log transformed)", y="Avg. Profit Percentage (log transformed)")+
  ggtitle("Avg. Profit Percentage VS. Avg. Profit on Directors")+
  theme(plot.title = element_text(hjust=0.5, face="bold"))+
  geom_text(label = Director_compare$Director, vjust=-0.5, size=3)+
  guides(color=guide_legend("none"))

