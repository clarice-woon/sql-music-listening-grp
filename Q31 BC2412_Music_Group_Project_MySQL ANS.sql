#listening_events, track_catalog, artist_tags and playlist_interactions.
SELECT DISTINCT tag_name FROM artist_tags;
SELECT * FROM listening_events;
#1. See which sources have greater outreach to large group of listeners
# See which source focuses attention on smaller group of artists
# unique tracks, genres and artists are the same as different music discover sources do draw from the same list of songs, what differs is the freunecy and proportion they are played in.
SELECT
    le.source_context,
    COUNT(*) AS total_events,
    COUNT(DISTINCT le.listener_id) AS unique_listeners,
    COUNT(DISTINCT le.track_id) AS unique_tracks,
    COUNT(DISTINCT tc.genre) as unique_genres,
    COUNT(DISTINCT tc.artist_id) as unique_artists
FROM listening_events le JOIN track_catalog tc 
	ON le.track_id = tc.track_id
GROUP BY source_context
ORDER BY total_events DESC;

#CHECK
SELECT
COUNT(DISTINCT le.track_id) AS unique_tracks,
    COUNT(DISTINCT tc.genre) as unique_genres,
    COUNT(DISTINCT tc.artist_id) as unique_artists
FROM listening_events le JOIN track_catalog tc 
	ON le.track_id = tc.track_id
WHERE source_context = "Algorithmic radio";


#2. Zoom in on each source to see what genres they tend to play and what listeners they tend to attract
# play more genres --> give more listener choices
WITH events_per_genre as (
	SELECT source_context, COUNT(DISTINCT event_id) total_events_per_genre
    FROM listening_events
    GROUP BY source_context
)
SELECT le.source_context, tc.genre,
	COUNT(DISTINCT le.listener_id) no_of_listeners_per_genre, 
	100* (COUNT(DISTINCT le.event_id)/epg.total_events_per_genre) events_per_genre_pct,
    ROUND(100*(SUM(le.completed)/ (SUM(le.completed)+SUM(le.skipped))),2) listening_completed_pct
FROM listening_events le JOIN track_catalog tc 
	ON le.track_id = tc.track_id
    JOIN events_per_genre epg 
    ON le.source_context = epg.source_context
GROUP BY le.source_context, tc.genre;

#3. focus on individual listeners: prove hypothesis e.g. listen more algorithmic, cover more artists
WITH listeners_unique_contexts as (
SELECT pi.listener_id, 
	COUNT(DISTINCT pi.source_type) unique_source_contexts,
    COUNT(DISTINCT tc.genre) unique_genres,
    COUNT(DISTINCT tc.artist_id) unique_artists,
    COUNT(DISTINCT tc.track_id) unique_tracks
FROM playlist_interactions pi JOIN track_catalog tc ON pi.track_id = tc.track_id
GROUP BY pi.listener_id)
SELECT unique_source_contexts, 
    AVG(unique_genres) avg_unique_genres,
    AVG(unique_artists) avg_unique_artists, 
    AVG(unique_tracks) avg_unique_tracks
FROM listeners_unique_contexts
GROUP BY unique_source_contexts
ORDER BY unique_source_contexts;

SELECT DISTINCT source_type FROM playlist_interactions;
SELECT * FROM track_catalog;
#4. For artists, their artist tag can affect their chances of appearing in different sources.
SELECT * FROM listening_events;
SELECT * FROM artist_tags ORDER BY artist_id;

SELECT _at.tag_name, 
SUM(le.source_context="Personalized Playlist") as play_count_personalised,
SUM(le.source_context="Algorithmic Radio") as play_count_algortihmic,
SUM(le.source_context="Search") as play_count_search,
SUM(le.source_context="Social Media") as play_count_social_media,
SUM(le.source_context="Editorial Playlist") as play_count_editorial,
SUM(le.source_context="Friend Share") as play_count_friend_share,
SUM(le.source_context="Artist Page") as play_count_artistpg
 FROM listening_events le
 JOIN artist_tags _at ON le.listener_id=_at.listener_id
 GROUP BY _at.tag_name
 ORDER BY play_count_personalised DESC;
 
 #5. For artists, their popularity can also affect their chances of appearing in different sources.
 WITH artist_popularity_events as (
 SELECT amm.artist_id, SUM(amm.total_streams) as number_of_streams,
	le.source_context
 FROM track_catalog tc
	JOIN listening_events le ON tc.track_id=le.track_id
	JOIN artist_monthly_metrics amm ON tc.artist_id=amm.artist_id
 GROUP BY amm.artist_id, le.source_context
 ORDER BY number_of_streams DESC),
 artist_buckets as (SELECT *,
        NTILE(5) OVER (
            ORDER BY number_of_streams DESC
        ) AS stream_bucket
    FROM artist_popularity_events),
bucket_streams as (
 SELECT stream_bucket,
	SUM(source_context="Personalized Playlist") as personalised,
	SUM(source_context="Algorithmic Radio") as algorithmic,
	SUM(source_context="Search") as search,
	SUM(source_context="Social Media") as social_media,
	SUM(source_context="Editorial Playlist") as editorial,
	SUM(source_context="Friend Share") as friend_share,
	SUM(source_context="Artist Page") as artist_pg
 FROM artist_buckets
 GROUP BY stream_bucket)
 SELECT sum(personalised) personalised_pct
 FROM bucket_streams
;
 
 WITH artist_popularity as (
 SELECT artist_id, SUM(total_streams) as number_of_streams
 FROM artist_monthly_metrics amm
 GROUP BY artist_id
 ORDER BY number_of_streams DESC),
 artist_buckets as (SELECT *,
        NTILE(5) OVER (
            ORDER BY number_of_streams DESC) stream_bucket
    FROM artist_popularity),
artist_events as (
 SELECT ab.stream_bucket,
 le.source_context
 FROM track_catalog tc
	JOIN listening_events le ON tc.track_id=le.track_id
	JOIN artist_buckets ab ON tc.artist_id=ab.artist_id),
bucket_streams as (
 SELECT stream_bucket,
	SUM(source_context="Personalized Playlist") as personalised,
	SUM(source_context="Algorithmic Radio") as algorithmic,
	SUM(source_context="Search") as search,
	SUM(source_context="Social Media") as social_media,
	SUM(source_context="Editorial Playlist") as editorial,
	SUM(source_context="Friend Share") as friend_share,
	SUM(source_context="Artist Page") as artist_pg
 FROM artist_events
 GROUP BY stream_bucket)
SELECT CONCAT('Top ', stream_bucket * 20, '%') AS artist_popularity,
    100.0 * SUM(personalised) OVER(ORDER BY stream_bucket)/
		SUM(personalised) OVER () AS personalised_pct,
    100.0 * SUM(algorithmic) OVER(ORDER BY stream_bucket)/
        SUM(algorithmic) OVER () AS algorithmic_pct,
    100.0 * SUM(search) OVER(ORDER BY stream_bucket)/
        SUM(search) OVER () AS search_pct,
	100.0 * SUM(social_media) OVER(ORDER BY stream_bucket)/
        SUM(social_media) OVER () AS social_media_pct,
	100.0 * SUM(editorial) OVER(ORDER BY stream_bucket)/
        SUM(editorial) OVER () AS editorial_pct,
	100.0 * SUM(friend_share) OVER(ORDER BY stream_bucket)/
        SUM(friend_share) OVER () AS friend_share_pct,
    100.0 * SUM(artist_pg) OVER (ORDER BY stream_bucket)/
		SUM(artist_pg) OVER () AS artist_pg_pct
FROM bucket_streams
;

 SELECT * from track_catalog;
 
SELECT * from artist_monthly_metrics
ORDER BY artist_id;
 
## check
WITH events_per_genre as (
	SELECT source_context, COUNT(DISTINCT event_id) total_events_per_genre
    FROM listening_events
    GROUP BY source_context
),
total as (SELECT le.source_context, tc.genre,
	COUNT(DISTINCT le.listener_id) no_of_listeners_per_genre, 
	100* (COUNT(DISTINCT le.event_id)/epg.total_events_per_genre) events_per_genre_pct
FROM listening_events le JOIN track_catalog tc 
	ON le.track_id = tc.track_id
    JOIN events_per_genre epg 
    ON le.source_context = epg.source_context
GROUP BY le.source_context, tc.genre
)
SELECT source_context, SUM(events_per_genre_pct) as total
FROM total
GROUP BY source_context;

SELECT * FROM wellbeing_surveys;
SELECT * FROM track_catalog;
SELECT * FROM release_metadata;