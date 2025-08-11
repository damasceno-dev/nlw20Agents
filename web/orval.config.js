module.exports = {
    'api-client': {
        input: {
            target: process.env.SWAGGER_URL || 'http://localhost:5130/swagger/v1/swagger.json',
        },
        output: {
            mode: 'split',
            target: './src/api/generated',
            client: 'react-query',
            override: {
                mutator: {
                    path: './src/api/mutator/custom-instance.ts',
                    name: 'customInstance',
                },
                operations: {
                    // You can add custom configurations for specific operations here
                },
                query: {
                    useQuery: true,
                    useInfinite: true,
                    useInfiniteQueryParam: 'pageParam',
                },
            },
        },
    },
};