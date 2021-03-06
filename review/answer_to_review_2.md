# Reviewer: 1

Comments to the Author:

> The methods adopted in the paper are very innovative and have been rarely implemented to analise large 14C-dates datasets. I am strongly conviced of the quality of the manuscript, that has improved in this second version.

Great!

> Only a small remark, the publication year of the paper "Capuzzo G, Boaretto E, Barceló JA" is 2014.

Fixed.

# Reviewer: 2

Comments to the Author:

> I read the revised version of the manuscript and I think the authors have addressed most of the issues I raised, and acknowledged others in the text. I am still unconvinced by the creation of the artificial subsets and think that perhaps using temporal distance matrix (see for example Shennan et al 2015 on Evolution and Human Behaviour) might have been a solution, but I also see the point that such approach would not directly explore time-series. Ultimately this is an instance of the so-called MAUP (Modifiable Areal Unit Problem) in geography, and perhaps there are some more nuanced approaches out there. I think for the purpose of this paper acknowledging the problem is more than sufficient.   

Thank you very much for your review. You gave me some great ideas how this problem could be approached in a better way and your review will be the first thing I will go to, when I have the opportunity to continue the work on this front. For measuring the degree of interaction in a better way and without artificial regions, I recently got some inspiration from a paper by Loog et al 2017:

Loog, L., Lahr, M. M., Kovacevic, M., Manica, A., Eriksson, A., & Thomas, M. G. (2017). Estimating mobility using sparse data: Application to human genetic variation. Proceedings of the National Academy of Sciences, 114(46), 12213–12218. https://doi.org/10.1073/pnas.1703642114

Two major take aways: (1) Their mobility estimator could be used for a better, region independent statistic for the general degree of interaction. (2) I could as well use a moving window instead of 200 years time slices (Figure 6).

I added some sentences in the conclusion to give an outlook on future work.

> I also still have some issues with how sample size is effectively being ignored once proportions are computed, and I think this should be emphasised more strongly as I expect not everyone would be reading beyond the conclusion section.

I made some major changes to the conclusion to make this very clear.

> Please find below some further minor comments on the revised text. Overall, I think this is a great piece of work and I will look forward to follow-ups, including the simulation work that was excluded from this manuscript.

> Page 2, Column 1, Line 29. ‘simplify survival’ → increase?

Rephrased.

> Page 2, Column 1, Line 42. ‘seemlingly random’  This is one of those tricky phrasing that has different meaning depending on the readership. ‘Random’ to me almost equals to unbiased transmission with drift, and stating that it is ‘seemlingly’ reads as if in reality this is not the case. This is perfectly fine, but it is slightly at odds with the definition of ‘style’ and the implicit assumption of neutrality. I would consider rephrasing, just to avoid potential misunderstandings.

You're right. I thought a lot about this and finally decided to simply remove the term "seemlingly random". In my opinion the binary distinction between style and function reaches its limit with burial traditions. In many cultural contexts, death and funerals are strongly reflected. Much more thought is given to this than to patterns on pots. The simulation paper will have to look at this difference more carefully, because there the neutrality is an even more important assumption.

> Page 2, Column 2, Line 41. the definition of drift here is more focused on its consequence. The fixation scenario presented applies only in regimes with no mutation/innovation. Perhaps specify that with no innovation a single trait will dominate by chance alone due to chance alone?

Rephrased. Added the important "no mutation or innovation" conditions.

> Page 3, Column 1, Lines 2-6. Great!

> Page 3, Column 2, Line 59. ‘the region are circular’ Why this shape if it causes overlap? Why not hexagons?

This is true. I added a sentence to point this out. For this paper I will use the established regions, because changing them at this point would render the area discussions useless. In the future more data might be available and it should be possible to establish an a lot more fine grained, hexagonal or rectangular region grid.

> Page 5, Figure 3. Just an idea for a follow-up study. Given these are effectively adoption curves, one could fit a logistic model to assess differences in the rate of adoption and estimates on the timing of earliest uptake. It would be also very interesting to determine whether indeed there is a long-tail in southern Germany and what this means (cf. Henrich 2001 on American Anthropologist, but see also recent debates on adoption curves, e.g. https://www.biorxiv.org/content/biorxiv/early/2017/11/16/159038.full.pdf). Food for thoughts.

Well noted. Thank you! Incidentally for Southern Germany there is a paper by Frank Falkenstein that reconstructed the adoption rate of these burial traditions based on archaeologically dated graves:

Falkenstein, F. (2017). Zum Wandel der Bestattungssitten von der Hügelgräber- zur Urnenfelderkultur in Süddeutschland. In Brandherm, D. and Nessel, B., editors, Phasenübergänge Und Umbrüche Im Bronzezeitlichen
Europa, number 297 in UPA, pages 77–96. Bonn.
https://www.academia.edu/36327050/Zum_Wandel_der_Bestattungssitten_von_der_H%C3%BCgelgr%C3%A4ber-_zur_Urnenfelderkultur_in_S%C3%BCddeutschland

> Page 5, Column 1, Lines 56-. Please specify the R package used for the Mantel and Partial Mantel Tests.

Done. ecodist::mantel()

> Page 5. I still think a permutation test would be more robust in this case. One could compare the observed correlation between two pairs of proportion time series against a simulation set where each iteration is the measured correlation between the proportion time-series of two artificial sets generated by randomly permuting the location label of each radiocarbon date. Pairs with a smaller number of dates will generate a wider range of correlation values and will be harder to test. One could adopt a more sophisticated solution by permuting groups of dates that occurred together in order to handle sample interdependence. Might be worth considering doing this for a follow-up study.

Well noted for the follow-up study. I also mention this approach now in the conclusion.

> Page 6, Column 2, Lines 46-49. ‘If one believes the sample, then a sudden, radical change from burial in flat graves to hill graves took place in Southern Germany at the beginning of the Middle Bronze Age.’  The sample size here is 8 dates. I appreciate the cautionary ‘if one believes the sample’ but this is a bit of a stretch to say the least, and readers that are numerically less literate might be misled. The same applies to other contexts with extremely small sample sizes and I think adding confidence intervals to those proportions would help.

I modified the small, introductory paragraph of this section to make it clear, that this is a thought experiment based on a very small amount of data. I also set the narrative in italics.

> Table 3 & Figure 6. The figure nicely summarises the trend detailed on Table 3, but does not distinguish instances where the correlation were identified as signficant vs those that were not. Indeed in no cases the analysis shows a signficant correlation under the Partial Mantel test, whilst only few chronological blocks are showing signficant correlations. I suggest highlighting this by perhaps changing the the point symbology. It is also worth noting that if anything there is a bias towards type I error given: a) that we are dealing with multiple testing; and b) these analyses do not take into account sample sizes which are often very small. P-values are not the core issue here, but rather the fact that some way to at least visually convey this uncertainty is much needed. 

To address this issue I modified Figure 6. I added...

1. ... an additional graph Figure 6 A that shows the medians (with an lower to upper quartile range ribbon) of the graves per year and region.

2. ... an indication of the mean of this medians for each 200 years time window in Figure 6 B. The square markers show, on how much data the correlation observations are based.

3. ... an indication of the p-Values in Figure 6 B to show which correlations are significant.

I also modified the description of this figure in the Materials and Methods as well as in the Results and the Discussion sections accordingly. I believe these changes are sufficient to visually convey the underlying uncertainty.

> Page 11, Column 1, line 54. Yes, but none of the negative correlation are statistically signficant!

Rephrased to address this.
