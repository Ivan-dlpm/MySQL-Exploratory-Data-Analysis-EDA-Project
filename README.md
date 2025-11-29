<h1>Global Layoffs Data Cleaning Project (MySQL)</h1>

<h2>Project Description</h2>
For this project, I built a full SQL data-cleaning workflow using a real global layoffs dataset. I created a new MySQL database, imported raw CSV data, and built a proper staging table to safely perform transformations. I removed duplicate records using window functions and row-number logic, standardized inconsistent values across fields (such as company names, industries, and countries), and cleaned formatting issues like leading/trailing spaces and non-uniform text. I converted date fields from text to proper DATE datatypes using STR_TO_DATE, handled null and blank values through conditional joins and targeted updates, and populated missing attributes wherever the data allowed. Finally, I removed unusable records and dropped unnecessary columns to produce a clean, analysis-ready table that could be used for exploratory data analysis in a subsequent project.

<h2> Full SQL data-cleaning workflow </h2>

- <b>[Clean Global Layoffs Data (SQL)]()</b>

<h2> Result Grid </h2>

<p align="center">
  
<img src="https://imgur.com/4YZxWrH.png" height="80%" width="80%" alt="Disk Sanitization Steps"/>
<br />
<br />
<h2>Original Data </h2>

- <b>[Global Layoffs Data CSV]()</b> 
