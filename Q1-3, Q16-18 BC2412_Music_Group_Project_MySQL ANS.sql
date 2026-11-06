
SELECT listener_id, country_name, age, subscription_tier, primary_device
FROM listener_profiles
WHERE subscription_tier = "Free" AND age between 18 and 30
ORDER BY age DESC, listener_id ASC;


SELECT * FROM track_catalog;

SELECT platform_id, platform_name, subscription_model, lossless_available
FROM platform_catalog
WHERE (subscription_model = "Freemium" or subscription_model = "Subscription") 
	AND lossless_available= "True"
ORDER BY platform_name ASC;

SELECT track_id, track_name, artist_name, genre, explicit
FROM track_catalog
WHERE (explicit = "False" or explicit = "0")
	AND track_name LIKE "%Signal 00%"
ORDER BY track_id ASC;

# Q16
SELECT b.platform_id, b.platform_name, c.subscription_tier, 
	COUNT(*) total_eligible_event_count, 
	COUNT(DISTINCT c.listener_id) number_of_distinct_active_listeners, 
    100*SUM(a.completed)/COUNT(*) completion_rate, 
    100*SUM(a.skipped)/COUNT(*) skip_rate
FROM listening_events a
	JOIN platform_catalog b on a.platform_id = b.platform_id
    JOIN listener_profiles c on a.listener_id = c.listener_id
WHERE (a.completed=0 AND a.skipped=1) OR 
	(a.completed=1 AND a.skipped=0) 
GROUP BY b.platform_id, b.platform_name, c.subscription_tier
HAVING total_eligible_event_count>=100
ORDER BY b.platform_id, c.subscription_tier;

SELECT 
    b.platform_id,
    b.platform_name,
    c.subscription_tier,
    COUNT(*) AS total_eligible_event_count,
    COUNT(DISTINCT c.listener_id) AS number_of_distinct_active_listeners,
    100.0 * AVG(a.completed) AS completion_rate,
    100.0 * AVG(a.skipped) AS skip_rate
FROM listening_events a
JOIN platform_catalog b ON a.platform_id = b.platform_id
JOIN listener_profiles c ON a.listener_id = c.listener_id
WHERE a.completed IN (0, 1) 
  AND a.skipped IN (0, 1)
GROUP BY b.platform_id, b.platform_name, c.subscription_tier
HAVING COUNT(*) >= 100
ORDER BY b.platform_id ASC, c.subscription_tier ASC;

#17
WiTH eligible_listeners AS (
	SELECT b1.listener_id 
		FROM listening_events a1
		JOIN listener_profiles b1 on a1.listener_id = b1.listener_id
	WHERE a1.source_context IN ("Algorithmic Radio", "Personalized Playlist")
	GROUP BY listener_id
	HAVING COUNT(*)>=10),	
listener_level_measures as (
	SELECT c.listener_id, c.country_code, c.subscription_tier,
		COUNT(CASE WHEN a.source_context="Algorithmic Radio" THEN 1 END ) number_of_algortihmic_events,
		COUNT(DISTINCT b.genre) number_of_distinct_genres,
		COUNT(DISTINCT b.artist_id) number_of_distinct_artists
    FROM listening_events a
		JOIN track_catalog b on a.track_id = b.track_id
		JOIN listener_profiles c on a.listener_id = c.listener_id
    WHERE c.listener_id IN (SELECT listener_id FROM eligible_listeners)
    GROUP BY c.listener_id, c.country_code, c.subscription_tier
    )
SELECT country_code, subscription_tier,
	COUNT(DISTINCT listener_id) number_of_eligible_listeners,
	AVG(number_of_algortihmic_events) avg_number_of_algortihmic_events,
    AVG(number_of_distinct_genres) avg_number_of_distinct_genres,
    AVG(number_of_distinct_artists) avg_number_of_distinct_artists
FROM listener_level_measures
GROUP BY country_code, subscription_tier
ORDER BY country_code, subscription_tier
;

#18
SELECT a.listener_id, b.country_code, b.subscription_tier,
	COUNT(a.saved) saved_event_count, 
    COUNT(DISTINCT a.track_id) number_of_distinct_tracks_saved
FROM listening_events a JOIN listener_profiles b 
	ON a.listener_id=b.listener_id
WHERE a.saved=1 AND 
	NOT EXISTS (SELECT 1
    FROM playlist_interactions c 
    WHERE a.listener_id=c.listener_id AND c.removed_later = 'False'
    )
GROUP BY a.listener_id, b.country_code, b.subscription_tier
ORDER BY saved_event_count DESC, a.listener_id
;

SELECT DISTINCT listener_id FROM listening_events;

SELECT * FROM listening_events WHERE completed NOT IN (0,1)
	OR skipped NOT IN(0,1);
SELECT * FROM listener_profiles;
SELECT removed_later FROM playlist_interactions WHERE removed_later  IN("True", "False");