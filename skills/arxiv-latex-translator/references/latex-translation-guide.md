# LaTeX Translation Guide

Detailed patterns for translating LaTeX academic papers.

## Translation Principles

### DO Translate
- Section titles (`\section`, `\subsection`)
- Abstract text
- Paragraph content
- Figure/table captions
- Itemize/enumerate text
- Abstract and conclusion

### DO NOT Translate
- LaTeX commands and syntax
- Citation keys (`\citep{key}`)
- Label names (`\label{sec:intro}`)
- Reference commands (`\ref{tab:results}`)
- Math formulas and symbols
- Code listings
- File paths and URLs
- Author names and affiliations
- Bibliography entries

## Common Patterns

### Section Translation
```latex
% Original
\section{Introduction}
\subsection{Related Work}
\paragraph{Main Contribution.}

% Translated
\section{引言}
\subsection{相关工作}
\paragraph{主要贡献。}
```

### Citation Handling
```latex
% Original
As shown in previous work \citep{smith2020}, ...

% Translated
如先前工作 \citep{smith2020} 所示，...
```

### Figure Environment
```latex
% Original
\begin{figure}[t]
    \centering
    \includegraphics[width=0.8\textwidth]{fig1.pdf}
    \caption{Performance comparison of different methods.}
    \label{fig:performance}
\end{figure}

% Translated
\begin{figure}[t]
    \centering
    \includegraphics[width=0.8\textwidth]{fig1.pdf}
    \caption{不同方法的性能比较。}
    \label{fig:performance}
\end{figure}
```

### Table Environment
```latex
% Original - translate caption and column headers only
\begin{table}[h]
\centering
\caption{Results on benchmark datasets.}
\begin{tabular}{lcc}
\toprule
\textbf{Method} & \textbf{Accuracy} & \textbf{F1} \\
\midrule
Baseline & 85.2 & 84.1 \\
Ours & 92.5 & 91.8 \\
\bottomrule
\end{tabular}
\end{table}

% Translated
\begin{table}[h]
\centering
\caption{基准数据集上的结果。}
\begin{tabular}{lcc}
\toprule
\textbf{方法} & \textbf{准确率} & \textbf{F1分数} \\
\midrule
Baseline & 85.2 & 84.1 \\
Ours & 92.5 & 91.8 \\
\bottomrule
\end{tabular}
\end{table}
```

### Math Environments
```latex
% Original - keep math exactly as is
The loss function is defined as:
\begin{equation}
L(\theta) = \sum_{i=1}^{n} (y_i - f_\theta(x_i))^2
\end{equation}
where $\theta$ denotes model parameters.

% Translated - only translate surrounding text
损失函数定义为：
\begin{equation}
L(\theta) = \sum_{i=1}^{n} (y_i - f_\theta(x_i))^2
\end{equation}
其中 $\theta$ 表示模型参数。
```

### Algorithm Environment
```latex
% Original - translate caption and comments only
\begin{algorithm}
\caption{Training Procedure}
\begin{algorithmic}[1]
\Require Dataset $D$, learning rate $\eta$
\For{each epoch}
    \State Sample batch from $D$
    \State Compute loss $L$
    \State Update parameters
\EndFor
\end{algorithmic}
\end{algorithm}

% Translated
\begin{algorithm}
\caption{训练过程}
\begin{algorithmic}[1]
\Require Dataset $D$, learning rate $\eta$
\For{each epoch}
    \State 从 $D$ 采样批次
    \State 计算损失 $L$
    \State 更新参数
\EndFor
\end{algorithmic}
\end{algorithm}
```

## Special Cases

### Technical Terms
Keep English for:
- Model names (GPT-4, BERT, ResNet)
- Dataset names (ImageNet, COCO)
- Metric names (BLEU, ROUGE, F1) - but translate description
- Algorithm names (Adam, SGD)

### Abbreviations
First occurrence: translate with original in parentheses
```latex
% Original
We use reinforcement learning (RL) to optimize ...

% Translated
我们使用强化学习（Reinforcement Learning, RL）来优化 ...
```

### Footnotes
Translate footnote content, preserve citations
```latex
% Original
Our approach\footnote{Code available at \url{https://github.com/...}.} achieves ...

% Translated
我们的方法\footnote{代码可在 \url{https://github.com/...} 获取。}实现了 ...
```

## Quality Checklist

Before finalizing translation:
- [ ] All LaTeX commands preserved
- [ ] Math formulas unchanged
- [ ] Citations remain intact
- [ ] Labels and references preserved
- [ ] Figure/table structure intact
- [ ] Code listings unchanged
- [ ] PDF compiles without errors
