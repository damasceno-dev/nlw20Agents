import axios, { type AxiosRequestConfig, type Method } from 'axios';

// Get the base URL from environment variables
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export const AXIOS_INSTANCE = axios.create({
    baseURL: API_BASE_URL,
});

export const customInstance = async <T>({ 
    url,
    method,
    params,
    data,
    headers,
    signal
}: {
    url: string;
    method: Method | string;
    params?: Record<string, unknown>;
    data?: unknown;
    headers?: Record<string, string>;
    signal?: AbortSignal;
}): Promise<T> => {
    const response = await AXIOS_INSTANCE({
        url,
        method,
        params,
        data,
        headers,
        signal,
    } as AxiosRequestConfig);
    return response.data;
};