install.packages(c("patchwork"))

library(patchwork)

getCaption <- function() {
  caption <- "https://saylibenadikar.github.io/snoot-scoop | Source: https://www.nacsw.net/trial-results"
}

getAnnotationTheme <- function() {
  theme = theme(
    plot.title = element_text(size = 16),
    plot.subtitle = element_text(size = 12),
    plot.caption = element_text(size = 10),
  )
}

getAnnotatedPlot <- function(plot, title, subtitle) {
  annotated_plot <- plot + 
    plot_annotation(
      title = title,
      subtitle = subtitle, 
      caption = getCaption(),
      theme = getAnnotationTheme()
    ) &
    theme(text = element_text("mono"))	
}