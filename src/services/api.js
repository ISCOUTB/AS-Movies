const API_KEY = process.env.REACT_APP_TMDB_API_KEY;
const BASE_URL = "https://api.themoviedb.org/3";

export const fetchMovies = async (endpoint) => {
    try {
        const response = await fetch(`${BASE_URL}${endpoint}?api_key=${API_KEY}`);
        if (!response.ok) throw new Error("Error al obtener datos");
        return await response.json();
    } catch (error) {
        console.error(error);
        return null;
    }
};
