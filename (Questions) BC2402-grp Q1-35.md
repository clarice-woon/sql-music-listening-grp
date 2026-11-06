## **Questions**

# **Basic questions: Q1 to Q15**

# ***These questions assess simple query construction. Each uses one table or collection.*** 

## Q1. Young Free-tier listeners in Singapore

## *listener\_profiles*

## Identify listeners in Singapore who are on the Free subscription tier and are between 18 and 30 years old, inclusive. Display listener\_id, country\_name, age, subscription\_tier and primary\_device. Sort by age from highest to lowest, then by listener\_id in ascending order.

## Q2. Lossless platform options

## *platform\_catalog*

## Identify platforms whose subscription\_model is either Freemium or Subscription and whose lossless\_available value is True. Display platform\_id, platform\_name, subscription\_model and lossless\_available. Sort by platform\_name in ascending order. The value True in this field is stored as text, not as a Boolean.

## Q3. Non-explicit catalogue search

## *track\_catalog*

## Find non-explicit tracks whose track\_name contains the text Signal 00\. Treat both False and 0 as non-explicit values in the explicit field. Display track\_id, track\_name, artist\_name and genre. Sort by track\_id in ascending order. Both non-explicit values are stored as text in the supplied files.

## Q4. Retained algorithmic and editorial additions

## *playlist\_interactions*

## Count playlist-interaction records whose source\_type is Algorithmic or Editorial and whose removed\_later value is False. Return the count as retained\_additions. Count interaction records, not distinct playlists, tracks or listeners. For this question, retained means only that the supplied removed\_later flag is False.

## Q5. Listener profile by country

## *listener\_profiles*

## For each country, report country\_code, country\_name, the number of listener profiles and average age. Sort by the number of listeners from highest to lowest, then by country\_code in ascending order. Each profile represents one listener.

## Q6. Genres represented in the catalogue

## *track\_catalog*

## Return the distinct genre values represented in the track catalogue. Display one row per genre and sort alphabetically. Do not count tracks or use listener preferences as a substitute for catalogue genres.

## Q7. Mobile listeners who have opted into marketing

## *listener\_profiles*

## Identify listeners whose primary\_device is Mobile, whose marketing\_opt\_in value is True, and whose subscription\_tier is not Free. Display listener\_id, country\_code, subscription\_tier and primary\_device. Sort by country\_code and then listener\_id in ascending order. Treat the marketing flag as text.

## Q8. Older listeners with autoplay disabled

## *listener\_profiles*

## Identify listeners aged 50 to 69, inclusive, whose autoplay\_enabled value is False. Display listener\_id, country\_code, age and primary\_device. Sort by country\_code in ascending order, age from highest to lowest, and listener\_id in ascending order. Use the recorded age and text flag without inferring listening behavior.

## Q9. Missing or unknown track energy values

## *track\_catalog*

## Find tracks whose energy field is an empty string, the text unknown, or NULL. In MongoDB, also include a document if the energy field is absent. Display track\_id, track\_name, artist\_name and the original energy value when present. Sort by track\_id in ascending order. This question identifies only the specified missing-value markers; do not attempt to repair or classify other values.

## Q10. Completed mobile plays from search

## *listening\_events*

## Find listening events whose source\_context is Search, device\_type is Mobile, network\_type is WiFi, and completed flag equals 1\. Include numeric 1 and text "1" where applicable. Display event\_id, listener\_id, track\_id and platform\_id. Sort by event\_id in ascending order. Use the completion flag; timestamp and duration parsing are not required.

## Q11. Official single releases in selected markets

## *release\_metadata*

## Find release-metadata records whose status is Official, primary\_type is Single, and release\_country is SG or JP. Display track\_id, release\_title, release\_country, primary\_type and status. Sort by release\_country and then track\_id in ascending order. The country refers to the release record, not the listener or the artist.

## Q12. Artists with substantial tagging activity

## *artist\_tags*

## For each artist\_id and artist\_name combination, count the number of tag-event records. Return artists with at least 50 tag events, displaying artist\_id, artist\_name and tag\_event\_count. Sort by tag\_event\_count from highest to lowest, then artist\_id in ascending order. Count tag records, not distinct tag words or listeners; no tag-text cleaning is required.

## Q13. Evening and night survey notes mentioning calm

## *wellbeing\_surveys*

## Find survey records whose time\_of\_day is evening or night and whose notes contain the text calm. Display survey\_id, listener\_ref, time\_of\_day, listening\_context and notes. Sort by survey\_id in ascending order. Use the supplied time-of-day label without reconstructing it from the timestamp.

## Q14. Survey coverage by context and time of day

## *wellbeing\_surveys*

## For each listening\_context and time\_of\_day combination, count the number of survey records. Display listening\_context, time\_of\_day and survey\_count, sorted by listening\_context and then time\_of\_day in ascending order. Include all survey records, even when an unused score field is invalid. Count responses rather than distinct people.

## Q15. Genre coverage in Singapore artist metrics

## *artist\_monthly\_metrics*

## Using only records for Singapore (country\_code SG) in 2025, count monthly artist-metric records by genre. Display genre and metric\_record\_count. Sort by the count from highest to lowest, then genre in ascending order. Match the year in its stored numeric or text form as appropriate. These are counts of monthly records, not total streams or unique artists.

# **Intermediate questions: Q16 to Q30**

# ***These questions assess the combination of taught operations. State the output unit, join keys and counting logic. Check that joining does not multiply records or unintentionally omit required listeners.***

## Q16. Engagement by platform and subscription tier

## *listening\_events \+ platform\_catalog \+ listener\_profiles*

## Compare engagement across platform and subscription-tier combinations. For each combination, report platform\_id, platform\_name, subscription\_tier, total eligible event count, number of distinct active listeners, completion rate and skip rate. Include only combinations with at least 100 eligible events. Sort by platform\_id and subscription\_tier in ascending order.

## An event is eligible when both completed and skipped can be interpreted as 0 or 1\. Compute each rate as 100 times the average of the relevant binary flag. Use the subscription tier in listener\_profiles as a supplied profile attribute, not as a historical record of the listener’s plan on a particular platform. Count each event once after joining.

## Q17. Breadth of algorithmic listening

## *listening\_events \+ track\_catalog \+ listener\_profiles*

## Among listeners with at least 10 recorded events from Algorithmic Radio or Personalized Playlist, compare listening breadth by country\_code and subscription\_tier. For each eligible listener, first calculate the number of these algorithmic events, the number of distinct genres heard and the number of distinct artists heard. Then report, for each country-tier combination, the number of eligible listeners and the average of each of these three listener-level measures. Sort by country\_code and subscription\_tier in ascending order.

## Apply the 10-event requirement to the two specified source contexts only. Identify artists using artist\_id. Each eligible listener must contribute once to the final averages. These records show listening through algorithmic sources, not every recommendation displayed to the listener.

## Q18. Saving without retained playlist additions

## *listening\_events \+ listener\_profiles \+ playlist\_interactions*

## Identify listeners who have at least one listening event with saved equal to 1 but have no playlist-interaction record with removed\_later equal to False. Display listener\_id, country\_code, subscription\_tier, saved-event count and number of distinct tracks saved. Sort by saved-event count from highest to lowest, then by listener\_id in ascending order.

## Test for the absence of any retained playlist addition by that listener, not merely the absence of the particular saved track. A listener with no playlist-interaction records qualifies. A listener whose playlist-interaction records are all marked removed also qualifies. Avoid multiplying saved-event counts when joining playlist records.

## Q19. Listener-weighted engagement by age band

## *listening\_events \+ listener\_profiles*

## Compare listening activity across the age bands 18 to 24, 25 to 34, 35 to 49, and 50 to 99\. First calculate each listener’s eligible event count and completion rate. Then report, for each age band, its lower bound as age\_band\_start, number of listeners, total eligible events, average eligible events per listener and mean listener completion rate. Sort by age\_band\_start in ascending order.

## Use only listeners aged at least 18 and below 100 with at least one event whose completed flag is interpretable as 0 or 1\. Give each listener equal weight when averaging completion rates; do not substitute the pooled event completion rate. Omit empty bands. Use fixed, lower-inclusive and upper-exclusive boundaries \[18, 25, 35, 50, 100\], not automatically generated buckets.

## Q20. Tracks above their genre completion benchmark

## *listening\_events \+ track\_catalog*

## Identify tracks whose completion rate is above the average completion rate of eligible tracks in the same genre. A track is eligible when it has at least 50 events with a completed flag interpretable as 0 or 1\. Calculate an event-based completion rate for each eligible track, then take the simple, unweighted average of those track rates within each genre. Include the focal track when calculating its genre benchmark.

## Display track\_id, track\_name, artist\_name, genre, eligible event count, track completion rate, genre mean completion rate and the difference in percentage points. Return only tracks strictly above their benchmark. Sort by genre in ascending order, the difference from highest to lowest, then track\_id in ascending order. A within-genre rank is not required.

## Q21. Listening outside the preferred genre

## *listening\_events \+ track\_catalog \+ listener\_profiles*

## Identify listeners with at least 10 eligible events outside their recorded preferred\_genre and at least three distinct other genres in those events. An event is eligible when its completed flag is interpretable as 0 or 1 and its track genre differs from the listener profile preference.

## Display listener\_id, country\_code, preferred\_genre, out\_of\_preference\_events, distinct\_other\_genres and completion\_rate\_pct for the qualifying events only. Sort by out\_of\_preference\_events from highest to lowest, then listener\_id in ascending order. Compare the two genre fields after joining; do not compare against a fixed genre or treat a profile preference as the listener’s entire listening history.

## Q22. Sharing with a retained addition for the same listener and track

## *listening\_events \+ playlist\_interactions \+ track\_catalog*

## Identify sharing events whose listener has at least one retained playlist-addition record for the same track. A sharing event has shared equal to 1; a retained addition has removed\_later equal to False. A retained addition of another track by that listener does not qualify.

## For each qualifying track, display track\_id, track\_name, artist\_name, shared\_event\_count and distinct\_sharing\_listeners. Sort by shared\_event\_count from highest to lowest, then track\_id in ascending order. Count each sharing event once even when several matching playlist records exist. This is a co-occurrence test across the supplied records, not a claim that sharing preceded or caused a playlist addition.

## Q23. Listening and playlist inventories for every listener

## *listener\_profiles \+ listening\_events \+ playlist\_interactions*

## Produce one row for every listener profile, including listeners with no matching activity. Display listener\_id, country\_code, subscription\_tier, event\_count and retained\_addition\_count. Count all listening-event records and playlist-interaction records with removed\_later equal to False for that listener. Return zero for an absent activity type. Sort by listener\_id in ascending order.

## The two activity counts must remain independent. A listener with 20 events and four retained additions must have counts 20 and four, not 80\. Use duplicate-safe outer joins or keep the two matched collections separate when counting; do not count a missing outer-join record as an event.

## Q24. Listeners using both social and algorithmic discovery

## *listening\_events \+ listener\_profiles*

## Identify listeners with at least three social-source events and at least 10 algorithmic-source events. Social sources are Social Media and Friend Share. Algorithmic sources are Algorithmic Radio and Personalized Playlist. Apply the thresholds separately to the two sets of contexts.

## Display listener\_id, country\_code, subscription\_tier, social\_event\_count and algorithmic\_event\_count. Sort by listener\_id in ascending order. Count event records, not distinct contexts or tracks. Keep the two source-specific counts separate before testing whether a listener meets both requirements.

## Q25. Retained playlists with broad musical coverage

## *playlist\_interactions \+ track\_catalog*

## For each playlist\_id, summarize only interaction records with removed\_later equal to False. Identify playlists containing at least six distinct tracks from at least four distinct genres in those retained records.

## Display playlist\_id, retained\_addition\_count, distinct\_tracks, distinct\_artists, distinct\_genres and contributing\_listeners. Identify artists by artist\_id and contributors by listener\_id. Sort by distinct\_genres from highest to lowest, distinct\_tracks from highest to lowest, then playlist\_id in ascending order. Repeated addition records count toward retained\_addition\_count but must not inflate the distinct counts. Do not assume that every contributor owns the playlist.

## Q26. Artist tagging and listening overlap

## *artist\_tags \+ listening\_events \+ track\_catalog*

## For each artist, consider only listeners who have both tagged that artist and have at least one listening event for any track by that artist. Return artists with at least five such listeners. Display artist\_id, artist\_name, participating\_listeners and tag\_event\_count, where tag\_event\_count counts the artist’s tag records contributed by those qualifying listeners.

## Sort by participating\_listeners from highest to lowest, then artist\_id in ascending order. Deduplicate listening to one listener-artist pair before combining it with tag records, or use an equivalent existence test. Multiple plays must not multiply a tag record. No cleaning of tag\_name is required, and no temporal order between tagging and listening is implied.

## Q27. Artist market reach and catalogue coverage

## *artist\_monthly\_metrics \+ track\_catalog*

## For 2025, first total streams for each artist-country combination across all relevant monthly records. A country qualifies for that artist when this annual total is at least 1,000. For each artist represented in track\_catalog and with at least one qualifying country, report artist\_id, artist\_name, qualifying\_country\_count, streams\_in\_qualifying\_countries and catalogue\_track\_count.

## Sort by qualifying\_country\_count from highest to lowest, streams\_in\_qualifying\_countries from highest to lowest, then artist\_id in ascending order. Aggregate artist-country streams before joining the track catalogue so that an artist’s multiple tracks do not multiply the totals. The stream total includes qualifying countries only. Do not sum monthly unique\_listeners and call the result annual unique listeners.

## Q28. Engagement with official releases by release market

## *listening\_events \+ track\_catalog \+ release\_metadata*

## Analyze listening to tracks whose linked release-metadata status is Official. Join the track catalogue to release metadata using musicbrainz\_recording\_id. For each release\_country and genre combination, report event\_count, distinct\_tracks, distinct\_listeners and completion\_rate\_pct. An event is eligible when completed is interpretable as 0 or 1\. Include combinations with at least 100 eligible events.

## Sort by release\_country and genre in ascending order. Count each eligible event once. The market dimension comes from release\_metadata.release\_country, not listening\_events.country\_code or a claim about artist nationality. Check that the metadata join is one-to-one for the recording identifiers used.

## Q29. One listening leader per genre

## *listening\_events \+ track\_catalog*

## For each genre, identify the track with the largest number of listening-event records among tracks with at least 50 events. If two tracks have the same event count, choose the track with the smaller track\_id in ascending order. Return one row per represented eligible genre.

## Display genre, track\_id, track\_name, artist\_name, event\_count and distinct\_listeners. Sort by genre in ascending order. Count all recorded events without filtering completion. Implement the per-genre selection using taught operations, such as a grouped SQL result with an existence test and a MongoDB pipeline that sorts, groups, stores rows in an array and selects the first element. A ranking function is not required.

## Q30. Repeated listening to the same track across platforms

## *listening\_events \+ listener\_profiles \+ track\_catalog*

## For each listener-track-platform combination, count listening-event records. Retain platform combinations with at least two events. Then identify listener-track pairs with at least two qualifying platforms.

## Display listener\_id, country\_code, track\_id, track\_name, artist\_name, qualifying\_platform\_count and events\_on\_qualifying\_platforms. Sort by qualifying\_platform\_count from highest to lowest, events\_on\_qualifying\_platforms from highest to lowest, then listener\_id and track\_id in ascending order. Sum only events from qualifying platforms. This question defines repeated listening from recorded event counts; it does not require repeat\_play equal to 1, a chronological sequence or proof of cross-platform migration.

## What makes an intermediate solution complete?

## Submit the queries, the requested outputs and a short interpretation. Explain how duplicate counts, group eligibility and denominators are handled. In Q19, distinguish listener-weighted from event-weighted averages. In Q20, distinguish an average of track rates from a pooled genre rate. Use taught query operations rather than adding unnecessary statistical or date-processing requirements.

## **Advanced questions: Q31 to Q35**

## *These questions do not have a single prescribed query or conclusion. For each question, define a focused investigation, identify relevant additional data, and meaningfully use those data in both database implementations. The same external dataset may support more than one investigation where that integration is justified.*

## *Document the source, retrieval date, relevant variables, data grain, preparation steps and linkage or comparison method. Synthetic listener, artist and recording identifiers must not be assumed to match public identifiers. Where record-level linkage is not defensible, use a justified aggregate comparison or an explicitly separate benchmark analysis. A list of references without an analytical use of the data is insufficient.*

## Q31. Recommendation concentration and artist equity

## *Possible starting data: listening\_events, track\_catalog, artist\_tags and playlist\_interactions.*

## Under what conditions does music discovery broaden listeners’ choices or concentrate attention on a smaller set of artists? Develop an evidence-based assessment of the implications for listeners and artists. Your group should decide how to represent diversity, concentration and artist equity, which discovery contexts to compare, and what additional data would support a meaningful interpretation.

## Distinguish recorded listening from recommendation exposure. Different definitions of diversity or equity may lead to different conclusions. Explain which claims your evidence can support and which remain unresolved.

## Q32. Listening patterns and wellbeing

## *Possible starting data: wellbeing\_surveys, listening\_events, listener\_profiles and track\_catalog.*

## How might the timing, intensity and context of music listening relate to wellbeing? Develop a focused investigation and assess what recommendations, if any, are justified. Your group should select the outcomes, comparison groups, relevant time horizon and additional data needed to address the question.

## Explain how observations are linked and how repeated surveys, missing values and alternative explanations are handled. Distinguish behavioral associations from causal effects and medical conclusions. Do not assume that the supplied volume\_level is a calibrated measure of sound exposure.

## Q33. Musical transitions across time and markets

## *Possible starting data: artist\_monthly\_metrics, track\_catalog, release\_metadata and listening\_events.*

## How are musical preferences and the characteristics of consumed music changing over time, and what might explain differences across markets or listener groups? Define a meaningful scope, examine the available evidence and identify additional data needed to assess competing cultural, technological, demographic or platform explanations.

## Distinguish changes in listening demand from differences in the catalogue or release cohorts. The supplied artist metrics cover 2023 to 2025 and are synthetic; longer-term or real-market claims require additional evidence.

## Q34. Timing and targeting responsible-listening interventions

## *Possible starting data: listening\_events, listener\_profiles, wellbeing\_surveys and playlist\_interactions.*

## Where, when and for whom should a music platform consider a responsible-listening intervention? Select a substantive objective, such as encouraging breaks, supporting diverse discovery or improving awareness of listening practices. Use the supplied databases and additional data to develop defensible targeting criteria, an intervention proposal and an evaluation plan.

## Explain the trade-offs, safeguards and possible unintended consequences. Separate evidence about an existing usage pattern from assumptions about an intervention’s effectiveness. Any safety, health or age-specific criteria must be supported by appropriate evidence rather than inferred from engagement counts alone.

## Q35. AI-generated music, disclosure and the creative economy

## *Possible starting data: track\_catalog, listening\_events, artist\_monthly\_metrics and release\_metadata.*

## How might AI-generated or AI-cloned music and origin disclosure reshape engagement, trust, musical diversity, artist exposure or compensation? Select a focused comparison, identify the additional evidence required and assess the implications for relevant stakeholders. Your group should determine the measures, data sources and analytical design rather than assume a particular effect.

## The supplied databases do not identify AI origin, voice cloning, disclosure, artist consent, trust or compensation. Do not treat source\_dataset as an AI label. Where observed outcome data are unavailable, clearly distinguish an evidence-informed scenario from an empirical estimate. Any simulated extension must be documented and labelled, and must not replace the requirement to identify and use relevant external data.

## *Notes: When additional datasets are considered, your team must provide formal references/sources to retrieve the original datasets.* 

## *Evaluation will be performed with attention to the coherence of your team’s narrative. A coherent data narrative can be achieved using a focused dataset. A rich, diversified dataset can muddle the narrative if the data is not meaningfully integrated.*