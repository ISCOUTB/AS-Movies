import React from "react";
import { useMovies } from "./hooks/useMovies";

function App() {
  const { movies, loading, error } = useMovies();

  return (
    <div>
      <h1>Películas Populares</h1>
      {loading && <p>Cargando...</p>}
      {error && <p>Error: {error}</p>}
      <ul>
        {movies.map((movie) => (
          <li key={movie.id}>{movie.title}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
