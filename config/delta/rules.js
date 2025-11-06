export default [
    {
        match: {
           //
        },
        callback: {
            url: "http://resource/.mu/delta",
            method: "POST",
        },
        options: {
            resourceFormat: "v0.0.1",
            gracePeriod: 1000,
            foldEffectiveChanges: true,
            ignoreFromSelf: true,
        },
    },
    {
        match: {
            predicate: {
                type: 'uri',
                value: 'http://schema.org/itemReviewed'
            },
        },
        callback: {
            url: 'http://stats-service/delta',
            method: "POST",
        },
        options: {
            resourceFormat: "v0.0.1",
            gracePeriod: 1000,
            foldEffectiveChanges: true,
            ignoreFromSelf: true,
        },
    },
];
