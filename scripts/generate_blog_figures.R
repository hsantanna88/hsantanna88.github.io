# =============================================================
# Generate all blog post figures — Eye Candy Edition
# Hugo Sant'Anna | hsantanna.org
# Palette: charcoal #2d2d2d, teal #2a9d8f, dark teal #1a3a36
# =============================================================

library(tidyverse)
library(ggdag)
library(AER)

img_dir <- "assets/images"

# --- Shared premium theme ---
theme_blog <- function(base_size = 14) {
  theme_minimal(base_size = base_size) +
    theme(
      text = element_text(family = "sans"),
      plot.title = element_text(face = "bold", color = "#2d2d2d", size = rel(1.15),
                                margin = margin(b = 4)),
      plot.subtitle = element_text(color = "#888888", size = rel(0.82),
                                   margin = margin(b = 12)),
      plot.caption = element_text(color = "#aaaaaa", size = rel(0.7),
                                  hjust = 1, margin = margin(t = 10)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#f0f0f0", linewidth = 0.3),
      axis.title = element_text(color = "#555555", size = rel(0.9)),
      axis.text = element_text(color = "#777777"),
      axis.line = element_line(color = "#cccccc", linewidth = 0.3),
      legend.title = element_text(face = "bold", size = rel(0.8)),
      legend.text = element_text(size = rel(0.75)),
      plot.margin = margin(20, 20, 15, 15),
      plot.background = element_rect(fill = "white", color = NA)
    )
}

# =============================================================
# FIGURE 1: EM Algorithm — Log Wage Histogram
# =============================================================
cat("Generating EM figures...\n")

set.seed(123)
n <- 10000
true_means <- c(2, 3)
true_sds <- c(0.5, 0.5)
true_weights <- c(0.6, 0.4)

lmarket <- tibble(
  worker_id = 1:n,
  type = c(rep(1, n * true_weights[1]), rep(2, n * true_weights[2])),
  log_wage = c(
    rnorm(n * true_weights[1], true_means[1], true_sds[1]),
    rnorm(n * true_weights[2], true_means[2], true_sds[2])
  )
) |>
  mutate(log_wage = log_wage - min(log_wage) + 1)

# Histogram with density overlay and rug
p_hist <- ggplot(lmarket, aes(x = log_wage)) +
  geom_histogram(aes(y = after_stat(density)), bins = 70,
                 fill = "#2d2d2d", alpha = 0.75, color = "white", linewidth = 0.15) +
  geom_density(color = "#2a9d8f", linewidth = 1, alpha = 0) +
  geom_rug(alpha = 0.015, color = "#2a9d8f", length = unit(0.03, "npc")) +
  annotate("segment", x = 2.63, xend = 2.63, y = 0, yend = 0.65,
           linetype = "dotted", color = "#2a9d8f", linewidth = 0.6, alpha = 0.7) +
  annotate("segment", x = 3.62, xend = 3.62, y = 0, yend = 0.55,
           linetype = "dotted", color = "#2a9d8f", linewidth = 0.6, alpha = 0.7) +
  annotate("label", x = 2.63, y = 0.68, label = "Low type?",
           color = "#2a9d8f", fontface = "italic", size = 3.5,
           fill = alpha("white", 0.85), label.border = NA, label.padding = unit(0.2, "lines")) +
  annotate("label", x = 3.62, y = 0.58, label = "High type?",
           color = "#2a9d8f", fontface = "italic", size = 3.5,
           fill = alpha("white", 0.85), label.border = NA, label.padding = unit(0.2, "lines")) +
  labs(
    x = "Log Wage",
    y = "Density",
    title = "Distribution of Log Wages",
    subtitle = "10,000 workers \u2014 can you see the hidden mixture components?",
    caption = "hsantanna.org"
  ) +
  theme_blog()

ggsave(file.path(img_dir, "hist_logwage.png"), p_hist,
       width = 9, height = 5.5, dpi = 250, bg = "white")
cat("  -> hist_logwage.png\n")

# --- Run EM to get parameters ---
initial_guess <- kmeans(lmarket$log_wage, centers = 2, nstart = 25)$cluster
mu1 <- mean(lmarket$log_wage[initial_guess == 1])
mu2 <- mean(lmarket$log_wage[initial_guess == 2])
sigma1 <- sd(lmarket$log_wage[initial_guess == 1])
sigma2 <- sd(lmarket$log_wage[initial_guess == 2])
pi1 <- mean(initial_guess == 1)
pi2 <- mean(initial_guess == 2)

sum_finite <- function(x) sum(x[is.finite(x)])

L <- c(-Inf, sum(log(pi1 * dnorm(lmarket$log_wage, mu1, sigma1) +
                      pi2 * dnorm(lmarket$log_wage, mu2, sigma2))))

current_iter <- 2
max_iter <- 500
while (abs(L[current_iter] - L[current_iter - 1]) >= 1e-8 && current_iter < max_iter) {
  # E step
  comp1 <- pi1 * dnorm(lmarket$log_wage, mu1, sigma1)
  comp2 <- pi2 * dnorm(lmarket$log_wage, mu2, sigma2)
  comp_sum <- comp1 + comp2
  p1 <- comp1 / comp_sum
  p2 <- comp2 / comp_sum
  # M step
  pi1 <- sum_finite(p1) / length(lmarket$log_wage)
  pi2 <- sum_finite(p2) / length(lmarket$log_wage)
  mu1 <- sum_finite(p1 * lmarket$log_wage) / sum_finite(p1)
  mu2 <- sum_finite(p2 * lmarket$log_wage) / sum_finite(p2)
  sigma1 <- sqrt(sum_finite(p1 * (lmarket$log_wage - mu1)^2) / sum_finite(p1))
  sigma2 <- sqrt(sum_finite(p2 * (lmarket$log_wage - mu2)^2) / sum_finite(p2))
  # Recompute log-likelihood with UPDATED parameters
  current_iter <- current_iter + 1
  L[current_iter] <- sum(log(pi1 * dnorm(lmarket$log_wage, mu1, sigma1) +
                              pi2 * dnorm(lmarket$log_wage, mu2, sigma2)))
}

# Reorder so component 1 is the lower mean
if (mu1 > mu2) {
  tmp <- mu1; mu1 <- mu2; mu2 <- tmp
  tmp <- sigma1; sigma1 <- sigma2; sigma2 <- tmp
  tmp <- pi1; pi1 <- pi2; pi2 <- tmp
}

# Build filled density data for smooth area fills
x_seq <- seq(min(lmarket$log_wage) - 0.5, max(lmarket$log_wage) + 0.5, length.out = 500)
density_df <- tibble(
  x = rep(x_seq, 3),
  y = c(
    pi1 * dnorm(x_seq, mu1, sigma1),
    pi2 * dnorm(x_seq, mu2, sigma2),
    pi1 * dnorm(x_seq, mu1, sigma1) + pi2 * dnorm(x_seq, mu2, sigma2)
  ),
  component = rep(c("Low Type (\u03c0\u2081)", "High Type (\u03c0\u2082)", "Mixture"), each = length(x_seq))
) |>
  mutate(component = factor(component, levels = c("Low Type (\u03c0\u2081)", "High Type (\u03c0\u2082)", "Mixture")))

p_em_overlay <- ggplot(lmarket, aes(x = log_wage)) +
  geom_histogram(aes(y = after_stat(density)), bins = 70,
                 fill = "#e0e0e0", alpha = 0.6, color = "white", linewidth = 0.15) +
  geom_area(data = density_df |> filter(component == "Low Type (\u03c0\u2081)"),
            aes(x = x, y = y), fill = "#2a9d8f", alpha = 0.25) +
  geom_area(data = density_df |> filter(component == "High Type (\u03c0\u2082)"),
            aes(x = x, y = y), fill = "#1a3a36", alpha = 0.25) +
  geom_line(data = density_df |> filter(component == "Low Type (\u03c0\u2081)"),
            aes(x = x, y = y, color = component), linewidth = 1.3) +
  geom_line(data = density_df |> filter(component == "High Type (\u03c0\u2082)"),
            aes(x = x, y = y, color = component), linewidth = 1.3) +
  geom_line(data = density_df |> filter(component == "Mixture"),
            aes(x = x, y = y, color = component), linewidth = 1.1, linetype = "dashed") +
  geom_vline(xintercept = mu1, linetype = "dotted", color = "#2a9d8f", alpha = 0.6) +
  geom_vline(xintercept = mu2, linetype = "dotted", color = "#1a3a36", alpha = 0.6) +
  scale_color_manual(
    values = c("Low Type (\u03c0\u2081)" = "#2a9d8f",
               "High Type (\u03c0\u2082)" = "#1a3a36",
               "Mixture" = "#c0392b"),
    name = NULL
  ) +
  annotate("label", x = mu1, y = max(density_df$y) * 1.05,
           label = sprintf("\u03bc\u2081 = %.2f", mu1),
           fill = "#2a9d8f", color = "white", fontface = "bold",
           size = 3.2, label.padding = unit(0.25, "lines"), label.r = unit(0.2, "lines")) +
  annotate("label", x = mu2, y = max(density_df$y) * 0.95,
           label = sprintf("\u03bc\u2082 = %.2f", mu2),
           fill = "#1a3a36", color = "white", fontface = "bold",
           size = 3.2, label.padding = unit(0.25, "lines"), label.r = unit(0.2, "lines")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(
    x = "Log Wage", y = "Density",
    title = "EM-Recovered Gaussian Mixture Components",
    subtitle = sprintf("Converged in %d %s  \u2022  \u03c0\u2081=%.0f%%, \u03c0\u2082=%.0f%%",
                       current_iter - 2,
                       ifelse(current_iter - 2 == 1, "iteration", "iterations"),
                       pi1 * 100, pi2 * 100),
    caption = "hsantanna.org"
  ) +
  theme_blog() +
  theme(
    plot.title = element_text(face = "bold", color = "#2d2d2d", size = rel(1.2),
                              margin = margin(b = 2)),
    plot.subtitle = element_text(margin = margin(b = 15)),
    legend.position = c(0.88, 0.88),
    legend.background = element_rect(fill = alpha("white", 0.92), color = "#e0e0e0",
                                     linewidth = 0.3),
    legend.key.width = unit(1.5, "cm"),
    legend.margin = margin(5, 8, 5, 8)
  )

ggsave(file.path(img_dir, "em_overlay.png"), p_em_overlay,
       width = 10, height = 6.5, dpi = 250, bg = "white")
cat("  -> em_overlay.png\n")

# =============================================================
# FIGURE 2: Bunching — DAG (custom built, not ggdag)
# =============================================================
cat("Generating Bunching figures...\n")

# Custom DAG with ggplot for full color control
nodes <- tibble(
  name = c("Education", "Cigarettes", "Birth\nWeight", "\u03b7"),
  x = c(0, 2.2, 4.4, 3.3),
  y = c(3, 3, 3, 1),
  node_size = c(22, 22, 22, 18),
  fill = c("#2d2d2d", "#2d2d2d", "#2a9d8f", "#c0392b"),
  text_col = c("white", "white", "white", "white"),
  text_size = c(3.2, 3.2, 3.2, 5)
)

p_dag <- ggplot() +
  # Solid edges: Educ→Cigs, Cigs→BW
  geom_segment(aes(x = 0, y = 3, xend = 2.2, yend = 3),
               arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
               color = "#2d2d2d", linewidth = 0.7) +
  geom_segment(aes(x = 2.2, y = 3, xend = 4.4, yend = 3),
               arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
               color = "#2d2d2d", linewidth = 0.7) +
  # Curved edge: Educ→BW (direct, over the top)
  geom_curve(aes(x = 0, y = 3.1, xend = 4.4, yend = 3.1),
             curvature = -0.35,
             arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
             color = "#2d2d2d", linewidth = 0.5, linetype = "solid") +
  # Dashed edges: η→Cigs, η→BW (confounding)
  geom_segment(aes(x = 3.3, y = 1, xend = 2.2, yend = 3),
               arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
               color = "#c0392b", linewidth = 0.7, linetype = "dashed") +
  geom_segment(aes(x = 3.3, y = 1, xend = 4.4, yend = 3),
               arrow = arrow(length = unit(0.25, "cm"), type = "closed"),
               color = "#c0392b", linewidth = 0.7, linetype = "dashed") +
  # Nodes
  geom_point(data = nodes, aes(x = x, y = y, fill = fill, size = node_size),
             shape = 21, color = "white", stroke = 1.5) +
  geom_text(data = nodes, aes(x = x, y = y, label = name, color = text_col, size = text_size),
            fontface = "bold", lineheight = 0.9) +
  scale_size_identity() +
  scale_fill_identity() +
  scale_color_identity() +
  coord_fixed(ratio = 0.8, xlim = c(-0.8, 5.2), ylim = c(0.3, 4.2)) +
  annotate("text", x = 3.3, y = 0.45,
           label = "Unobserved confounder", color = "#c0392b",
           fontface = "italic", size = 3.2) +
  labs(title = "Causal Diagram: Smoking and Birth Weight",
       caption = "Dashed red = confounding path through unobservables") +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", color = "#2d2d2d", size = 14,
                              hjust = 0.5, margin = margin(b = 15)),
    plot.caption = element_text(color = "#999999", size = 9, hjust = 0.5,
                                margin = margin(t = 10)),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(15, 15, 15, 15)
  )

ggsave(file.path(img_dir, "bunch_dag.png"), p_dag,
       width = 9, height = 5.5, dpi = 250, bg = "white")
cat("  -> bunch_dag.png\n")

# =============================================================
# FIGURE 3: Bunching — Scatter Plot
# =============================================================

set.seed(20240804)
n_b <- 5000
educ <- sample(6:16, n_b, replace = TRUE)
eta <- rnorm(n_b)
cigs_star <- 20 - 1.5 * educ + 5 * eta + rnorm(n_b, 0, 3)
cigs <- pmax(0, round(cigs_star))
bw <- 3000 - 20 * cigs + 15 * educ - 10 * eta + rnorm(n_b, 0, 100)
bdata <- tibble(bw = bw, cigs = cigs, educ = educ)

bunching_pct <- mean(bdata$cigs == 0) * 100

# Separate smokers and non-smokers for different styling
smokers <- bdata |> filter(cigs > 0)
non_smokers <- bdata |> filter(cigs == 0)

p_scatter <- ggplot() +
  # Bunching highlight band — bold
  annotate("rect", xmin = -1.2, xmax = 0.8, ymin = -Inf, ymax = Inf,
           fill = "#c0392b", alpha = 0.10) +
  # Smokers first (underneath)
  geom_point(data = smokers, aes(x = cigs, y = bw, color = cigs),
             alpha = 0.5, size = 1.6, shape = 16) +
  # Non-smokers on TOP — jittered horizontally so they spread and show density
  geom_jitter(data = non_smokers, aes(x = cigs, y = bw),
              color = "#c0392b", alpha = 0.5, size = 2, shape = 16,
              width = 0.35, height = 0) +
  # Fit line (all data)
  geom_smooth(data = bdata, aes(x = cigs, y = bw),
              method = "lm", color = "#2a9d8f", fill = "#2a9d8f",
              alpha = 0.15, linewidth = 1.4, se = TRUE) +
  scale_color_gradient(low = "#6bc4b8", high = "#1a1a1a",
                       name = "Cigarettes\nper Day",
                       guide = guide_colorbar(barwidth = 0.8, barheight = 5)) +
  # Annotation — solid dark badge, no alpha tricks
  annotate("rect",
           xmin = max(cigs) * 0.42, xmax = max(cigs) * 0.72,
           ymin = max(bw) * 0.955, ymax = max(bw) * 0.995,
           fill = "#1a3a36", color = NA) +
  annotate("text", x = max(cigs) * 0.57, y = max(bw) * 0.975,
           label = sprintf("%.0f%% bunched at zero", bunching_pct),
           color = "white", fontface = "bold", size = 3.8) +
  # Arrow — thick and clear
  annotate("segment",
           x = max(cigs) * 0.42, y = max(bw) * 0.965,
           xend = 1.2, yend = max(bw) * 0.945,
           arrow = arrow(length = unit(0.3, "cm"), type = "closed"),
           color = "#1a3a36", linewidth = 1) +
  labs(
    title = "Cigarette Consumption vs. Birth Weight",
    subtitle = "Non-smokers (red) pile up at zero — the bunching signature of a censored running variable",
    x = "Cigarettes Smoked per Day",
    y = "Birth Weight (grams)",
    caption = "hsantanna.org"
  ) +
  theme_blog() +
  theme(
    legend.position = c(0.93, 0.7),
    legend.background = element_rect(fill = alpha("white", 0.92), color = "#e0e0e0",
                                     linewidth = 0.3)
  )

ggsave(file.path(img_dir, "cig_bw_plot.png"), p_scatter,
       width = 10, height = 6.5, dpi = 250, bg = "white")
cat("  -> cig_bw_plot.png\n")

# =============================================================
# FIGURE 4: Bunching — CDF
# =============================================================

p_cdf <- ggplot(bdata, aes(x = cigs)) +
  stat_ecdf(geom = "step", color = "#2d2d2d", linewidth = 0.9, pad = FALSE) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "#2a9d8f", linewidth = 0.8) +
  # Filled region for the jump
  annotate("rect", xmin = -0.5, xmax = 0.5, ymin = 0, ymax = bunching_pct / 100,
           fill = "#2a9d8f", alpha = 0.15) +
  annotate("label", x = max(cigs) * 0.35, y = bunching_pct / 100 - 0.04,
           label = sprintf("%.0f%% at zero", bunching_pct),
           fill = "#2a9d8f", color = "white", fontface = "bold", size = 4,
           label.padding = unit(0.3, "lines"), label.r = unit(0.2, "lines")) +
  labs(
    title = "Empirical CDF of Cigarette Consumption",
    subtitle = "The vertical jump at zero reveals the bunching mass",
    x = "Cigarettes Smoked per Day",
    y = "Cumulative Probability",
    caption = "hsantanna.org"
  ) +
  theme_blog()

ggsave(file.path(img_dir, "bunch_CDF.png"), p_cdf,
       width = 9, height = 5.5, dpi = 250, bg = "white")
cat("  -> bunch_CDF.png\n")

# =============================================================
# FIGURE 5: DR — Lollipop comparison chart
# =============================================================
cat("Generating DR figures...\n")

set.seed(123)
n_dr <- 10000
X1 <- rnorm(n_dr)
X2 <- rnorm(n_dr)
ps_true <- plogis(-1 - 0.5 * X1 - 0.5 * X2)
treat <- rbinom(n_dr, 1, ps_true)
tau <- 0.5

df <- tibble(
  X1 = X1, X2 = X2, treat = treat,
  Y = tau * treat + 0.25 * X1 + 0.25 * X2 + rnorm(n_dr, 0, 0.5)
)

naive_ATE <- df |>
  group_by(treat) |> summarize(meanY = mean(Y)) |>
  summarize(ATE = diff(meanY)) |> pull()
correct_ols <- lm(Y ~ treat + X1 + X2, data = df)
ps_model <- glm(treat ~ X1 + X2, data = df, family = binomial)
df$ps <- predict(ps_model, type = "response")
df$weight <- ifelse(df$treat == 1, 1 / df$ps, 1 / (1 - df$ps))
Y1 <- sum(df$Y[df$treat == 1] * df$weight[df$treat == 1]) / nrow(df)
Y0 <- sum(df$Y[df$treat == 0] * df$weight[df$treat == 0]) / nrow(df)
ipw_ATE <- Y1 - Y0
mu1_model <- lm(Y ~ X1 + X2, data = df |> filter(treat == 1))
mu0_model <- lm(Y ~ X1 + X2, data = df |> filter(treat == 0))
df$mu1_hat <- predict(mu1_model, newdata = df)
df$mu0_hat <- predict(mu0_model, newdata = df)
aipw_1 <- mean(df$treat * (df$Y - df$mu1_hat) / df$ps + df$mu1_hat)
aipw_0 <- mean((1 - df$treat) * (df$Y - df$mu0_hat) / (1 - df$ps) + df$mu0_hat)
aipw_ATE <- aipw_1 - aipw_0
mu1_wrong <- lm(Y ~ 1, data = df |> filter(treat == 1))
mu0_wrong <- lm(Y ~ 1, data = df |> filter(treat == 0))
df$mu1_wrong <- predict(mu1_wrong, newdata = df)
df$mu0_wrong <- predict(mu0_wrong, newdata = df)
aipw_mis_1 <- mean(df$treat * (df$Y - df$mu1_wrong) / df$ps + df$mu1_wrong)
aipw_mis_0 <- mean((1 - df$treat) * (df$Y - df$mu0_wrong) / (1 - df$ps) + df$mu0_wrong)
aipw_mis_ATE <- aipw_mis_1 - aipw_mis_0

results <- tibble(
  method = c("Naive\n(no controls)", "OLS\n(outcome model only)", "IPW\n(PS model only)",
             "AIPW\n(both models correct)", "AIPW\n(wrong outcome,\ncorrect PS)"),
  ate = c(naive_ATE, coef(correct_ols)["treat"], ipw_ATE, aipw_ATE, aipw_mis_ATE)
) |>
  mutate(
    method = factor(method, levels = rev(method)),
    close = abs(ate - tau) < 0.05,
    fill_col = ifelse(close, "#2a9d8f", "#c0392b"),
    bias = ate - tau
  )

# Place labels to the RIGHT of dots (after coord_flip, nudge_y = horizontal offset)
# For Naive (biased, ate ~0.27): label to the LEFT of dot
# For green cluster (ate ~0.49-0.50): labels to the RIGHT, staggered to avoid overlap
results <- results |>
  mutate(
    label_y = case_when(
      ate < 0.4 ~ ate - 0.04,            # Naive: label to the left
      TRUE ~ ate + 0.04                    # Green: label to the right
    ),
    label_hjust = case_when(
      ate < 0.4 ~ 1,                       # Naive: right-align (points left)
      TRUE ~ 0                              # Green: left-align (points right)
    )
  )

p_dr <- ggplot(results, aes(x = method, y = ate)) +
  # Reference line
  geom_hline(yintercept = tau, color = "#2d2d2d", linewidth = 0.6, linetype = "solid") +
  annotate("rect", xmin = -Inf, xmax = Inf,
           ymin = tau - 0.025, ymax = tau + 0.025,
           fill = "#2a9d8f", alpha = 0.08) +
  # Lollipop stems
  geom_segment(aes(x = method, xend = method, y = tau, yend = ate, color = fill_col),
               linewidth = 1.2) +
  # Points
  geom_point(aes(fill = fill_col), size = 4, shape = 21, color = "white", stroke = 1.2) +
  # ATE values: color matches dot, positioned clearly beside each dot
  geom_text(aes(label = sprintf("%.3f", ate), y = label_y,
                hjust = label_hjust, color = fill_col),
            size = 4.5, fontface = "bold") +
  # Labels
  scale_fill_identity() +
  scale_color_identity() +
  scale_y_continuous(breaks = seq(0, 0.6, 0.1), limits = c(0.10, 0.62),
                     expand = expansion(mult = c(0.02, 0.05))) +
  annotate("text", x = 0.5, y = tau + 0.06,
           label = paste0("True \u03c4 = ", tau),
           fontface = "bold", color = "#2d2d2d", size = 3.5, hjust = 0) +
  coord_flip() +
  labs(
    title = "Estimator Comparison: Average Treatment Effect",
    subtitle = "Lollipop distance from the reference line shows bias  \u2022  Green = accurate, Red = biased",
    x = NULL, y = "Estimated ATE",
    caption = "hsantanna.org"
  ) +
  theme_blog() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(size = 10, face = "bold", color = "#2d2d2d")
  )

ggsave(file.path(img_dir, "dr_comparison.png"), p_dr,
       width = 10, height = 5.5, dpi = 250, bg = "white")
cat("  -> dr_comparison.png\n")

cat("\nAll figures generated successfully!\n")
