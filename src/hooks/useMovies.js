import { useState, useEffect } from "react";

const API_URL = "https://api.themoviedb.org/3/movie/popular";
const API_KEY = process.env.REACT_APP_TMDB_API_KEY; // La clave debe estar en .env.local

export function useMovies() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchMovies() {
      try {
        const response = await fetch(`${API_URL}?api_key=${API_KEY}&language=es-ES`);
        if (!response.ok) {
          throw new Error("Error al obtener las películas");
        }
        const data = await response.json();
        setMovies(data.results);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    }

    fetchMovies();
  }, []);

  return { movies, loading, error };
}
