\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cep}[2023/09/03 Class for COMP6250 Career Episode Piece]
% Declare my option option and pass it to the base class
% \ProcessOptions\relax  % must if any \DeclareOption{}{} appears above

% Based on the article class
\LoadClass[12pt, a4paper]{article}


% Import packages
% Layout: paper-size, margin, etc
\RequirePackage{geometry}
\geometry{
  bottom=3cm,
  left=3.5cm,
  right=3.5cm,
  top=1cm,
}

% Color
% Colors: user-defined colors
\RequirePackage[dvipsnames]{xcolor}
\definecolor{ghblue}{HTML}{0969da}

% URLs: email, github repos, article
% This pacakge should come last or as late as possible
\RequirePackage[hidelinks]{hyperref}

% Shorten the URLs to domain/title in bib
% args: #1 long real url; #2 domain; #3 title where
% domain and title must escape their underscore(s)
\newcommand{\src}[3]{%
  \small\textcolor{ghblue}{\href{#1}{#2/#3}}
}

\newcommand{\orul}[1]{%
  \small\textcolor{ghblue}{\url{#1}}
}

% Bibliography
\RequirePackage[
backend=biber,
sorting=nyt,
style=ext-authoryear,
articlein=false,
block=space,                    % add space after each block
date=year,                      % use only date in reference entry
isbn=false,                     % suppress ISBN block in reference entry
]{biblatex}

\DeclareFieldFormat[article]{volume}{\addnbspace vol.\addnbspace #1}
\DeclareFieldFormat[article]{number}{\addnbspace no.\addnbspace #1}
\DeclareFieldFormat[article]{journaltitle}{\emph{#1}}
\DeclareFieldFormat[misc]{subtitle}{\textnormal{#1}}
\DeclareDelimFormat{nameyeardelim}{%
  \addcomma\space}

% Do not italicize the subtitle in misc
\DeclareFieldFormat[inbook]{title}{\textnormal{#1}}
\DeclareFieldFormat[article,book,booklet,inbook,misc]{url}{%
    \small\textcolor{ghblue}{\url{#1}}
}

% No indentation of paragraphs and 10pt vertical space between each
\setlength\parindent{0pt}
\setlength\parskip{10pt}
\newcommand{\RNCaps}[1]
    {\MakeUppercase{\romannumeral #1}}
