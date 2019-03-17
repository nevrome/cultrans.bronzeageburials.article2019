# Reviewer: 1

## Comments to the Author:

> A lot of work has been already done in quantifying changes in funerary practices during the Bronze Age in central and south-western Europe through the analysis of radiocarbon-dated archaeological contexts. I recommend citing these works in the paper, since the adopted approach is similar.

> -	Capuzzo G, Barceló JA. 2015. Cultural changes in the 2nd millennium BC: a Bayesian examination of radiocarbon evidence from Switzerland and Catalonia. World Archaeology 47 (4) Special Issue: Bayesian approaches to Prehistoric Chronologies:622-641.
> -	Capuzzo G, López Cachero FJ. 2017. De la inhumación a la cremación en el nordeste peninsular: cronología y sociedad. In: Barceló JA, Bogdanovic I, Morell B, editors. Iber-Crono 2016. Cronometrías Para la Historia de la Península Ibérica (Chronometry for the History of the Iberian Peninsula), Barcelona (Spain), 17-19 October 2016:192-208.
> -	Capuzzo G, Barceló JA (in press). Cremation burials in Central and Western Europe: quantifying an adoption of innovation in the 2nd millennium BC. In: Kneisel J, Nakoinz O, Barcelo J, editors. Turning Points and Change in Bronze Age Europe (2400 – 800 BC). Modes of change – inhumation versus cremation in Bronze Age burial rites. Proceedings of the International Workshop "Socio-Environmental Dynamics over the Last 12,000 Years: The Creation of Landscapes IV (24th-27th March 2015) in Kiel. Universitätsforschungen zur Prähistorischen Archäologie 
> -	Capuzzo G. 2014. Space-temporal Analysis of Radiocarbon Evidence and Associated Archaeological Record: from Danube to Ebro Rivers and from Bronze to Iron Ages. Ph.D. thesis, Autonomous University of Barcelona.

I was not aware of this work and added a paragraph in the introduction to reference it. It is indeed relevant.

> In the paper, it’s very high the amount of data, for which the archaeological information regarding the type of burial and funerary rite is lacking. At table 1, page 4, we can clearly detect that for 60% of the dates associated to cremation burials we have no information regarding the type of funerary structure. For 37% of the inhumations, no information about the funerary structure is available. Moreover, for 32% of the dataset (559 radiocarbon dates out of 1701) we do not have any kind of information regarding neither the funerary rite nor the burial structure. This lack of data obliges the author to consider carefully the results reached in the paper. It’s relevant to highlight all the biases of the prosed research and how the conclusion can be misleading due to the quality of available data. In particular, when the statistical analyses carried out on data aim to explore in the details the cultural distance among the different regions.

This is absolutely true and I tried to emphasise the limitations of the data in the discussion. The challenges are not confined on the amount of data, but also concern its meaning and origin. The supplementary remarks are extensively long to cover these problems. Is it necessary to mention the limitations at other critical points of the paper? I'm absolutely open to do that. 

## There are some typing error in the manuscript:

> Line 28 page 2: can be described

Fixed.

> Line 58 page 4: How should the correlation

Fixed.

> Line 2 page 5: Listed are the overall

Fixed.

> I advise the author to review carefully the text.

> At lines 48-50, page 2, the bibliographic reference to Dunnell is missing.

Fixed.

> Regarding the images, it would be preferable not to use negative number in order to indicate years BC.

Done.

# Reviewer: 2

## Comments to the Author:

> I had the chance to read the manuscript entitled “Evaluating Cultural Transmission in Bronze Age burial rites of Central, Northern and North-western Europe using radiocarbon data” authored by C. Schimd. This is an interesting paper that combines empirical analysis of Bronze age burial sites across Europe with a computer simulation of intergroup cultural transmission. The manuscript is well written, I enjoyed reading it, and think that the core findings are definitely of interest for archaeologist working on Bronze age Europe and for those interested in the application of cultural evolutionary framework. I am thus keen to recommend its publication, although I think several issues needs to be addressed before this. 

> Firstly, my impression is that the author is trying to squeeze perhaps a bit too much in a single paper. I felt this was particularly the case of the computer simulation model which is almost thrown in in the mix, without much discussion on model parameters (see below). I would be tempted to suggest removing this entirely and include this into another paper. 

After careful deliberation, I have decided to follow this advice. The simulation (1) does not add information that would be absolutely essential for the core topics, (2) reduces the overall comprehensibility due to the terminology that has to be introduced to describe it and (3) cannot be adequately presented and discussed here without leaving the initial scope of the paper. I will prepare another paper in the future that will present this simulation and other simulation approaches.  
 
> Secondly, I feel like the empirical analyses have too much preprocessing. The raw data provides spatial and temporal coordinates of individual burials, yet these are combined spatially and chronologically first and analysed as aggregates. As a consequence: 1) there is a substantial loss of spatial information; 2) sampling error is effectively disregarded (i.e. mantel tests are based on proportion values that are calculated for regions with very different samples sizes) and strictly speaking the samples are also non-independent (i.e. a large site with multiple burials can strongly bias the proportions of a particular region); and 3) there is an increased risk of ecological fallacy/Simpson’s paradox. I take this aggregation provides a direct mapping to existing literature, but I am not convinced that this is worth sacrificing so much.

> Thirdly, the author implies that the scripts used for his analysis are supplied but there are no links on the article to any repository and I did not find any electronic supplementary material. As the author is well aware, we need to do our best to make our work fully reproducible. 

## Minor points:

> Page 1, Column 2, Lines 52-43: “Do time series ... spatial distance”. I think this question should be phrased better. Eg. What  does “meaningful” mean in this context? 

> Page 2, Column 1, Line 9: “[...] adaptive behaviour”. Not necessarily.

> Page 2, Column 1, Line 15: “explicitly adopted the terminology of Cultural evolution”. This reads as if only the terminology is adopted? Rephrase?
 
> Page 2, Column 1, Lines 58. Not sure what “random dominance of similar traits” means - should be rephrased. 

> Page 3, Column 1, Line 33. Please provide a link to the repository with the code.

> Page 3, Column 2, Lines 40-44. The definition of these regions seems rather arbitrary and necessary. Why create such an artificial unit when the spatial coordinates are available?

> Page 3, Column 2, Line 60. “For the remaining 154 dates...”. I assume these dates were excluded as we don’t know whether they are terrestrial or marine?  Also, the paragraph mentions “bones and teeth”, are there any risks of aquatic diet determining a reservoir effect?

> Page 4, Column 1, Lines 57-59. Why not use directly the summed probabilities?

> Page 4, Columns 1-2, Lines 58-60; 1-8. This is a major issue. Perhaps it is worth bootstrap confidence interval for these proportions? This way both sample size and sample independence could be tackled. Also, please provide the sample size for each region.

> Page 4, Column 2, Lines 43-56. I think it is worth computing partial mantel tests so that the correlation between burial type and construction can take into account geography.

> Page 5, Column 1, Line 24. Perhaps worth making this a subsection?

> Page 5, Column 1, Lines 24-60. I have several issues with this model. The idea here is to emulate the observed data so we can build expectations that can be directly compared against empirical patterns. But I do find several issues: 1) How is Ng=100 justified? This seems a somewhat arbitrary number for a parameter that is likely going to play a significant role in the amount of drift in the system? 2) I understand each time-step is 20 years. Why? I assume this is related to generation length but this ought to be discussed; 3) Is the model supposed to reach an equilibrium state? If this is the case I don’t think 70 time-steps and Ng=100 is sufficient for this. If the answer is no, the initial condition of the system shouldn’t be random and perhaps be informed from the empirical data. 

> Figure 3. These are very nice plots - I would add the sample sizes for each region though.

> Figure 6. I find these plots a bit messy and with too much information. I also don’t see much the point of testing for significance the results of each simulation run - they are effectively samples from the same generative process so I think testing them does not make much sense?

Figure 6 is much simpler now without simulation results. It only contains a time series of distance correlation. 
