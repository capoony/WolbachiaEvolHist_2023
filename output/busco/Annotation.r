

library(tidyverse)

DATA=read.table("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/results/Annotation/Summary.txt",
  header=T)

DATA.wide <- DATA %>% 
  spread(ID,Type)

write.table(file="/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.txt",
  DATA.wide,
  quote=F,
  row.names=F)


PLOT=ggplot(DATA,aes(group=Gene))+
  geom_rect(aes(xmin = Start, xmax = End, ymin = 0, ymax = 1,fill=Type))+
  facet_grid(ID~.)+
    theme_bw()+
  scale_fill_manual(values=c("blue","orange","red","grey","purple"))+
   theme(
        axis.text.y=element_blank(),  #remove y axis labels
        axis.ticks.y=element_blank()  #remove y axis ticks
        )+
  theme(strip.text.y.right = element_text(angle = 0))+ 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
  scale_x_continuous(breaks=seq(0, 1300000, 250000))


ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.pdf",
  PLOT,
  width=10,
  height=4)

ggsave("/media/inter/mkapun/projects/WolbachiaEvolHist_2023/output/busco/Annotation.png",
  PLOT,
  width=10,
  height=4)


