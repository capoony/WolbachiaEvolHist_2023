
# load necessary R libraries
library("ggtree")
library("gridExtra")
library("ggrepel")
library("ape")
library("ggplot2")
library("phangorn")
library("dplyr")
library("tidyverse")
library(phytools) # to determine the maximum tree height and add midpoint root

args <- commandArgs(trailingOnly = TRUE)

input <- args[1]
output <- args[2]
title <- args[3]
offset <- as.numeric(args[4])
outgroup <- args[5]

## load tree file and root midpoint
tree <- read.tree(input)
if (outgroup == "NO") {
  tree <- midpoint.root(tree)
} else {
  tree <- root(tree, outgroup = unlist(str_split(outgroup, ",")))
}
## caluculate tree height (on x-axis)
Xmax <- max(nodeHeights(tree))

## only retain Bootstrapping Support > 75%
tree$node.label[as.numeric(tree$node.label) < 75] <- NA

## plot tree
PLOT.tree <- ggtree(tree,
  layout = "roundrect"
) +
  ggtitle(title) +
  theme_tree2() +
  theme_bw() +
  ggplot2::xlim(
    0,
    Xmax + offset
  ) +
  xlab("av. subst./site") +
  geom_nodelab(
    hjust = 1.25,
    vjust = -0.75,
    size = 3,
    color = "blue"
  ) +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  geom_tiplab()

PNG <- paste0(output, ".png")
PDF <- paste0(output, ".pdf")
## export tree
ggsave(
  filename = PDF,
  PLOT.tree
)
ggsave(
  filename = PNG,
  PLOT.tree
)
