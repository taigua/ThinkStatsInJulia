### A Pluto.jl notebook ###
# v0.20.25

using Markdown
using InteractiveUtils

# ╔═╡ af551046-78fc-4eeb-a181-b7bdcdefaf41
begin
	using DataFrames, DuckDB
	using PrettyTables, FreqTables
	using StatsBase
end

# ╔═╡ 4ece36ad-7e91-4813-9df6-9e52ffec50d1
include("utils.jl")

# ╔═╡ 677f5480-505b-11f1-b267-dbcddb2e318a
md"""
# Exploratory Data Analysis

The thesis of this book is we can use data to answer questions, resolve debates, and make better decisions.

This chapter introduces the steps we'll use to do that: loading and validating data, exploring, and choosing statistics that measure what we are interested in.
As an example, we'll use data from the National Survey of Family Growth (NSFG) to answer a question I heard when my wife and I were expecting our first child: do first babies tend to arrive late?
"""

# ╔═╡ 44b6f067-6165-4f58-985f-bb2acffbdce8
md"""
## Evidence

You might have heard that first babies are more likely to be late.
If you search the web with this question, you will find plenty of discussion.
Some people claim it's true, others say it's a myth, and some people say it's the other way around: first babies come early.

In many of these discussions, people provide data to support their claims.
I found many examples like these:

> "My two friends that have given birth recently to their first babies, BOTH went almost 2 weeks overdue before going into labour or being induced."

> "My first one came 2 weeks late and now I think the second one is going to come out two weeks early!!"

> "I don't think that can be true because my sister was my mother's first and she was early, as with many of my cousins."
"""

# ╔═╡ 4b56de0b-4590-4213-b0b4-c0c69a547a65
md"""
Reports like these are called **anecdotal evidence** because they are based on data that is unpublished and usually personal.
In casual conversation, there is nothing wrong with anecdotes, so I don't mean to pick on the people I quoted.

But we might want evidence that is more persuasive and an answer that is more reliable.
By those standards, anecdotal evidence usually fails, because:

-   Small number of observations: If pregnancy length is longer for first babies, the difference is probably small compared to natural variation. In that case, we might have to compare a large number of pregnancies to know whether there is a difference.

-   Selection bias: People who join a discussion of this question might be interested because their first babies were late. In that case the process of selecting data would bias the results.

-   Confirmation bias: People who believe the claim might be more likely to contribute examples that confirm it. People who doubt the claim are more likely to cite counterexamples.

-   Inaccuracy: Anecdotes are often personal stories, and might be misremembered, misrepresented, repeated inaccurately, etc.
"""

# ╔═╡ c14ce053-4b33-47bb-9aac-88bf2356fe18
md"""
To address the limitations of anecdotes, we will use the tools of statistics, which include:

-   Data collection: We will use data from a large national survey that was designed explicitly with the goal of generating statistically valid inferences about the U.S. population.

-   Descriptive statistics: We will generate statistics that summarize the data concisely, and evaluate different ways to visualize data.

-   Exploratory data analysis: We will look for patterns, differences, and other features that address the questions we are interested in. At the same time we will check for inconsistencies and identify limitations.

-   Estimation: We will use data from a sample to estimate characteristics of the general population.

-   Hypothesis testing: Where we see apparent effects, like a difference between two groups, we will evaluate whether the effect might have happened by chance.

By performing these steps with care to avoid pitfalls, we can reach conclusions that are more justified and more likely to be correct.
"""

# ╔═╡ 3189c39b-8960-4333-8daf-149aadd01e75
md"""
## The National Survey of Family Growth

Since 1973 the U.S. Centers for Disease Control and Prevention (CDC) have conducted the National Survey of Family Growth (NSFG), which is intended to gather "information on family life, marriage and divorce, pregnancy, infertility, use of contraception, and men's and women's health. The survey results are used...to plan health services and health education programs, and to do statistical studies of families, fertility, and health."
"""

# ╔═╡ bc83e00e-e344-4e47-8c06-b665bc6022ee
md"""
You can read more about the NSFG at <http://cdc.gov/nchs/nsfg.htm>.
"""

# ╔═╡ 20266e29-f8de-4ec0-a425-f776aa18cb84
md"""
We will use data collected by this survey to investigate whether first babies tend to be born late, and other questions.
In order to use this data effectively, we have to understand the design of the study.

In general, the goal of a statistical study is to draw conclusions about a **population**.
In the NSFG, the target population is people in the United States aged 15-44.

Ideally surveys would collect data from every member of the population, but that's seldom possible.
Instead we collect data from a subset of the population called a **sample**.
The people who participate in a survey are called **respondents**.

The NSFG is a **cross-sectional** study, which means that it captures a snapshot of a population at a point in time.
The NSFG has been conducted several times now; each deployment is called a **cycle**.
We will use data from Cycle 6, which was conducted from January 2002 to March 2003.
"""

# ╔═╡ 5bb0184b-f6fc-41bf-9513-764614010bba
md"""
In general, cross-sectional studies are meant to be **representative**, which means that the sample is similar to the target population in all ways that are important for the purposes of the study.
That ideal is hard to achieve in practice, but people who conduct surveys come as close as they can.

The NSFG is not representative; instead it is **stratified**, which means that it deliberately **oversamples** some groups.
The designers of the study recruited three groups -- Hispanics, African-Americans and teenagers -- at rates higher than their representation in the U.S. population, in order to make sure that the number of respondents in each group is large enough to draw valid conclusions.
The drawback of oversampling is that it is not as easy to draw conclusions about the population based on statistics from the sample.
We will come back to this point later.

When working with this kind of data, it is important to be familiar with the **codebook**, which documents the design of the study, the survey questions, and the encoding of the responses.
"""

# ╔═╡ 9e8fa107-852a-4941-a47d-8a9f87a5e966
md"""
The codebook and user's guide for the NSFG data are available from <http://www.cdc.gov/nchs/nsfg/nsfg_cycle6.htm>
"""

# ╔═╡ 16eea539-4a76-4b4f-b72b-fcdeb39706c2
md"""
## Reading the Data

Before downloading NSFG data, you have to agree to the terms of use:

> Any intentional identification or disclosure of an individual or establishment violates the assurances of confidentiality given to the providers of the information. Therefore, users will:
>
> * Use the data in this dataset for statistical reporting and analysis only.
>
> * Make no attempt to learn the identity of any person or establishment included in these data.
>
> * Not link this dataset with individually identifiable data from other NCHS or non-NCHS datasets.
>
> * Not engage in any efforts to assess disclosure methodologies applied to protect individuals and establishments or any research on methods of re-identification of individuals and establishments.

If you agree to comply with these terms, instructions for downloading the data are in the notebook for this chapter.
"""

# ╔═╡ cb57b720-b44f-4a90-91f6-f720bfb6e750
md"""
The data files are available directly from the NSFG web site at <https://www.cdc.gov/nchs/data_access/ftp_dua.htm?url_redirect=ftp://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NSFG>, but we will download them from the repository for this book, and convert it to parquet format.

The following cell includes `utils.jl` to parse parquet file using DuckDB.
"""

# ╔═╡ e54c5cef-cd40-4f36-8448-886634a057c9
md"""
Here's how we use it.
"""

# ╔═╡ 7df534fb-c8d3-4713-b18c-320f65ec4402
preg = read_parquet("data/2002FemPreg.parquet");

# ╔═╡ 5a52ca6b-cd3f-4d00-8059-0a6c1be81b28
md"""
The result is a `DataFrame`, which is a DataFrames.jl data structure that represents tabular data in rows and columns.
This `DataFrame` contains a row for each pregnancy reported by a respondent and a column for each **variable**.
A variable can contain responses to a survey question or values that are calculated based on responses to one or more questions.

In addition to the data, a `DataFrame` also contains the variable names and their types, and it provides methods for accessing and modifying the data.
We can use `size` function to get the number of rows and columns of `DataFrame`.
"""

# ╔═╡ 74f771bf-ea3f-4304-b906-db1af157d8db
size(preg)

# ╔═╡ 735483b8-b973-4397-bd38-2f0c26d54c12
md"""
This dataset has 243 variables with information about 13,593 pregnancies.
We can use `first` function to display the first few rows.
"""

# ╔═╡ f13c4f8d-e6b4-4464-af61-36cdcb4e1cf8
first(preg, 5)

# ╔═╡ 869c857e-6966-4ea6-8ce2-027a699889d8
md"""
We can use `names` function to get the names of the variables
"""

# ╔═╡ 968fe9b1-0563-4bf7-81f9-4eae4c7554a8
names(preg)

# ╔═╡ 3ad12d42-b66e-4038-9502-d2f5d1bf2439
md"""
To access a column from a `DataFrame`, you can use the column name as a key.
"""

# ╔═╡ 71e71b1d-fe3d-4d5a-9416-52d5c34f74b5
begin
	pregordr = preg.pregordr
	typeof(pregordr)
end

# ╔═╡ e7cb6627-f8f5-4f0b-ba66-214e77762304
md"""
The result is a Julia `Vector`, which represents a sequence of values.
`Int64` indicates that the values are 64-bit integers.
We can also use `first` function, which displays the first few values.
"""

# ╔═╡ bd3ac994-39fc-4373-af95-26d8bfe00f14
first(pregordr, 5)

# ╔═╡ 86224fd7-6ea9-4631-9f8c-ebaa7e67bb25
md"""
The NSFG dataset contains 243 variables in total.
Here are some of the ones we'll use for the explorations in this book.

-   `caseid` is the integer ID of the respondent.

-   `pregordr` is a pregnancy serial number: the code for a respondent's first pregnancy is 1, for the second pregnancy is 2, and so on.

-   `prglngth` is the integer duration of the pregnancy in weeks.

-   `outcome` is an integer code for the outcome of the pregnancy. The code 1 indicates a live birth.

-   `birthord` is a serial number for live births: the code for a respondent's first child is 1, and so on. For outcomes other than live birth, this field is blank.

-   `birthwgt_lb` and `birthwgt_oz` contain the pounds and ounces parts of the birth weight of the baby.

-   `agepreg` is the mother's age at the end of the pregnancy.

-   `finalwgt` is the statistical weight associated with the respondent. It is a floating-point value that indicates the number of people in the U.S. population this respondent represents.
"""

# ╔═╡ 74d76945-68ee-4614-b7ea-6df4232657b0
md"""
If you read the codebook carefully, you will see that many of the variables are **recodes**, which means that they are not part of the **raw data** collected by the survey -- they are calculated using the raw data.

For example, `prglngth` for live births is equal to the raw variable `wksgest` (weeks of gestation) if it is available; otherwise it is estimated using `mosgest * 4.33` (months of gestation times the average number of weeks in a month).

Recodes are often based on logic that checks the consistency and accuracy of the data.
In general it is a good idea to use recodes when they are available, unless there is a compelling reason to process the raw data yourself.
"""

# ╔═╡ 43828f7a-3520-4ab9-87d8-7a9a377a9aaa
md"""
## Validation

When data is exported from one software environment and imported into another, errors might be introduced.
And when you are getting familiar with a new dataset, you might decode data incorrectly or misunderstandings its meaning.
If you invest time to validate the data, you can save time later and avoid errors.

One way to validate data is to compute basic statistics and compare them with published results.
For example, the NSFG codebook includes tables that summarize each variable.
Here is the table for `outcome`, which encodes the outcome of each pregnancy.
"""

# ╔═╡ c2d66bb3-b4e9-4077-b3b6-5f9024c75db8
DataFrame(	
    Value = [1, 2, 3, 4, 5, 6, "Total"],
    Label = [
        "LIVE BIRTH",
        "INDUCED ABORTION",
        "STILLBIRTH",
        "MISCARRIAGE",
        "ECTOPIC PREGNANCY",
        "CURRENT PREGNANCY",
        "",
    ],
    Total = [9148, 1862, 120, 1921, 190, 352, 13593],
)

# ╔═╡ ca4acb04-cb24-4c8c-ac37-9ff437794a3e
md"""
The "Total" column indicates the number of pregnancies with each outcome.
To check these totals, we'll use the `freqtable` method in [FreqTables.jl](https://github.com/nalimilan/FreqTables.jl), which counts the number of times each value appears.
"""

# ╔═╡ d3b078d7-5371-4b45-a228-bec5a8468419
# freqtable is used in value_count
value_count(preg, :outcome)

# ╔═╡ 226221b3-790a-4e5a-90fd-9de594150278
md"""
Comparing the results with the published table, we can confirm that the values in `outcome` are correct.
Similarly, here is the published table for `birthwgt_lb`.
"""

# ╔═╡ 5c0bac4e-ca00-42b0-aa2b-296cba497d8c
DataFrame(
    Values = [".", "0-5", "6", "7", "8", "9-95", "97", "98", "99", "Total"],
    Label = [
        "inapplicable",
        "UNDER 6 POUNDS",
        "6 POUNDS",
        "7 POUNDS",
        "8 POUNDS",
        "9 POUNDS OR MORE",
        "Not ascertained",
        "REFUSED",
        "DON'T KNOW",
        "",
    ],
    Total = [4449, 1125, 2223, 3049, 1889, 799, 1, 1, 57, 13593],
)

# ╔═╡ b9a5b31c-fe85-4861-a54a-1589f8e9d635
md"""
Birth weight is only recorded for pregnancies that ended in a live birth.
The table indicates that there are 4449 cases where this variable is inapplicable.
In addition, there is one case where the question was not asked, one where the respondent did not answer, and 57 cases where they did not know.

Again, we can use `freqtable` to compare the counts in the dataset to the counts in the codebook.
"""

# ╔═╡ 5525e5d3-178f-4ab4-8f82-74aa0b3c26be
begin
	counts = freqtable(preg.birthwgt_lb)
	pretty_table(HTML, (birthwgt_lb=names(counts, 1), count=vec(counts)))
end


# ╔═╡ aafe6403-c5f6-4e53-b1b6-d4c38922d9dd
md"""
These `missing` appear in the results stands for "Not avaiable" -- and the count of these values is consistent with the count of inapplicable cases in the codebook.

The counts for 6, 7, and 8 pounds are consistent with the codebook.
To check the counts for the weight range from 0 to 5 pounds, we can use a slice index to select a subset of the counts.
"""

# ╔═╡ 94cfd5b6-bbad-4230-918d-f50f37e887bd
begin
	sub_counts = counts[0.0:5.0]
	pretty_table(HTML, (birthwgt_lb=names(sub_counts, 1), count=vec(sub_counts)))
end

# ╔═╡ 87f99a44-4d7d-45d0-b204-fa69a8a56d81
md"""
And we can use the `sum` method to add them up.
"""

# ╔═╡ 5f71700d-2411-45f8-a86c-4498c1567fb8
sum(sub_counts)

# ╔═╡ 9e713fbf-33c4-4116-aee9-1c2a7f01d49f
md"""
The total is consistent with the codebook.

The values 97, 98, and 99 represent cases where the birth weight is unknown.
There are several ways we might handle missing data.
A simple option is to replace these values with `missing`.
At the same time, we will also replace a value that is clearly wrong, 51 pounds.

We can use the replace method like this:
"""

# ╔═╡ 46859437-75dc-467e-a253-21acb259d4c5
replace!(x -> !ismissing(x) && x ∈ [51, 97, 98, 99] ? missing : x, preg.birthwgt_lb);

# ╔═╡ 9ff6af0a-731e-4ca9-b4e8-a5b7259220cb
md"""
When you read data like this, you often have to check for errors and deal with special values.
Operations like this are called **data cleaning**.
"""

# ╔═╡ 4b3b445c-abd8-45c9-86ea-dd288331a405
md"""
## Transformation

As another kind of data cleaning, sometimes we have to convert data into different formats, and perform other calculations.

For example, `agepreg` contains the mother's age at the end of the pregnancy.
According to the codebook, it is an integer number of centiyears (hundredths of a year), as we can tell if we use the `mean` method to compute its average.
"""

# ╔═╡ 07de27eb-e76b-48fb-9322-3a261c69a31e
mean(skipmissing(preg.agepreg))

# ╔═╡ e09c18c9-3be1-433d-8bc4-836e918d2c14
md"""
To convert it to years, we can divide through by 100.
"""

# ╔═╡ 35527bc3-7709-412b-ad83-7f3e474448a9
begin
	preg.agepreg ./= 100.0
	mean(skipmissing(preg.agepreg))
end

# ╔═╡ 5888a990-c111-436f-8794-162d8cc16eee
md"""
Now the average is more credible.

As another example, `birthwgt_lb` and `birthwgt_oz` contain birth weights with the pounds and ounces in separate columns.
It will be more convenient to combine them into as single column that contains weights in pounds and fractions of a pound.

First we'll clean `birthwgt_oz` as we did with `birthwgt_lb`.
"""

# ╔═╡ fb7731de-5e45-4970-af04-1924e8f7efec
value_count(preg, :birthwgt_oz; skipmissing=false)

# ╔═╡ 5d860658-e2a3-4051-8050-8e72e6ca65dd
replace!(x -> !ismissing(x) && x ∈ [97, 98, 99] ? missing : x, preg.birthwgt_oz);

# ╔═╡ 8f693559-0b53-4c10-af98-39b0ae3552ee
md"""
Now we can use the cleaned values to create a new column that combines pounds and ounces into a single quantity.
"""

# ╔═╡ ac887072-255c-414d-8016-6622003596ad
begin
	preg.totalwgt_lb .= preg.birthwgt_lb .+ preg.birthwgt_oz ./ 16.0
    mean(skipmissing(preg.totalwgt_lb))
end

# ╔═╡ a7ffb334-e67b-4fac-847a-fc524b2c800b
md"""
The average of the result seems plausible.
"""

# ╔═╡ 354f71c9-a97d-44f6-b910-d786face39b9
md"""
## Summary Statistics

A **statistic** is a number derived from a dataset, usually intended to quantify some aspect of the data.
Examples include the count, mean, variance, and standard deviation.
"""

# ╔═╡ 32e7157a-55a2-44e5-8698-53976c1ed8ef
begin
	weights = preg.totalwgt_lb
	weights_n = count(!ismissing, weights)
end

# ╔═╡ e65f25a8-3933-48c3-af2a-df337786fb3d
md"""
There is also a `sum` method that returns the sum of the values -- we can use it to compute the mean like this.
"""

# ╔═╡ 4fc1b649-2772-4791-ab9b-b0fa8a5167f6
weights_mean = sum(skipmissing(weights)) / weights_n

# ╔═╡ f677fce1-e889-4ae2-b84b-525319603232
md"""
But as we've already seen, there's also a `mean` function that does the same thing.
"""

# ╔═╡ bbf95602-7ec8-48aa-b396-1a1f59345b31
mean(skipmissing(weights))

# ╔═╡ 5d259727-9c72-4c60-96d9-bade4b80c0e9
md"""
In this dataset, the average birth weight is about 7.3 pounds.

Variance is a statistic that quantifies the spread of a set of values.
It is the mean of the squared deviations, which are the distances of each point from the mean.
"""

# ╔═╡ 77f6521f-cbb6-434a-8fca-bfb693908153
squared_deviations = (weights .- weights_mean) .^ 2;

# ╔═╡ 6c12455c-ab2e-4b65-9bbe-629e9c634c97
md"""
We can compute the mean of the squared deviations like this.
"""

# ╔═╡ 326e1b11-f75f-4ce3-a49d-37c799a4f4b8
weights_var = sum(skipmissing(squared_deviations)) / weights_n

# ╔═╡ 5447f54e-33cc-4357-bd41-23b75a8843fe
md"""
As you might expect, `Julia` provides a `var` method that does *almost* the same thing.
"""

# ╔═╡ 9372071f-7663-45c3-91e9-d6a2e3ead6a5
var(skipmissing(weights))

# ╔═╡ 5db9852a-6816-4337-8627-bb0d940981d3
md"""
The result is slightly different because when the `var` method computes the mean of the squared deviations, it divides by `n-1` rather than `n`.
That's because there are two ways to compute the variance of a sample, depending on what you are trying to do.
I'll explain the difference in `Chapter 8` -- but in practice it usually doesn't matter.
If you prefer the version with `n` in the denominator, you can get it by passing `corrected=false` as a keyword argument to the `var` method.
"""

# ╔═╡ 636eabf3-eb35-4861-ae17-63277f596494
var(skipmissing(weights), corrected=false)

# ╔═╡ c3038f3a-1ef1-44ed-baa6-735cc930c845
md"""
In this dataset, the variance of the birth weights is about 1.98, but that value is hard to interpret -- for one thing, it is in units of pounds squared.
Variance is useful in some computations, but not a good way to describe a dataset.
A better option is the **standard deviation**, which is the square root of variance.
We can compute it like this.
"""

# ╔═╡ 87022048-e786-4758-9c04-5b4c9ffd6439
weights_std = sqrt(weights_var)

# ╔═╡ 7d65569e-ece5-4dd4-85f4-be7f4d0d9be7
md"""
Or, we can use the `std` function.
"""

# ╔═╡ 90bbda04-e00c-4bc2-a7fa-34e9efedb13a
std(skipmissing(weights), corrected=false)

# ╔═╡ cad40632-b3f9-484c-a2a2-07d2f20b3d0a
md"""
In this dataset, the standard deviation of birth weights is about 1.4 pounds.
Informally, values that are one or two standard deviations from the mean are common -- values farther from the mean are rare.
"""

# ╔═╡ 6c2fbb9a-013a-48e4-a85c-09d6e54f65ac
md"""
## Interpretation

To work with data effectively, you have to think on two levels at the same time: the level of statistics and the level of context.
As an example, let's select the rows in the pregnancy file with `caseid` 10229.
The `subset` can be used to do this.
"""

# ╔═╡ 44a55052-8605-4c8c-87f3-4afa104d2599
begin
	preg_subset = subset(preg, :caseid => ByRow(==(10229)))
	size(preg_subset)
end

# ╔═╡ 3d58f064-3d9f-486d-a13a-6e36d4984258
md"""
The result is a `DataFrame` that contains only the rows where the subset condtion is `true`.
This respondent reported seven pregnancies -- here are their outcomes, which are recorded in chronological order.
"""

# ╔═╡ 6e33233f-36ff-48ab-bd5c-729e5da36d1b
preg_subset.outcome

# ╔═╡ bf78f9f1-cf51-4a1a-ab1f-745332be8f62
md"""
The outcome code `1` indicates a live birth.
Code `4` indicates a miscarriage -- that is, a pregnancy loss, usually with no known medical cause.

Statistically this respondent is not unusual.
Pregnancy loss is common and there are other respondents who reported as many instances.
But remembering the context, this data tells the story of a woman who was pregnant six times, each time ending in miscarriage.
Her seventh and most recent pregnancy ended in a live birth.
If we consider this data with empathy, it is natural to be moved by the story it tells.

Each row in the NSFG dataset represents a person who provided honest answers to many personal and difficult questions.
We can use this data to answer statistical questions about family life, reproduction, and health.
At the same time, we have an obligation to consider the people represented by the data, and to afford them respect and gratitude.
"""

# ╔═╡ 5140bcde-af7a-4e36-a6c5-12138ae2d60e
md"""
## Glossary

The end of each chapter provides a glossary of words that are defined in the chapter.

- **anecdotal evidence:** Data collected informally from a small number of individual cases, often without systematic sampling.

- **cross-sectional study:** A study that collects data from a representative sample of a population at a single point or interval in time.

- **cycle:** One data-collection interval in a study that collects data at multiple intervals in time.

- **population:** The entire group of individuals or items that is the subject of a study.

- **sample:** A subset of a population, often chosen at random.

- **respondents:** People who participate in a survey and respond to questions.

- **representative:** A sample is representative if it is similar to the population in ways that are important for the purposes of the study.

- **stratified:** A sample is stratified if it deliberately oversamples some groups, usually to make sure that enough members are included to support valid conclusions. 

- **oversampled:** A group is oversampled if its members have a higher chance of appearing in a sample.

- **variable:** In survey data, a variable is a collection of responses to questions or values computed from responses.

- **codebook:** A document that describes the variables in a dataset, and provides other information about the data.

- **recode:** A variable that is computed based on other variables in a dataset.

- **raw data:** Data that has not been processed after collection.

- **data cleaning:** A process for identifying and correcting errors in a dataset, dealing with missing values, and computing recodes.

- **statistic:** A value that describes or summarizes a property of a sample.

- **standard deviation:** A statistic that quantifies the spread of data around the mean.
"""

# ╔═╡ cb827c2c-fc4b-483b-b93e-518c277a38f9
md"""
## Exercises

The exercises for this chapter are based on the NSFG pregnancy file.
"""

# ╔═╡ b2853ea8-133f-49d5-b93f-5162e041450e
md"""
### Exercise 1.1

Select the `birthord` column from `preg`, print the value counts, and compare to results published in the  codebook at <https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/NSFG/Cycle6Codebook-Pregnancy.pdf>.
"""

# ╔═╡ 6a21a338-989e-444a-90d2-56c8cc524e98
value_count(preg, :birthord)

# ╔═╡ e0c25a40-653f-40a1-a1d0-fec6e08870e0
md"""
### Exercise 1.2

Create a new column named `totalwgt_kg` that contains birth weight in kilograms (there are approximately 2.2 pounds per kilogram).
Compute the mean and standard deviation of the new column.
"""

# ╔═╡ 2bc7d22d-b5f4-4059-9686-65c216129dba
begin
	preg.totalwgt_kg .= preg.totalwgt_lb ./ 2.2
	mean(skipmissing(preg.totalwgt_kg)), std(skipmissing(preg.totalwgt_kg))
end

# ╔═╡ 286b0da2-5712-42c9-ac05-9fbe80a30906
md"""
### Exercise 1.3

What are the pregnancy lengths for the respondent with `caseid` 2298?
"""

# ╔═╡ 76bb2ce1-230d-4c4e-ad76-d721f3751c6f
begin
	caseid_subset = subset(preg, :caseid => ByRow(==(2298)))
	caseid_subset.prglngth
end

# ╔═╡ 01eb6beb-7620-4465-bf1d-b0f79a7a7ba8
md"""
What was the birth weight of the first baby born to the respondent with `caseid` 5013?
Hint: You can check more than one condition in `subset`.
"""

# ╔═╡ d8b78d8d-bcf9-4617-baa7-61804c74d20d
begin
	caseid_subset2 = subset(preg, :caseid => ByRow(==(5013)))
	caseid_subset2.totalwgt_lb
end

# ╔═╡ fa97a213-7f28-4664-9249-b745f4bc8496
begin
	caseid_subset3 = subset(preg, :caseid => ByRow(==(5013)), :birthord => ByRow(==(1)); skipmissing=true)
	caseid_subset3.totalwgt_lb
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DuckDB = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
DataFrames = "~1.8.2"
DuckDB = "~1.5.2"
FreqTables = "~1.0.0"
PrettyTables = "~3.3.2"
StatsBase = "~0.34.10"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "7c7f2e8a364483e609ce07a50159339b3739416f"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitIntegers]]
deps = ["Random"]
git-tree-sha1 = "091d591a060e43df1dd35faab3ca284925c48e46"
uuid = "c3b6d118-76ef-56ca-8cc7-ebb389d030a1"
version = "0.3.7"

[[deps.CategoricalArrays]]
deps = ["Compat", "DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "a6f644eb7bbc0171286f0f3ad1ffde8f04be7b83"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "1.1.0"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysArrowExt = "Arrow"
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStatsBaseExt = "StatsBase"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    Arrow = "69666777-d1a9-59fb-9406-91d4454c9d45"
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.Combinatorics]]
git-tree-sha1 = "c761b00e7755700f9cdf5b02039939d1359330e1"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.1.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "a444404b3f94deaa43ca2a58e18153a82695282b"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.6.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5fab31e2e01e70ad66e3e24c968c264d1cf166d6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.8.2"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e86f4a2805f7f19bec5129bc9150c38208e5dc23"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.4"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.DuckDB]]
deps = ["DBInterface", "Dates", "DuckDB_jll", "FixedPointDecimals", "Tables", "UUIDs", "WeakRefStrings"]
git-tree-sha1 = "656133510fa02a4f70a9d3ce6c1d083318406550"
uuid = "d2f5444f-75bc-4fdf-ac35-56f514c445e1"
version = "1.5.2"

[[deps.DuckDB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4f4bc0e8be87d6ab270a07caa182808958bff9fe"
uuid = "2cbbab25-fc8b-58cf-88d4-687a02676033"
version = "1.5.2+0"

[[deps.FixedPointDecimals]]
deps = ["BitIntegers", "Parsers"]
git-tree-sha1 = "41d3a5de0eab320cc04833a373f0fcb3640073d5"
uuid = "fb4d412d-6eee-574d-9565-ede6634db7b0"
version = "0.6.5"

[[deps.FreqTables]]
deps = ["CategoricalArrays", "Missings", "NamedArrays", "Tables"]
git-tree-sha1 = "a2f24a17652beedaac07ce78f4c985a52c76d005"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "1.0.0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "OrderedCollections", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "33d258318d9e049d26c02ca31b4843b2c851c0b0"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.10.5"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "5d5e0a78e971354b1c7bff0655d11fdc1b0e12c8"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.4"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "REPL", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "624de6279ab7d94fc9f672f0068107eb6619732c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "3.3.2"

    [deps.PrettyTables.extensions]
    PrettyTablesTypstryExt = "Typstry"

    [deps.PrettyTables.weakdeps]
    Typstry = "f0ed7684-a786-439e-b1e3-3b82803b501e"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "ebe7e59b37c400f694f52b58c93d26201387da70"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.9"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "d05693d339e37d6ab134c5ab53c29fce5ee5d7d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.4"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "0716e01c3b40413de5dedbc9c5c69f27cddfddfc"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╟─677f5480-505b-11f1-b267-dbcddb2e318a
# ╠═af551046-78fc-4eeb-a181-b7bdcdefaf41
# ╟─44b6f067-6165-4f58-985f-bb2acffbdce8
# ╟─4b56de0b-4590-4213-b0b4-c0c69a547a65
# ╟─c14ce053-4b33-47bb-9aac-88bf2356fe18
# ╟─3189c39b-8960-4333-8daf-149aadd01e75
# ╟─bc83e00e-e344-4e47-8c06-b665bc6022ee
# ╟─20266e29-f8de-4ec0-a425-f776aa18cb84
# ╟─5bb0184b-f6fc-41bf-9513-764614010bba
# ╟─9e8fa107-852a-4941-a47d-8a9f87a5e966
# ╟─16eea539-4a76-4b4f-b72b-fcdeb39706c2
# ╟─cb57b720-b44f-4a90-91f6-f720bfb6e750
# ╠═4ece36ad-7e91-4813-9df6-9e52ffec50d1
# ╟─e54c5cef-cd40-4f36-8448-886634a057c9
# ╠═7df534fb-c8d3-4713-b18c-320f65ec4402
# ╟─5a52ca6b-cd3f-4d00-8059-0a6c1be81b28
# ╠═74f771bf-ea3f-4304-b906-db1af157d8db
# ╟─735483b8-b973-4397-bd38-2f0c26d54c12
# ╠═f13c4f8d-e6b4-4464-af61-36cdcb4e1cf8
# ╟─869c857e-6966-4ea6-8ce2-027a699889d8
# ╠═968fe9b1-0563-4bf7-81f9-4eae4c7554a8
# ╟─3ad12d42-b66e-4038-9502-d2f5d1bf2439
# ╠═71e71b1d-fe3d-4d5a-9416-52d5c34f74b5
# ╟─e7cb6627-f8f5-4f0b-ba66-214e77762304
# ╠═bd3ac994-39fc-4373-af95-26d8bfe00f14
# ╟─86224fd7-6ea9-4631-9f8c-ebaa7e67bb25
# ╟─74d76945-68ee-4614-b7ea-6df4232657b0
# ╟─43828f7a-3520-4ab9-87d8-7a9a377a9aaa
# ╠═c2d66bb3-b4e9-4077-b3b6-5f9024c75db8
# ╟─ca4acb04-cb24-4c8c-ac37-9ff437794a3e
# ╠═d3b078d7-5371-4b45-a228-bec5a8468419
# ╟─226221b3-790a-4e5a-90fd-9de594150278
# ╠═5c0bac4e-ca00-42b0-aa2b-296cba497d8c
# ╟─b9a5b31c-fe85-4861-a54a-1589f8e9d635
# ╠═5525e5d3-178f-4ab4-8f82-74aa0b3c26be
# ╟─aafe6403-c5f6-4e53-b1b6-d4c38922d9dd
# ╠═94cfd5b6-bbad-4230-918d-f50f37e887bd
# ╟─87f99a44-4d7d-45d0-b204-fa69a8a56d81
# ╠═5f71700d-2411-45f8-a86c-4498c1567fb8
# ╟─9e713fbf-33c4-4116-aee9-1c2a7f01d49f
# ╠═46859437-75dc-467e-a253-21acb259d4c5
# ╟─9ff6af0a-731e-4ca9-b4e8-a5b7259220cb
# ╟─4b3b445c-abd8-45c9-86ea-dd288331a405
# ╠═07de27eb-e76b-48fb-9322-3a261c69a31e
# ╟─e09c18c9-3be1-433d-8bc4-836e918d2c14
# ╠═35527bc3-7709-412b-ad83-7f3e474448a9
# ╟─5888a990-c111-436f-8794-162d8cc16eee
# ╠═fb7731de-5e45-4970-af04-1924e8f7efec
# ╠═5d860658-e2a3-4051-8050-8e72e6ca65dd
# ╟─8f693559-0b53-4c10-af98-39b0ae3552ee
# ╠═ac887072-255c-414d-8016-6622003596ad
# ╟─a7ffb334-e67b-4fac-847a-fc524b2c800b
# ╟─354f71c9-a97d-44f6-b910-d786face39b9
# ╠═32e7157a-55a2-44e5-8698-53976c1ed8ef
# ╟─e65f25a8-3933-48c3-af2a-df337786fb3d
# ╠═4fc1b649-2772-4791-ab9b-b0fa8a5167f6
# ╟─f677fce1-e889-4ae2-b84b-525319603232
# ╠═bbf95602-7ec8-48aa-b396-1a1f59345b31
# ╟─5d259727-9c72-4c60-96d9-bade4b80c0e9
# ╠═77f6521f-cbb6-434a-8fca-bfb693908153
# ╟─6c12455c-ab2e-4b65-9bbe-629e9c634c97
# ╠═326e1b11-f75f-4ce3-a49d-37c799a4f4b8
# ╟─5447f54e-33cc-4357-bd41-23b75a8843fe
# ╠═9372071f-7663-45c3-91e9-d6a2e3ead6a5
# ╟─5db9852a-6816-4337-8627-bb0d940981d3
# ╠═636eabf3-eb35-4861-ae17-63277f596494
# ╟─c3038f3a-1ef1-44ed-baa6-735cc930c845
# ╠═87022048-e786-4758-9c04-5b4c9ffd6439
# ╟─7d65569e-ece5-4dd4-85f4-be7f4d0d9be7
# ╠═90bbda04-e00c-4bc2-a7fa-34e9efedb13a
# ╟─cad40632-b3f9-484c-a2a2-07d2f20b3d0a
# ╟─6c2fbb9a-013a-48e4-a85c-09d6e54f65ac
# ╠═44a55052-8605-4c8c-87f3-4afa104d2599
# ╟─3d58f064-3d9f-486d-a13a-6e36d4984258
# ╠═6e33233f-36ff-48ab-bd5c-729e5da36d1b
# ╟─bf78f9f1-cf51-4a1a-ab1f-745332be8f62
# ╟─5140bcde-af7a-4e36-a6c5-12138ae2d60e
# ╟─cb827c2c-fc4b-483b-b93e-518c277a38f9
# ╟─b2853ea8-133f-49d5-b93f-5162e041450e
# ╠═6a21a338-989e-444a-90d2-56c8cc524e98
# ╟─e0c25a40-653f-40a1-a1d0-fec6e08870e0
# ╠═2bc7d22d-b5f4-4059-9686-65c216129dba
# ╟─286b0da2-5712-42c9-ac05-9fbe80a30906
# ╠═76bb2ce1-230d-4c4e-ad76-d721f3751c6f
# ╟─01eb6beb-7620-4465-bf1d-b0f79a7a7ba8
# ╠═d8b78d8d-bcf9-4617-baa7-61804c74d20d
# ╠═fa97a213-7f28-4664-9249-b745f4bc8496
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
