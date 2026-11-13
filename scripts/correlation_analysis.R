###############################################
##        BIVARIATE ANALYSIS: loss vs factors ##
###############################################
# Input : results/learning_loss_clean.csv  (separatore ';', decimale '.')
# Output: results/plots/scatter_*.png, scatter_panel.png
#         results/correlation_matrix_pearson.csv, correlation_pvalues.csv
#         results/correlation_summary.csv

library(ggplot2)   # install.packages("ggplot2")

setwd('C:/Users/sntis/Documents/Projects/Uni/AY 26-27/Statistics/Project') #Change this to your working directory
dir.create('results/plots', showWarnings = FALSE, recursive = TRUE)
options(scipen = 999)

# NB: il file e' scritto con sep = ';' e dec = '.', quindi NON usare read.csv2()
ll <- read.table('results/learning_loss_clean.csv', header = TRUE, sep = ';',
                 dec = '.', quote = '"', na.strings = c('', 'NA'))
rownames(ll) <- ll$country

#used logpop since it provides more coherent results

resp_var  <- 'loss'
core_vars <- c('weeks', 'deaths', 'loggdp', 'private', 'internet', 'hlo', 'vac',
               'stringency', 'union', 'polity', 'pop', 'schooling')  #instead of gdp, loggdp was used since there relationship were more coherent.

###############################################
# 1. SCATTER PLOT: loss vs ciascuna core variable
###############################################
# Retta di regressione (rossa) + curva loess (grigia tratteggiata) per giudicare
# se la relazione e' lineare. Titolo con r di Pearson.

scatter_one <- function(v) {
  r <- cor(ll[[resp_var]], ll[[v]], use = 'complete.obs')
  ggplot(ll, aes(x = .data[[v]], y = .data[[resp_var]])) +
    geom_point(colour = '#2b6c8f', size = 2, alpha = 0.8) +
    geom_smooth(method = 'lm',    se = TRUE, colour = '#c0392b', linewidth = 0.9) +
    geom_smooth(method = 'loess', se = FALSE, colour = 'grey35', linetype = 'dashed',
                linewidth = 0.8, span = 0.9, formula = y ~ x) +
    labs(title = sprintf('loss vs %s  (r = %.2f)', v, r), x = v, y = 'loss') +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 11))
}

for (v in core_vars) {
  ggsave(sprintf('results/plots/scatter_loss_%s.png', v), scatter_one(v),
         width = 6, height = 4.5, dpi = 300)
}

# Pannello unico 4 x 3 (base R, nessun pacchetto aggiuntivo)
png('results/plots/scatter_panel.png', width = 14, height = 16, units = 'in', res = 200)
par(mfrow = c(4, 3), mar = c(4, 4, 3, 1))
for (v in core_vars) {
  x <- ll[[v]]; y <- ll[[resp_var]]
  plot(x, y, pch = 16, col = '#2b6c8f', xlab = v, ylab = 'loss',
       main = sprintf('loss vs %s  (r = %.2f)', v, cor(x, y)))
  abline(lm(y ~ x), col = '#c0392b', lwd = 2)
  lines(lowess(x, y, f = 0.8), col = 'grey35', lty = 2, lwd = 1.5)
}
dev.off()
par(mfrow = c(1, 1))

###############################################
# 2. CORRELAZIONE DI PEARSON PER OGNI COPPIA
###############################################
vars <- c(resp_var, core_vars)
cor_mat <- cor(ll[vars], method = 'pearson', use = 'pairwise.complete.obs')
p_mat   <- matrix(NA, length(vars), length(vars), dimnames = list(vars, vars))
for (a in vars) for (b in vars)
  p_mat[a, b] <- if (a == b) 0 else cor.test(ll[[a]], ll[[b]])$p.value

print(round(cor_mat, 3))
write.table(round(cor_mat, 3), 'results/correlation_matrix_pearson.csv', sep = ';')
write.table(round(p_mat, 4),   'results/correlation_pvalues.csv',        sep = ';')

###############################################
# 3. TABELLA: direzione, intensita', natura
###############################################
direction <- function(r) ifelse(abs(r) < 0.15, 'assente / trascurabile',
                         ifelse(r > 0, 'positiva', 'negativa'))
strength  <- function(r) {
  a <- abs(r)
  ifelse(a < 0.2, 'molto debole',
  ifelse(a < 0.4, 'debole',
  ifelse(a < 0.6, 'moderata',
  ifelse(a < 0.8, 'forte', 'molto forte'))))
}

r_vec <- sapply(core_vars, function(v) cor(ll$loss, ll[[v]]))
p_vec <- sapply(core_vars, function(v) cor.test(ll$loss, ll[[v]])$p.value)
s_vec <- sapply(core_vars, function(v) cor(ll$loss, ll[[v]], method = 'spearman'))

# Valutazione della natura della relazione (da scatter plot + loess + Spearman)
nature <- c(
  weeks      = 'Lineare (lieve concavita per valori alti; India influente)',
  deaths     = 'Nessuna relazione evidente',
  loggdp        = 'Non lineare: decrescente e poi piatta (migliora con log(gdp))',
  private    = 'Nessuna relazione evidente',
  internet   = 'Approssimativamente lineare, con dispersione',
  hlo        = 'Lineare debole, molto dispersa',
  vac        = 'Lineare debole, molto dispersa',
  stringency = 'Nessuna relazione evidente / molto debole',
  union      = 'Nessuna relazione lineare; dispersione eterogenea',
  polity     = 'Non lineare / poco informativa (valori ammassati a 10)',
  logpop        = 'Nessuna relazione; dominata da Cina e India (outlier)',
  schooling  = 'Lineare'
)

summary_tab <- data.frame(
  variable  = core_vars,
  r_pearson = round(r_vec, 3),
  p_value   = round(p_vec, 4),
  direction = direction(r_vec),
  strength  = strength(r_vec),
  spearman  = round(s_vec, 3),
  nature    = nature[core_vars],
  row.names = NULL
)
print(summary_tab)
write.table(summary_tab, 'results/correlation_summary.csv', sep = ';', row.names = FALSE)
