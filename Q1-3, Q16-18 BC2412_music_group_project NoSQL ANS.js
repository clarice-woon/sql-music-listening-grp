//Q1
db.listener_profiles.find({"subscription_tier":"Free","age":{$gte: 18, $lte: 30}}, 
    {"_id":0,"listener_id":1, "country_name":1,"age":1,  "subscription_tier":1,"primary_device":1})
    .sort({"age":-1, "listener_id":1})

//Q2
db.platform_catalog.find({"subscription_model":{$in:["Freemium", "Subscription"]},
    "lossless_available":"True"}, 
    {"_id":0, "platform_id":1, "platform_name":1, "subscription_model":1, "lossless_available":1})
    .sort({"platform_name":1})


//Q3
db.track_catalog.find({"explicit":{$in:["False", "0"]},  "track_name": {$regex: "Signal 00"} }, 
    {"_id":0, "track_id":1, "track_name":1, "artist_name":1, "genre":1})
    .sort({"track_id":1})



//Q16
db.listening_events
.aggregate( [
    {
        $addFields: {
            completed_int: {
                $convert: {
                    input: "$completed",
                    to: "int",
                    onError: null,
                    onNull: null
                }
            },
            skipped_int: {
                $convert: {
                    input: "$skipped",
                    to: "int",
                    onError: null,
                    onNull: null
                }
            }
        }
    },
    { //filter eligible events
        $match: 
        {$or: [
            { $and: [{ completed_int: 1 }, { skipped_int: 0 }] },
            { $and: [{ completed_int: 0 }, { skipped_int: 1 }] },
        ]
        }
    },
    {
        $lookup: {
            from: "platform_catalog",
            localField: "platform_id",
            foreignField: "platform_id",
            as: "events_platform"}
    },
    {
        $unwind: "$events_platform"
    },
    {
        $lookup: {
            from: "listener_profiles",
            localField: "listener_id",
            foreignField: "listener_id",
            as: "events_listener"}
    },
    {
        $unwind: "$events_listener"
    },
    { //group eligible events
        $group: 
        {
            _id: {
                "platform_id": "$events_platform.platform_id",
                "platform_name": "$events_platform.platform_name",
                "subscription_tier": "$events_listener.subscription_tier"},
            "total_eligible_events": {$count:{}},
            distinct_listeners:{$addToSet: "$listener_id"},
            completed_events:{$sum:{$cond:[{$eq: ["$completed", 1] },1,0]}},
            skipped_events:{$sum:{$cond:[{$eq: ["$skipped", 1] },1,0]}},
        }
    },
    {
        $match: {total_eligible_events: { $gte: 100 }
    }
    },
    {
        $project: {
            _id: 0,
            platform_id: "$_id.platform_id",
            platform_name: "$_id.platform_name",
            subscription_tier: "$_id.subscription_tier",
            "total_eligible_events": 1,
            "number_of_distinct_active_listeners": { $size: "$distinct_listeners" },
            completion_rate: {
                $multiply: [100,
                    {$divide: ["$completed_events", "$total_eligible_events"] }
                ]},
            skip_rate: {$multiply: [100,
                {$divide: ["$skipped_events", "$total_eligible_events"] }
            ]}
      }
    },
    {
        $sort:{"platform_id":1, "subscription_tier":1}
    }
])


////Q17
// listening events, track catalog, listener profiles
use "bc2412_music_group_project"
db.listening_events.aggregate([
    {
        $match: {
            source_context: {
                $in: ["Algorithmic Radio", "Personalized Playlist"]
            }
        }
    },
    {
        // Join track_catalog to retrieve genre and artist_id
        $lookup: {
            from: "track_catalog",
            localField: "track_id",
            foreignField: "track_id",
            as: "event_track"
        }
    },
    {
        $unwind: "$event_track"
    },
    {
        // Join listener_profiles for country and subscription tier
        $lookup: {
            from: "listener_profiles",
            localField: "listener_id",
            foreignField: "listener_id",
            as: "event_listener"
        }
    },
    {
        $unwind: "$event_listener"
    },
    {
        // Calculate measures for each listener
        $group: {
            _id: {
                listener_id: "$listener_id",
                country_code: "$event_listener.country_code",
                subscription_tier: "$event_listener.subscription_tier"
            },
            number_of_algorithmic_events: { $sum: 1 },
            distinct_genres: { $addToSet: "$event_track.genre" },
            distinct_artists: { $addToSet: "$event_track.artist_id" }
        }
    },
    {
        // Count distinct genres and artists
        $project: {
            _id: 1,
            number_of_algorithmic_events: 1,
            number_of_distinct_genres: { $size: "$distinct_genres" },
            number_of_distinct_artists: { $size: "$distinct_artists" }
        }
    },
    {
        // Only listeners with at least 10 algorithmic events
        $match: {
            number_of_algorithmic_events: { $gte: 10 }
        }
    },
    {
        // Calculate country-tier averages
        $group: {
            _id: {
                country_code: "$_id.country_code",
                subscription_tier: "$_id.subscription_tier"
            },
            number_of_eligible_listeners: { $sum: 1 },
            avg_number_of_algorithmic_events: {
                $avg: "$number_of_algorithmic_events"
            },
            avg_number_of_distinct_genres: {
                $avg: "$number_of_distinct_genres"
            },
            avg_number_of_distinct_artists: {
                $avg: "$number_of_distinct_artists"
            }
        }
    },
    {
        // Format output
        $project: {
            _id: 0,
            country_code: "$_id.country_code",
            subscription_tier: "$_id.subscription_tier",
            number_of_eligible_listeners: 1,
            avg_number_of_algorithmic_events: 1,
            avg_number_of_distinct_genres: 1,
            avg_number_of_distinct_artists: 1
        }
    },
    {
        $sort: {
            country_code: 1,
            subscription_tier: 1
        }
    }
]);



// Q18
// Q18 listening events, playlist interactions, listener profiles
db.listening_events.aggregate([
    {
        // Filter saved listening events
        $match: {
            saved: { $in: [1, "1"] }
        }
    },
    {
        // Join listener_profiles
        $lookup: {
            from: "listener_profiles",
            localField: "listener_id",
            foreignField: "listener_id",
            as: "event_listener"
        }
    },
    {
        $unwind: "$event_listener"
    },
    {
        // Check for retained playlist additions by listener
        $lookup: {
            from: "playlist_interactions",
            localField: "listener_id",
            foreignField: "listener_id",
            pipeline: [
                {
                    $match: {removed_later:"False"}
                },
                { $limit: 1 }
            ],
            as: "retained_playlist"
        }
    },
    {
        // Equivalent to SQL NOT EXISTS
        $match: {
            retained_playlist: { $eq: [] }
        }
    },
    {
        // Group by listener
        $group: {
            _id: {
                listener_id: "$listener_id",
                country_code: "$event_listener.country_code",
                subscription_tier: "$event_listener.subscription_tier"
            },
            saved_event_count: { $sum: 1 },
            distinct_tracks_saved: { $addToSet: "$track_id" }
        }
    },
    {
        // Calculate distinct track count
        $project: {
            _id: 0,
            listener_id: "$_id.listener_id",
            country_code: "$_id.country_code",
            subscription_tier: "$_id.subscription_tier",
            saved_event_count: 1,
            number_of_distinct_tracks_saved: {
                $size: "$distinct_tracks_saved"
            }
        }
    },
    {
    $sort: {
        saved_event_count: -1,
        listener_id: 1
    }
}
])
